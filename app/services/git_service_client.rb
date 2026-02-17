require_relative '../../lib/generated/git_object_store/git_service_pb'
require_relative '../../lib/generated/git_object_store/git_service_services_pb'

class GitServiceClient
  class << self
    def resolve_ref(repository, ref)
      request = GitService::ResolveRefRequest.new(
        repository_id: repository.id.to_s,
        repository_name: repository.name,
        ref: ref
      )
      response = stub.resolve_ref(request)
      response.sha.presence
    rescue GRPC::NotFound
      nil
    end

    def get_commit(repository, sha)
      request = GitService::GetCommitRequest.new(
        repository_id: repository.id.to_s,
        repository_name: repository.name,
        sha: sha
      )
      stub.get_commit(request)
    rescue GRPC::NotFound
      nil
    end

    def get_tree(repository, sha)
      request = GitService::GetTreeRequest.new(
        repository_id: repository.id.to_s,
        repository_name: repository.name,
        sha: sha
      )
      stub.get_tree(request)
    rescue GRPC::NotFound
      nil
    end

    def get_blob(repository, sha)
      request = GitService::GetBlobRequest.new(
        repository_id: repository.id.to_s,
        repository_name: repository.name,
        sha: sha
      )
      stub.get_blob(request)
    rescue GRPC::NotFound
      nil
    end

    private

    def stub
      @stub ||= GitService::GitObjectStore::Stub.new('localhost:50051', :this_channel_is_insecure)
    end
  end
end
