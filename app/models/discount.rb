class Discount < ApplicationRecord
  belongs_to :merchant

  validates :percent, presence: true, numericality: { greater_than: 0, less_than: 100 }
  validates :bulk_amount, presence: true, numericality: { greater_than: 0 }

  def conflict?
    merchant = self.merchant
    query = merchant.discounts.where(percent: self.percent).or(merchant.discounts.where(bulk_amount: self.bulk_amount))

    query != []
  end
end
