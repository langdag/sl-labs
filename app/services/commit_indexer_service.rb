class CommitIndexerService
  def initialize(repository)
    @repository = repository
    @user_cache = {}
  end

  def index(ref = "HEAD")
    git_repo = @repository.git_repo
    return unless git_repo

    sha = git_repo.resolve_ref(ref)
    return unless sha

    @git_repo = git_repo # Set for use in create_commit_record
    queue = [sha]
    indexed_shas = Set.new

    new_commits_count = 0
    head_sha = nil

    while queue.any?
      current_sha = queue.shift
      next if indexed_shas.include?(current_sha) || Commit.exists?(repository: @repository, sha: current_sha)

      begin
        git_commit = GitObjectStore::GitObject.find(@git_repo, current_sha)
        next unless git_commit.is_a?(GitObjectStore::Commit)

        create_commit_record(git_commit)
        indexed_shas.add(current_sha)
        new_commits_count += 1
        head_sha ||= current_sha

        queue.concat(git_commit.parents)
      rescue => e
        Rails.logger.error "Failed to index commit #{current_sha}: #{e.message}"
        next
      end
    end

    if new_commits_count > 0
      create_activity(new_commits_count, head_sha, ref)
    end
  end

  private

  def create_activity(count, head_sha, ref)
    Activity.create!(
      user: @repository.user,
      repository: @repository,
      action_type: 'push',
      commit_count: count,
      ref: ref,
      head_sha: head_sha,
      occurred_at: Time.current
    )
  end

  def create_commit_record(git_commit)
    author_data = parse_author(git_commit.author)

    # Fail if we can't parse metadata required by the database
    raise "Malformed author data: #{git_commit.author}" unless author_data

    # Find user (cached) or fallback to repo owner
    user = find_user(author_data[:email]) || @repository.user

    Commit.find_or_create_by!(
      repository: @repository,
      sha: git_commit.sha
    ) do |c|
      c.user = user
      c.author_name = author_data[:name]
      c.author_email = author_data[:email]
      c.message = git_commit.message
      c.committed_at = author_data[:date]
      c.parent_shas = git_commit.parents
    end
  end

  def find_user(email)
    @user_cache[email] ||= User.find_by(email_address: email)
  end

  # Git author format: "Name <email> timestamp zone"
  def parse_author(author_string)
    return nil if author_string.blank?

    match = author_string.match(/\A(.*) <(.*)> (\d+) (.*)\z/)

    return nil if match.nil?

    {
      name: match[1],
      email: match[2],
      date: Time.at(match[3].to_i)
    }
  end
end
