require 'rails_helper'

RSpec.describe Discount do
  describe 'Relationships' do
    it { should belong_to(:merchant) }
  end

  describe 'Validations' do
    it { should validate_presence_of :percent }
    it { should validate_numericality_of(:percent).is_greater_than(0).is_less_than(100) }
    it { should validate_uniqueness_of(:percent).scoped_to(:merchant_id) }
    it { should validate_presence_of :bulk_amount }
    it { should validate_numericality_of(:bulk_amount).is_greater_than(0) }
    it { should validate_uniqueness_of(:bulk_amount).scoped_to(:merchant_id) }
  end

  describe 'Instance Methods' do
    it '#conflict?' do
      merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      merchant_2 = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      discount_1 = merchant_1.discounts.create!(percent: 5, bulk_amount: 20)
      discount_2 = merchant_2.discounts.create!(percent: 10, bulk_amount: 30)
      new_discount_1 = merchant_1.discounts.new(percent: 5, bulk_amount: 20)
      new_discount_2 = merchant_1.discounts.new(percent: 5, bulk_amount: 30)
      new_discount_3 = merchant_1.discounts.new(percent: 10, bulk_amount: 20)
      new_discount_4 = merchant_1.discounts.new(percent: 10, bulk_amount: 30)
      new_discount_5 = merchant_2.discounts.new(percent: 10, bulk_amount: 30)

      expect(new_discount_1.conflict?).to be(true)
      expect(new_discount_2.conflict?).to be(true)
      expect(new_discount_3.conflict?).to be(true)
      expect(new_discount_4.conflict?).to be(false)
      expect(new_discount_5.conflict?).to be(true)
    end
  end
end
