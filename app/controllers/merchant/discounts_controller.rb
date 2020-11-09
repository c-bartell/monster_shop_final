class Merchant::DiscountsController < Merchant::BaseController
  def index
    @merchant = current_user.merchant
  end

  def new
    @discount = Discount.new
  end

  def create
    discount = current_user.merchant.discounts.new(discount_params)
    discount.save

    redirect_to merchant_discounts_path
  end

  private
  def discount_params
    params.require(:discount).permit(:percent, :bulk_amount)
  end
end
