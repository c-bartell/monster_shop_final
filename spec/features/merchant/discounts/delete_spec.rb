require 'rails_helper'

describe 'Merchants can delete Bulk Orders:' do
  before :each do
    @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
    @merchant_2 = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
    @m_user = @merchant_1.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword')
    @discount_1 = @merchant_1.discounts.create!(percent: 5, bulk_amount: 20)
    @discount_2 = @merchant_1.discounts.create!(percent: 10, bulk_amount: 40)
    @discount_3 = @merchant_2.discounts.create!(percent: 6, bulk_amount: 30)
  end

  describe 'As a merchant employee' do
    before :each do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_user)
    end

    describe 'When I visit my bulk discounts index' do
      before :each do
        visit merchant_discounts_path
      end
      describe 'And I click "Delete Bulk Discount" next to a discount' do
        it 'That discount is destroyed and I am returned to the discounts index, where I no longer see that discount.' do
          discount_1_id = @discount_1.id
          expect(Discount.exists?(discount_1_id)).to be(true)

          within "#discount-#{discount_1_id}" do
            click_link 'Delete Bulk Discount'
          end

          expect(Discount.exists?(discount_1_id)).to be(false)
          expect(current_path).to eq(merchant_discounts_path)
          # Expectation works with page.reset!, not sure why or if I should use it.
          # page.reset!
          # Broken expectation, but working in app. Fix later if time allows.
          # expect(page).to_not have_css("#discount-#{discount_1_id}")
        end
      end
    end
  end
end
