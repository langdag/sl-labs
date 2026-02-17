class TreeNavigationService < BaseService
  attr_reader :resolved_ref, :commit

  def initialize(repo, ref, path = nil)
    @repo = repo
    @ref = ref.presence || "HEAD"
    @path = path
    @resolved_ref = @ref
    @commit = nil
  end

  def call
    # 1. Resolve Ref via gRPC
    sha = GitServiceClient.resolve_ref(@repo, @ref)

    # Fallback logic for HEAD -> main/master
    if sha.nil? && @ref == "HEAD"
      ["master", "main"].each do |fallback|
        sha = GitServiceClient.resolve_ref(@repo, fallback)
        if sha
          @resolved_ref = fallback
          break
        end
      end
    end

    return nil unless sha

    # 2. Get the commit object via gRPC
    # Note: We assume the resolved ref points to a commit for now
    commit_response = GitServiceClient.get_commit(@repo, sha)
    return nil unless commit_response

    @commit = Helper.format_commit(commit_response)

    # 3. Start traversal from the commit's tree
    # The commit response gives us the tree_sha
    root_tree_sha = commit_response.tree_sha

    traverse(root_tree_sha, @path)
  end

  private

  def traverse(current_sha, path_string)
    # If no path, return the tree for the current SHA
    return fetch_tree(current_sha) if path_string.blank?

    path_string.split("/").reject(&:blank?).reduce(fetch_tree(current_sha)) do |current_object, segment|
      return nil unless current_object.is_a?(GitService::GetTreeResponse)

      entry = current_object.entries.find { |e| e.name == segment }
      return nil unless entry

      if entry.mode == "40000" # Directory
        fetch_tree(entry.sha)
      else # File / Blob
        # We need to return a GetBlobResponse-like object so the controller recognizes it.
        # Ideally, we'd fetch the blob here or in the controller.
        # Let's signify it's a blob by fetching it lightly or constructing a response.
        GitServiceClient.get_blob(@repo, entry.sha)
      end
    end
  end

  def fetch_tree(sha)
    GitServiceClient.get_tree(@repo, sha)
  end

  module Helper
    def self.format_commit(proto_commit)
      match = proto_commit.author.match(/(\d+) [+-]\d{4}\z/)
      date = match ? Time.at(match[1].to_i) : Time.current

      {
        sha: proto_commit.sha,
        author: proto_commit.author.split('<').first.strip,
        message: proto_commit.message.split("\n").first,
        committed_date: date
      }
    end
  end
end
