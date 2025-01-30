class UsersController < ApplicationController
  before_action :reject_unauthenticated_access

  def show
    @user = User.preload(:profile, :credentials).find(user_params)
  end

  private def user_params
    params.expect(:id)
  end
end
