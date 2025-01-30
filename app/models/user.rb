class User < ApplicationRecord
  has_one :profile, dependent: :destroy
  has_many :credentials, dependent: :destroy

  validates :webauthn_id, presence: true, uniqueness: true

  after_initialize do
    self.webauthn_id ||= ::WebAuthn.generate_user_id
    while User.exists?(webauthn_id:)
      self.webauthn_id = ::WebAuthn.generate_user_id
    end
  end
end
