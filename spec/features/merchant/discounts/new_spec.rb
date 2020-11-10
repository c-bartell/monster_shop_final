require 'rails_helper'

describe 'New Bulk Discount Page:' do
  before :each do
    @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
    @merchant_2 = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
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

      it 'If I fill out the form with invalid percent or bulk_amount, or if I leave a field blank, I am returned to the form, where I see an error message and the data that I filled in' do
        percent = { too_high: 100, too_low: 0, negative: -1, letter: 'A', valid: 5 }
        bulk_amount = { too_low: 0, negative: -1, letter: 'A', valid: 20 }

        # All fields blank
        click_button 'Create Bulk Discount'

        expect(page).to have_content("Percent can't be blank, percent is not a number, bulk amount can't be blank, and bulk amount is not a number.")

        # Invalid percent (including non numbers)
        fill_in :discount_bulk_amount, with: bulk_amount[:valid]
        fill_in :discount_percent, with: percent[:too_high]
        click_button 'Create Bulk Discount'

        expect(page).to have_content("Percent must be less than 100.")
        expect(page).to have_field(:discount_percent, with: percent[:too_high])
        expect(page).to have_field(:discount_bulk_amount, with: bulk_amount[:valid])

        fill_in :discount_percent, with: percent[:too_low]
        click_button 'Create Bulk Discount'

        expect(page).to have_content("Percent must be greater than 0.")
        expect(page).to have_field(:discount_percent, with: percent[:too_low])
        expect(page).to have_field(:discount_bulk_amount, with: bulk_amount[:valid])

        fill_in :discount_percent, with: percent[:negative]
        click_button 'Create Bulk Discount'

        expect(page).to have_content("Percent must be greater than 0.")
        expect(page).to have_field(:discount_percent, with: percent[:negative])
        expect(page).to have_field(:discount_bulk_amount, with: bulk_amount[:valid])

        fill_in :discount_percent, with: percent[:letter]
        click_button 'Create Bulk Discount'

        expect(page).to have_content("Percent is not a number.")
        expect(page).to have_field(:discount_percent, with: percent[:letter])
        expect(page).to have_field(:discount_bulk_amount, with: bulk_amount[:valid])

        # Invalid bulk_amount (including non numbers)
        fill_in :discount_percent, with: percent[:valid]
        fill_in :discount_bulk_amount, with: bulk_amount[:too_low]
        click_button 'Create Bulk Discount'

        expect(page).to have_content("Bulk amount must be greater than 0.")
        expect(page).to have_field(:discount_percent, with: percent[:valid])
        expect(page).to have_field(:discount_bulk_amount, with: bulk_amount[:too_low])

        fill_in :discount_bulk_amount, with: bulk_amount[:negative]
        click_button 'Create Bulk Discount'

        expect(page).to have_content("Bulk amount must be greater than 0.")
        expect(page).to have_field(:discount_percent, with: percent[:valid])
        expect(page).to have_field(:discount_bulk_amount, with: bulk_amount[:negative])

        fill_in :discount_bulk_amount, with: bulk_amount[:letter]
        click_button 'Create Bulk Discount'

        expect(page).to have_content("Bulk amount is not a number.")
        expect(page).to have_field(:discount_percent, with: percent[:valid])
        expect(page).to have_field(:discount_bulk_amount, with: bulk_amount[:letter])
      end

      it "If I try to create a discount with the same percent, bulk_amount, or both, as another discount, I am returned to the form and see a message" do
        discount_1 = @merchant_1.discounts.create!(percent: 5, bulk_amount: 20)
        discount_2 = @merchant_2.discounts.create!(percent: 6, bulk_amount: 30)

        fill_in :discount_percent, with: discount_1.percent
        fill_in :discount_bulk_amount, with: discount_2.bulk_amount

        click_button 'Create Bulk Discount'

        expect(page).to have_content("A discount with this percent and/or bulk amount already exists.")

        fill_in :discount_percent, with: discount_1.percent
        fill_in :discount_bulk_amount, with: discount_1.bulk_amount

        click_button 'Create Bulk Discount'

        expect(page).to have_content("A discount with this percent and/or bulk amount already exists.")

        fill_in :discount_percent, with: discount_2.percent
        fill_in :discount_bulk_amount, with: discount_1.bulk_amount

        click_button 'Create Bulk Discount'

        expect(page).to have_content("A discount with this percent and/or bulk amount already exists.")

        fill_in :discount_percent, with: discount_2.percent
        fill_in :discount_bulk_amount, with: discount_2.bulk_amount

        click_button 'Create Bulk Discount'

        expect(current_path).to eq(merchant_discounts_path)
        expect(page).to_not have_content("A discount with this percent and/or bulk amount already exists.")
      end
    end
  end
end
