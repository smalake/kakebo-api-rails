class Event < ApplicationRecord
  validates :amount, presence: true
  validates :group_id, presence: true
end
