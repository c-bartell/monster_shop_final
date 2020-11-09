class Discount < ApplicationRecord
  validates :percent, presence: true, numericality: { greater_than: 0, less_than: 100 }
  validates :bulk_amount, presence: true, numericality: { greater_than: 0 }
end