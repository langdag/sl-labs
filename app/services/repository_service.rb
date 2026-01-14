class RepositoryService < BaseService
  def initialize(repository)
    @repository = repository
    @disk_path = repository.disk_path
  end

  def call
    case
    when @repository.destroyed?
      cleanup_git_repository
    when @repository.previously_new_record?
      initialize_git_repository
    when @repository.saved_change_to_name?
      rename_git_repository
    end
  end

  def cleanup_git_repository
    if Dir.exist?(@disk_path)
      FileUtils.remove_dir(@disk_path, force: true, recursive: true)
    end
  end

  private

  def rename_git_repository
    old_name, _new_name = @repository.saved_change_to_name
    old_path = Rails.root.join("storage", "repositories", "#{@repository.id}_#{old_name}")

    if Dir.exist?(old_path) && old_path != @disk_path
      FileUtils.mv(old_path, @disk_path)
    end
  end

  def initialize_git_repository
    FileUtils.mkdir_p(File.dirname(@disk_path))
    GitObjectStore::Repository.init(@disk_path) unless Dir.exist?(@disk_path)
  end
end
