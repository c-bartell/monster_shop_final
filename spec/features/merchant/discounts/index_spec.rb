require 'rails_helper'

describe 'Bulk Discounts Index Page:' do
  before :each do
    @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
    @merchant_2 = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
    @m_user = @merchant_1.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword')
    @ogre = @merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
    @giant = @merchant_1.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
    @hippo = @merchant_2.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 1 )
    @order_1 = @m_user.orders.create!(status: "pending")
    @order_2 = @m_user.orders.create!(status: "pending")
    @order_3 = @m_user.orders.create!(status: "pending")
    @order_item_1 = @order_1.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: false)
    @order_item_2 = @order_2.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: true)
    @order_item_3 = @order_2.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2, fulfilled: false)
    @order_item_4 = @order_3.order_items.create!(item: @giant, price: @giant.price, quantity: 2, fulfilled: false)
    @discount_1 = @merchant_1.discounts.create!(percent: 5, bulk_amount: 20)
    @discount_2 = @merchant_1.discounts.create!(percent: 10, bulk_amount: 40)
  end

  describe 'As a merchant employee' do
    before :each do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_user)
    end

    describe 'When I visit my bulk discounts index' do
      before :each do
        visit merchant_discounts_path
      end

      it 'I see a list of all bulk discounts for my merchant' do
        within '#discounts' do
          within "#discount-#{@discount_1.id}" do
            expect(page).to have_content("Discount #{@discount_1.id}:")
            expect(page).to have_content("#{@discount_1.percent}% off quantities of #{@discount_1.bulk_amount} or more for a single item.")
          end

          within "#discount-#{@discount_2.id}" do
            expect(page).to have_content("Discount #{@discount_2.id}:")
            expect(page).to have_content("#{@discount_2.percent}% off quantities of #{@discount_2.bulk_amount} or more for a single item.")
          end
        end
      end

      it 'I see a link to create a new bulk discount' do
        click_link("New Bulk Discount")

        expect(current_path).to eq(new_merchant_discount_path)
      end

      it 'Next to each discount, I see a link to edit that discount, which takes me to an edit discount form' do
        within "#discount-#{@discount_1.id}" do
          expect(page).to have_link('Edit Bulk Discount')
        end

        within "#discount-#{@discount_2.id}" do
          expect(page).to have_link('Edit Bulk Discount')
          click_link 'Edit Bulk Discount'
        end

        expect(current_path).to eq(edit_merchant_discount_path(@discount_2))
      end

      it 'Next to each discount, I see a link to delete that discount' do
        within "#discount-#{@discount_1.id}" do
          expect(page).to have_link('Delete Bulk Discount')
        end

        within "#discount-#{@discount_2.id}" do
          expect(page).to have_link('Delete Bulk Discount')
        end
      end
    end
  end
end
