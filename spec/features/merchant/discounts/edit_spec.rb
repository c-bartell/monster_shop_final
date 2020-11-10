require 'rails_helper'

describe 'Bulk Discount Edit page' do
  before :each do
    @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
    @m_user = @merchant_1.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword')
    @discount_1 = @merchant_1.discounts.create!(percent: 5, bulk_amount: 20)
    @discount_2 = @merchant_1.discounts.create!(percent: 10, bulk_amount: 40)
  end

  describe 'As a merchant employee' do
    before :each do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_user)
    end

    describe 'When I visit /merchant/discounts/:discount_id/edit' do
      before :each do
        visit edit_merchant_discount_path(@discount_1)
      end

      it 'I see an edit discount form, prefilled with the discounts data' do
        expect(page).to have_field(:discount_percent, with: @discount_1.percent)
        expect(page).to have_field(:discount_bulk_amount, with: @discount_1.bulk_amount)
        expect(page).to have_button('Update Bulk Discount')
      end
    end
  end
end
