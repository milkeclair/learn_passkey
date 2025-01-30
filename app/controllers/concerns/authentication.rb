module Authentication
  extend ActiveSupport::Concern

  def reject_unauthenticated_access
    redirect_to new_session_path unless current_user
  end

  def reject_authenticated_access
    redirect_to user_path(current_user) if current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
