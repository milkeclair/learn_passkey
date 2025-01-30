import { Controller } from "@hotwired/stimulus";
import * as WebAuthnJSON from "@github/webauthn-json";

// Connects to data-controller="webauthn-session"
export default class extends Controller {
  static targets = ["form", "submit"];
  static values = { challengePath: String };
  #errorClass = "error";

  submit = async (event) => {
    event.preventDefault();

    if (!(await this.#isNavigatorSupported())) {
      this.#showError("WebAuthnに対応していません");
      return;
    }

    const challengeResult = await this.#createChallenge();
    const credential = await WebAuthnJSON.get({ publicKey: challengeResult.details });
    const response = await this.#authenticate(credential);

    if (!response.error) {
      this.#removeError();
      window.location.href = response.redirect;
    } else {
      this.#showError(response.error);
    }
  };

  #isNavigatorSupported = async () => {
    return (
      navigator.credentials &&
      navigator.credentials.create &&
      navigator.credentials.get &&
      window.PublicKeyCredential &&
      (await PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable())
    );
  };

  #createChallenge = async () => {
    return await this.#post(this.challengePathValue);
  };

  #authenticate = async (credential) => {
    return await this.#post(this.formTarget.action, credential);
  };

  #post = async (url, data = {}) => {
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
      body: JSON.stringify(data),
    });

    return response.json();
  };

  #showError = (error) => {
    this.#removeError();
    const errorElement = document.createElement("div");
    errorElement.classList.add(this.#errorClass);
    errorElement.textContent = error;
    this.element.appendChild(errorElement);
  };

  #removeError = () => {
    this.element.querySelectorAll(`.${this.#errorClass}`).forEach((element) => element.remove());
  };
}
