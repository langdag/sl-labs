class WebhooksController < ApplicationController
  # Webhooks come from Git, not a browser, so they don't have CSRF tokens
  skip_before_action :verify_authenticity_token 
  allow_unauthenticated_access

  def push
    repository_id = params[:repository_id]
    refname = params[:ref]

    if repository_id.present? && refname.present?
      # This instantly queues the background job and returns control
      PostReceiveJob.perform_later(repository_id.to_i, refname)
      
      render json: { status: "success", message: "Job enqueued" }, status: :ok
    else
      render json: { status: "error", message: "Missing repository_id or ref" }, status: :bad_request
    end
  end
end
