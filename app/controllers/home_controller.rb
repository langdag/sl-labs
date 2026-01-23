class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    if authenticated?
      @repositories = current_user.repositories.limit(5)
      @activities = Activity.where(repository_id: current_user.repository_ids)
                           .order(occurred_at: :desc)
                           .limit(20)
    end
  end
end
