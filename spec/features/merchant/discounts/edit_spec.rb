require 'rails_helper'

describe 'Bulk Discount Edit page' do
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

    describe 'When I visit /merchant/discounts/:discount_id/edit' do
      before :each do
        visit edit_merchant_discount_path(@discount_1)
      end

      it 'I see an edit discount form, prefilled with the discounts data' do
        expect(page).to have_field(:discount_percent, with: @discount_1.percent)
        expect(page).to have_field(:discount_bulk_amount, with: @discount_1.bulk_amount)
        expect(page).to have_button('Update Bulk Discount')
      end

      it 'When I change an attribute and click "Update Bulk Discount", the discount is updatedn and I am taken back to the discounts index, where I see the updated info' do
        updated_percent = 6
        updated_bulk_amount = 21

        fill_in :discount_percent, with: updated_percent
        fill_in :discount_bulk_amount, with: updated_bulk_amount
        click_button 'Update Bulk Discount'

        expect(@discount_1.percent).to eq(updated_percent)
        expect(@discount_1.bulk_amount).to eq(updated_bulk_amount)
        expect(current_path).to eq(merchant_discounts_path)

        within "#discount-#{@discount_1.id}" do
          expect(page).to have_content("Discount #{@discount_1.id}:")
          expect(page).to have_content("#{updated_percent}% off quantities of #{updated_bulk_amount} or more for a single item.")
        end
      end

      it 'I cannot change percent or bulk_amount to have the same value as an exiting discount for the same merchant, and I get a message if I try' do

        fill_in :discount_bulk_amount, with: @discount_2.bulk_amount

        click_button 'Update Bulk Discount'

        expect(page).to have_content("Bulk amount has already been taken.")

        fill_in :discount_percent, with: @discount_2.percent
        fill_in :discount_bulk_amount, with: @discount_2.bulk_amount

        click_button 'Update Bulk Discount'

        expect(page).to have_content("Percent has already been taken and bulk amount has already been taken.")

        fill_in :discount_percent, with: @discount_2.percent
        fill_in :discount_bulk_amount, with: @discount_1.bulk_amount

        click_button 'Update Bulk Discount'

        expect(page).to have_content("Percent has already been taken.")

        fill_in :discount_percent, with: @discount_3.percent
        fill_in :discount_bulk_amount, with: @discount_3.bulk_amount

        click_button 'Update Bulk Discount'

        expect(current_path).to eq(merchant_discounts_path)
        expect(page).to_not have_content("Percent has already been taken and bulk amount has already been taken.")
      end
    end
  end
end
