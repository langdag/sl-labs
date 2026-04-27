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
    sha, @resolved_ref = GitServiceClient.resolve_ref_with_fallback(@repo, @ref)

    return nil unless sha

    # 2. Get the commit object via gRPC
    # Note: We assume the resolved ref points to a commit for now
    commit_response = GitServiceClient.get_commits(@repo, sha)
    return nil unless commit_response && commit_response.entries.any?

    @commits = commit_response.entries # Store full history if needed

    # 3. Format the current commit for the main header banner
    @commit = format_single_commit(commit_response.entries.first)

    # 4. Start traversal from the commit's tree
    # The first entry in the response is the specific commit we requested
    root_tree_sha = commit_response.entries.first.tree_sha
    
    # We pass the root 'sha' (the commit hash) so the server can label the files with this commit
    @commit_sha = commit_response.entries.first.sha

    traverse(root_tree_sha, @path)
  end

  private

  def traverse(current_sha, path_string)
    # If no path, return the tree for the current SHA
    return fetch_tree(current_sha, "", @commit_sha) if path_string.blank?

    path_string.split("/").reject(&:blank?).reduce(fetch_tree(current_sha, "", @commit_sha)) do |current_object, segment|
      return nil unless current_object.is_a?(::Sl::Git::GetTreeResponse)

      entry = current_object.entries.find { |e| File.basename(e.name) == segment }
      return nil unless entry

      if entry.mode == "40000" # Directory
        fetch_tree(entry.sha, entry.name, @commit_sha)
      else # File / Blob
        # We need to return a GetBlobResponse-like object so the controller recognizes it.
        # Ideally, we'd fetch the blob here or in the controller.
        # Let's signify it's a blob by fetching it lightly or constructing a response.
        GitServiceClient.get_blob(@repo, entry.sha)
      end
    end
  end

  def format_single_commit(proto)
    return nil unless proto
    {
      sha: proto.sha,
      author: proto.author.to_s.split('<').first.to_s.strip,
      message: proto.message.to_s.split("\n").first,
      committed_date: Time.at(proto.respond_to?(:committed_at) ? proto.committed_at : 0)
    }
  end

  def fetch_tree(sha, path = "", commit_sha = nil)
    GitServiceClient.get_tree(@repo, sha, path, commit_sha)
  end
end
