require 'rails_helper'

RSpec.describe Discount do
  describe 'Relationships' do
    it { should belong_to(:merchant) }
  end

  describe 'Validations' do
    it { should validate_presence_of :percent }
    it { should validate_numericality_of(:percent).is_greater_than(0).is_less_than(100) }
    it { should validate_presence_of :bulk_amount }
    it { should validate_numericality_of(:bulk_amount).is_greater_than(0) }
  end

  describe 'Instance Methods' do
    it '#conflict?' do
      merchant = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      discount_1 = merchant.discounts.create!(percent: 5, bulk_amount: 20)
      new_discount_1 = merchant.discounts.new(percent: 5, bulk_amount: 20)
      new_discount_2 = merchant.discounts.new(percent: 10, bulk_amount: 20)
      new_discount_3 = merchant.discounts.new(percent: 10, bulk_amount: 30)

      expect(new_discount_1.conflict?).to be(true)
      expect(new_discount_2.conflict?).to be(true)
      expect(new_discount_3.conflict?).to be(false)
    end
  end
end
