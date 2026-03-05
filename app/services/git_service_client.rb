require 'sl-protos'

class GitServiceClient
  class << self
    def resolve_ref(repository, ref)
      request = Sl::Git::ResolveRefRequest.new(
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
      request = Sl::Git::GetCommitRequest.new(
        repository_id: repository.id.to_s,
        repository_name: repository.name,
        sha: sha
      )
      stub.get_commit(request)
    rescue GRPC::NotFound
      nil
    end

    def get_tree(repository, sha)
      request = Sl::Git::GetTreeRequest.new(
        repository_id: repository.id.to_s,
        repository_name: repository.name,
        sha: sha
      )
      stub.get_tree(request)
    rescue GRPC::NotFound
      nil
    end

    def get_blob(repository, sha)
      request = Sl::Git::GetBlobRequest.new(
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
      @stub ||= Sl::Git::ObjectStore::Stub.new('localhost:50051', :this_channel_is_insecure)
    end
  end
end
