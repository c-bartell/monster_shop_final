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


end
