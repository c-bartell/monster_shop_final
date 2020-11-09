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
        expect(page).to have_field(:percent)
        expect(page).to have_field(:bulk_amount)
        expect(page).to have_button(:create_discount)
      end

      # After test for working form and create action, add sad path for invalid :percent and :bulk_amount, flash messages, form remaining filled out
    end
  end
end
