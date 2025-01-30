class Registrations::ConfirmationEmailsController < ApplicationController
  def create
    p "confirm_code: #{session.dig(:current_registration, "confirm_code")}"

    if registration_params[:confirmCode] == session.dig(:current_registration, "confirm_code")
      session[:current_registration]["confirm_code"] = nil
      session[:current_registration]["confirmed"] = true
      view = render_to_string(partial: "registrations/webauthn")
      render json: { view: }, status: :ok
    else
      render json: { error: "コードが違います" }, status: :unprocessable_content
    end
  end

  private def registration_params
    params.expect(registration: %i[email confirmCode])
  end
end
