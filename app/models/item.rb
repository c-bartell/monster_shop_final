class Item < ApplicationRecord
  belongs_to :merchant
  has_many :order_items
  has_many :orders, through: :order_items
  has_many :reviews, dependent: :destroy

  validates_presence_of :name,
                        :description,
                        :image,
                        :price,
                        :inventory

  def self.active_items
    where(active: true)
  end

  def self.by_popularity(limit = nil, order = "DESC")
    left_joins(:order_items)
    .select('items.id, items.name, COALESCE(sum(order_items.quantity), 0) AS total_sold')
    .group(:id)
    .order("total_sold #{order}")
    .limit(limit)
  end

  def sorted_reviews(limit = nil, order = :asc)
    reviews.order(rating: order).limit(limit)
  end

  def average_rating
    reviews.average(:rating)
  end

  def bulk_discount(amount)
    self.merchant.discounts.where('bulk_amount <= ?', amount).order(percent: :desc).first
  end

  def bulk_price(amount)
    discount = bulk_discount(amount)
    if discount
      self.price * (1.0 - (discount.percent / 100.0))
    else
      self.price
    end
  end

  def subtotal(amount)
    bulk_price(amount) * amount
  end
end
