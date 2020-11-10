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

  end
end
