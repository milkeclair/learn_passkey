class SessionsController < ApplicationController
  before_action :reject_authenticated_access, only: %i[new create]

  def new
  end

  def create
    webauthn_credential = WebAuthn::Credential.from_get(session_params.to_h)

    user = User.find_by(webauthn_id: session_params.dig(:response, :userHandle))
    credential = user.credentials.find_by(external_id: Base64.strict_encode64(webauthn_credential.raw_id))

    begin
      webauthn_credential.verify(
        session.dig(:current_authentication, "challenge"),
        public_key: credential.public_key,
        sign_count: credential.sign_count,
        user_verification: true
      )

      credential.update!(sign_count: webauthn_credential.sign_count)
      reset_session
      session[:user_id] = user.id
      render json: { redirect: user_path(user) }
    rescue WebAuthn::Error => _error
      render json: { error: "エラーが発生しました" }, status: :unprocessable_content
    end
  end

  def destroy
    reset_session
    redirect_to new_sessions_path, status: :see_other
  end

  private def session_params
    params.expect(
      session: [
        :type,
        :id,
        :rawId,
        :authenticatorAttachment,
        clientExtensionResults: [],
        response: [
          :clientDataJSON,
          :authenticatorData,
          :signature,
          :userHandle
        ]
      ]
    )
  end
end
