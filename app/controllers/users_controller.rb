class UsersController < ApplicationController
  before_action :reject_unauthenticated_access

  def show
    @user = User.preload(:profile, :credentials).find(current_user.id)
  end
end
