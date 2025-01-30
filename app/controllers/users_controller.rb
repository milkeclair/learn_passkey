class UsersController < ApplicationController
  def show
    @user = User.preload(:profile, :credentials).find(user_params)
  end

  private def user_params
    params.expect(:id)
  end
end
