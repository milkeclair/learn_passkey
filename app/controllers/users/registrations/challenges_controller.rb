class Users::Registrations::ChallengesController < ApplicationController
  def create
    user = User.new.tap { it.build_profile(registration_params) }

    challenge_details = WebAuthn::Credential.options_for_create(
      user: { id: user.webauthn_id, name: user.profile.name },
      authenticator_selection: {
        # パスキーのみでログインできる
        resident_key: "discouraged",
        # 認証器での確認を必須にする
        user_verification: "required"
      }
    )

    confirm_code = SecureRandom.hex(3)

    session[:current_registration] = {
      challenge: challenge_details.challenge,
      user:,
      profile: user.profile,
      confirm_code:
    }
    view = render_to_string(partial: "users/registrations/confirm_code")
    render json: { details: challenge_details, view:, email: registration_params[:email] }
  end

  private def registration_params
    params.expect(registration: %i[email name])
  end
end
