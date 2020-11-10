class Discount < ApplicationRecord
  belongs_to :merchant

  validates :percent, presence: true, numericality: { greater_than: 0, less_than: 100 }, uniqueness: {scope: :merchant_id}
  validates :bulk_amount, presence: true, numericality: { greater_than: 0 }, uniqueness: {scope: :merchant_id}
end
