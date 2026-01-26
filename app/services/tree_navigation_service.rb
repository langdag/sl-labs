class TreeNavigationService < BaseService
  attr_reader :resolved_ref

  def initialize(repo, ref, path = nil)
    @repo = repo
    @ref = ref.presence || "HEAD"
    @path = path
    @resolved_ref = @ref
  end

  def call
    repo = git_object_repo
    return nil unless repo

    hash = reference_hash
    return nil unless hash

    object = GitObjectStore::GitObject.find(repo, hash)

    root_tree = case object
                when GitObjectStore::Tree then object
                when GitObjectStore::Commit then GitObjectStore::GitObject.find(repo, object.tree)
                else return nil
                end

    traverse(root_tree, @path)
  end

  private

  def git_object_repo
    @git_object_repo ||= @repo.git_repo
  end

  def reference_hash
    # 1. Try to resolve exactly what was requested (HEAD, master, or a specific branch)
    sha = git_object_repo&.resolve_ref(@ref)
    
    # 2. If it's HEAD and it failed (the "unborn branch" issue), look for fallbacks
    if sha.nil? && @ref == "HEAD"
      ["master", "main"].each do |fallback|
        sha = git_object_repo&.resolve_ref(fallback)
        if sha
          @resolved_ref = fallback # Update the "pretty" name for the UI/Redirects
          break # STOP once we find a real branch!
        end
      end
    end

    sha
  end

  def traverse(start_tree, path_string)
    return start_tree if path_string.blank?

    path_string.split("/").reject(&:blank?).reduce(start_tree) do |current_object, segment|
      return nil unless current_object.is_a?(GitObjectStore::Tree)

      entry = current_object.entries.find { |e| e[:name] == segment }
      return nil unless entry

      GitObjectStore::GitObject.find(git_object_repo, entry[:sha])
    end
  end
end
