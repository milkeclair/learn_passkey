class Profile < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
end
