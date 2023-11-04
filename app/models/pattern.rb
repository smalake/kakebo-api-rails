class Pattern < ApplicationRecord
  validates :user_id, presence: true
  validates :store_name, presence: true
  validates :category, presence: true
end
