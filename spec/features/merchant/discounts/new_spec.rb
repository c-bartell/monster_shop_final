require 'rails_helper'

describe 'New Bulk Discount Page:' do
  before :each do
    @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
    @m_user = @merchant_1.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword')
    @ogre = @merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
    @giant = @merchant_1.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
  end

  describe 'As a merchant employee' do
    before :each do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_user)
    end

    describe 'When I visit "/merchant/discounts/new"' do
      before :each do
        visit new_merchant_discount_path
      end

      it 'I see a form to create a new bulk discount' do

        expect(page).to have_field(:discount_percent)
        expect(page).to have_field(:discount_bulk_amount)
        expect(page).to have_button('Create Bulk Discount')
      end

      it 'When I correctly fill out and submit the form, I am taken back to the discounts index, where I see the new discount' do
        discount_data = { percent: 5, bulk_amount: 20 }

        fill_in :discount_percent, with: discount_data[:percent]
        fill_in :discount_bulk_amount, with: discount_data[:bulk_amount]
        click_button 'Create Bulk Discount'

        new_discount_id = Discount.last.id

        expect(current_path).to eq(merchant_discounts_path)

        within "#discount-#{new_discount_id}" do
          expect(page).to have_content("#{discount_data[:percent]}% off quantities of #{discount_data[:bulk_amount]} or more for a single item.")
        end
      end

      # After test for working form and create action, ad sad path for invalid :percent and :bulk_amount, flash messages, form remaining filled out
      # Should discounts be unique by amount for every merchant?
    end
  end
end
