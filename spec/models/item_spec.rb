require 'rails_helper'

RSpec.describe Item do
  describe 'Relationships' do
    it {should belong_to :merchant}
    it {should have_many :order_items}
    it {should have_many(:orders).through(:order_items)}
    it {should have_many :reviews}
  end

  describe 'Validations' do
    it {should validate_presence_of :name}
    it {should validate_presence_of :description}
    it {should validate_presence_of :image}
    it {should validate_presence_of :price}
    it {should validate_presence_of :inventory}
  end

  describe 'Instance Methods' do
    before :each do
      @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @xenomorph = @megan.items.create!(name: 'Xenomorph', description: "Pharyngeal jaws and acid blood!", price: 100, image: 'https://img.particlenews.com/img/id/3ZsdMI_0PFEZ9Ig00?type=thumbnail_512x288', active: true, inventory: 5 )
      @review_1 = @ogre.reviews.create(title: 'Great!', description: 'This Ogre is Great!', rating: 5)
      @review_2 = @ogre.reviews.create(title: 'Meh.', description: 'This Ogre is Mediocre', rating: 3)
      @review_3 = @ogre.reviews.create(title: 'EW', description: 'This Ogre is Ew', rating: 1)
      @review_4 = @ogre.reviews.create(title: 'So So', description: 'This Ogre is So so', rating: 2)
      @review_5 = @ogre.reviews.create(title: 'Okay', description: 'This Ogre is Okay', rating: 4)
      @discount_1 = @megan.discounts.create!(percent: 25, bulk_amount: 20)
      @discount_2 = @megan.discounts.create!(percent: 20, bulk_amount: 21)
      @discount_3 = @megan.discounts.create!(percent: 50, bulk_amount: 40)
      @discount_4 = @brian.discounts.create!(percent: 50, bulk_amount: 30)
    end

    it '.sorted_reviews()' do
      expect(@ogre.sorted_reviews(3, :desc)).to eq([@review_1, @review_5, @review_2])
      expect(@ogre.sorted_reviews(3, :asc)).to eq([@review_3, @review_4, @review_2])
      expect(@ogre.sorted_reviews).to eq([@review_3, @review_4, @review_2, @review_5, @review_1])
    end

    it '.average_rating' do
      expect(@ogre.average_rating.round(2)).to eq(3.00)
    end

    it '#bulk_price' do
      expect(@xenomorph.bulk_price(1)).to eq(@xenomorph.price)
      expect(@xenomorph.bulk_price(19)).to eq(@xenomorph.price)
      expect(@xenomorph.bulk_price(20)).to eq(@xenomorph.price * ((100 - @discount_1.percent) / 100.0))
      expect(@xenomorph.bulk_price(21)).to_not eq(@xenomorph.price * ((100 - @discount_2.percent) / 100.0))
      expect(@xenomorph.bulk_price(29)).to eq(@xenomorph.price * ((100 - @discount_1.percent) / 100.0))
      expect(@xenomorph.bulk_price(30)).to_not eq(@xenomorph.price * ((100 - @discount_4.percent) / 100.0))
      expect(@xenomorph.bulk_price(39)).to eq(@xenomorph.price * ((100 - @discount_1.percent) / 100.0))
      expect(@xenomorph.bulk_price(40)).to eq(@xenomorph.price * ((100 - @discount_3.percent) / 100.0))
      expect(@xenomorph.bulk_price(100)).to eq(@xenomorph.price * ((100 - @discount_3.percent) / 100.0))
      expect(@xenomorph.bulk_price(1_000_000)).to eq(@xenomorph.price * ((100 - @discount_3.percent) / 100.0))
    end

    it '#subtotal' do
      expect(@xenomorph.subtotal(1)).to eq(@xenomorph.price)
      expect(@xenomorph.subtotal(19)).to eq(19 * @xenomorph.price)
      expect(@xenomorph.subtotal(20)).to eq(20 * @xenomorph.price * ((100 - @discount_1.percent) / 100.0))
      expect(@xenomorph.subtotal(21)).to_not eq(21 * @xenomorph.price * ((100 - @discount_2.percent) / 100.0))
      expect(@xenomorph.subtotal(29)).to eq(29 * @xenomorph.price * ((100 - @discount_1.percent) / 100.0))
      expect(@xenomorph.subtotal(30)).to_not eq(30 * @xenomorph.price * ((100 - @discount_4.percent) / 100.0))
      expect(@xenomorph.subtotal(39)).to eq(39 * @xenomorph.price * ((100 - @discount_1.percent) / 100.0))
      expect(@xenomorph.subtotal(40)).to eq(40 * @xenomorph.price * ((100 - @discount_3.percent) / 100.0))
      expect(@xenomorph.subtotal(100)).to eq(100 * @xenomorph.price * ((100 - @discount_3.percent) / 100.0))
      expect(@xenomorph.subtotal(1_000_000)).to eq(1_000_000 * @xenomorph.price * ((100 - @discount_3.percent) / 100.0))
    end

    it '#bulk_discount' do
      expect(@xenomorph.bulk_discount(1)).to eq(nil)
      expect(@xenomorph.bulk_discount(19)).to eq(nil)
      expect(@xenomorph.bulk_discount(20)).to eq(@discount_1)
      expect(@xenomorph.bulk_discount(21)).to_not eq(@discount_2)
      expect(@xenomorph.bulk_discount(29)).to eq(@discount_1)
      expect(@xenomorph.bulk_discount(30)).to_not eq(@discount_4)
      expect(@xenomorph.bulk_discount(39)).to eq(@discount_1)
      expect(@xenomorph.bulk_discount(40)).to eq(@discount_3)
      expect(@xenomorph.bulk_discount(100)).to eq(@discount_3)
      expect(@xenomorph.bulk_discount(1_000_000)).to eq(@discount_3)
    end

    it '#discount' do
      expect(@xenomorph.discount(1)).to eq(nil)
      expect(@xenomorph.discount(19)).to eq(nil)
      expect(@xenomorph.discount(20)).to eq(@discount_1.percent)
      expect(@xenomorph.discount(21)).to_not eq(@discount_2.percent)
      expect(@xenomorph.discount(29)).to eq(@discount_1.percent)
      expect(@xenomorph.discount(30)).to_not eq(@discount_4.percent)
      expect(@xenomorph.discount(39)).to eq(@discount_1.percent)
      expect(@xenomorph.discount(40)).to eq(@discount_3.percent)
      expect(@xenomorph.discount(100)).to eq(@discount_3.percent)
      expect(@xenomorph.discount(1_000_000)).to eq(@discount_3.percent)
    end
  end

  describe 'Class Methods' do
    before :each do
      @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @nessie = @brian.items.create!(name: 'Nessie', description: "I'm a Loch Monster!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: false, inventory: 3 )
      @hippo = @brian.items.create!(name: 'Hippo', description: "I'm a Loch Monster!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: false, inventory: 3 )
      @gator = @brian.items.create!(name: 'Gator', description: "I'm a Loch Monster!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: false, inventory: 3 )
      @review_1 = @ogre.reviews.create(title: 'Great!', description: 'This Ogre is Great!', rating: 5)
      @review_2 = @ogre.reviews.create(title: 'Meh.', description: 'This Ogre is Mediocre', rating: 3)
      @review_3 = @ogre.reviews.create(title: 'EW', description: 'This Ogre is Ew', rating: 1)
      @review_4 = @ogre.reviews.create(title: 'So So', description: 'This Ogre is So so', rating: 2)
      @review_5 = @ogre.reviews.create(title: 'Okay', description: 'This Ogre is Okay', rating: 4)
      @user = User.create!(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword')
      @order_1 = @user.orders.create!
      @order_2 = @user.orders.create!
      @order_3 = @user.orders.create!
      @order_1.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2)
      @order_1.order_items.create!(item: @hippo, price: @hippo.price, quantity: 3)
      @order_2.order_items.create!(item: @hippo, price: @hippo.price, quantity: 5)
      @order_3.order_items.create!(item: @nessie, price: @nessie.price, quantity: 7)
      @order_3.order_items.create!(item: @gator, price: @gator.price, quantity: 1)
    end

    it '.active_items' do
      expect(Item.active_items).to eq([@ogre, @giant])
    end

    it '.by_popularity()' do
      expect(Item.by_popularity).to eq([@hippo, @nessie, @ogre, @gator, @giant])
      expect(Item.by_popularity(3, "ASC")).to eq([@giant, @gator, @ogre])
      expect(Item.by_popularity(3, "DESC")).to eq([@hippo, @nessie, @ogre])
    end
  end
end
