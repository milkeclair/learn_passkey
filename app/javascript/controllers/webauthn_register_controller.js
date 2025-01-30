import { Controller } from "@hotwired/stimulus";
import * as WebAuthnJSON from "@github/webauthn-json";

// Connects to data-controller="webauthn-register"
export default class extends Controller {
  static targets = ["form", "email", "name", "confirmCode"];
  #challengeResult;
  #confirmEmail;
  #errorClass = "error";

  challengeStep = async (event) => {
    event.preventDefault();

    const response = await this.#createChallenge();

    if (!response.error) {
      this.#removeError();
      this.#challengeResult = response.details;
      this.#confirmEmail = response.email;
      const nextForm = this.#createFormHTML(response.view);
      this.element.replaceChild(nextForm, this.formTarget);
    } else {
      this.#showError(response.error);
    }
  };

  confirmEmailStep = async (event) => {
    event.preventDefault();

    const formData = {
      registration: {
        email: this.#confirmEmail,
        confirmCode: this.confirmCodeTarget.value,
      },
    };
    const response = await this.#post(this.formTarget.action, formData);

    if (!response.error) {
      this.#removeError();
      const nextForm = this.#createFormHTML(response.view);
      this.element.replaceChild(nextForm, this.formTarget);
    } else {
      this.#showError(response.error);
    }
  };

  webauthnStep = async (event) => {
    event.preventDefault();

    const response = await this.#createCredential(this.#challengeResult);
    if (!response.error) {
      window.location.href = response.redirect;
    } else {
      this.#showError(response.error);
    }
  };

  reset = () => {
    window.location.reload();
  };

  #createChallenge = async () => {
    const formData = { registration: {} };
    const param = /registration\[(.*)\]/;
    new FormData(this.formTarget).forEach((value, key) => {
      const match = key.match(param);
      if (match) {
        formData["registration"][match[1]] = value;
      }
    });

    return await this.#post(this.formTarget.action, formData);
  };

  #createCredential = async (challengeDetails) => {
    const credential = await WebAuthnJSON.create({ publicKey: challengeDetails });
    const formData = { registration: credential };

    return await this.#post(this.formTarget.action, formData);
  };

  #post = async (url, data) => {
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

  #createFormHTML = (formString) => {
    const parser = new DOMParser();
    const dom = parser.parseFromString(formString, "text/html");
    return dom.body.firstElementChild;
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
