class Sessions::ChallengesController < ApplicationController
  before_action :reject_authenticated_access

  def create
    challenge_details = WebAuthn::Credential.options_for_get(
      user_verification: "required"
    )

    session[:current_authentication] = { challenge: challenge_details.challenge }

    render json: { details: challenge_details }
  end
end
