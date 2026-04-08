class PostReceiveJob < ApplicationJob
  queue_as :default

  def perform(repository_id, refname)
    repository = Repository.find(repository_id)

    CommitIndexerService.new(repository).index(refname)
  end
end