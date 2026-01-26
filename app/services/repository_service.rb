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
      setup_hooks
    when @repository.saved_change_to_name?
      rename_git_repository
      setup_hooks
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
    FileUtils.mkdir_p(@disk_path)
    # Initialize as bare repository for easier pushing and to avoid worktree conflicts
    GitObjectStore::Repository.init(@disk_path, bare: true) unless Dir.exist?(@disk_path.join("objects"))
  end

  def setup_hooks
    hooks_dir = @disk_path.join("hooks")
    FileUtils.mkdir_p(hooks_dir)

    hook_path = hooks_dir.join("post-receive")
    
    # We must unset Bundler/Git environment variables that Git sets during a push,
    # otherwise the 'rails runner' will try to load gems using those variables and fail.
    hook_content = <<~BASH
      #!/bin/bash
      while read oldrev newrev refname
      do
        # Trigger SL Labs Indexer in a clean environment
        (
          cd #{Rails.root}
          unset BUNDLE_GEMFILE
          unset BUNDLE_BIN_PATH
          unset BUNDLE_PATH
          unset BUNDLE_APP_CONFIG
          unset GEM_HOME
          unset GEM_PATH
          unset RUBYOPT
          unset GIT_DIR
          unset GIT_QUARANTINE_PATH
          
          # Force a fresh bundle environment
          export RAILS_ENV=development
          #{Rails.root}/bin/rails runner "CommitIndexerService.new(Repository.find(#{@repository.id})).index('$refname')"
        )
      done
    BASH

    File.write(hook_path, hook_content)
    FileUtils.chmod(0755, hook_path)
  end
end
