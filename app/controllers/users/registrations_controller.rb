class Users::RegistrationsController < ApplicationController
  def new
  end

  def create
    webauthn_credential = WebAuthn::Credential.from_create(registration_params.to_h)
    user = User.new(session.dig(:current_registration, "user")).tap do
      it.build_profile(session.dig(:current_registration, "profile"))
    end

    begin
      webauthn_credential.verify(session.dig(:current_registration, "challenge"), user_verification: true)

      user.credentials.build(
        external_id: Base64.strict_encode64(webauthn_credential.raw_id),
        public_key: webauthn_credential.public_key,
        sign_count: webauthn_credential.sign_count
      )

      if user.valid? && user.profile.valid? && user.credentials.first.valid? && session.dig(:current_registration, "confirmed")
        user.save!
        session[:user_id] = user.id
        session[:current_registration] = nil
        render json: { redirect: user_path(user) }
      else
        render json: { error: "エラーが発生しました" }, status: :unprocessable_content
      end
    rescue WebAuthn::Error => _error
      render json: { error: "エラーが発生しました" }, status: :unprocessable_content
    end
  end

  private def registration_params
    params.expect(
      registration: [
        :confirmCode,
        :type,
        :id,
        :rawId,
        :authenticatorAttachment,
        clientExtensionResults: [
          :credProps
        ],
        response: [
          :clientDataJSON,
          :attestationObject,
          transports: []
        ]
      ]
    )
  end
end
