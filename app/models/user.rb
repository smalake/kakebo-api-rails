class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :group_id, presence: true
end
