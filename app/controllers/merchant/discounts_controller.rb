class Merchant::DiscountsController < Merchant::BaseController
  def index
    @merchant = current_user.merchant
  end

  def new
    @discount = Discount.new
  end

  def create
    @discount = Discount.new(discount_params)
    if @discount.conflict?
      flash.now[:errors] = "A discount with this percent and/or bulk amount already exists."
      render :new
    elsif @discount.save
      redirect_to merchant_discounts_path
    else
      flash[:errors] = @discount.errors.full_messages.to_sentence.capitalize + '.'
      render :new
    end
  end

  def edit
    @discount = Discount.find(params[:id])
  end

  private
  def discount_params
    params.require(:discount).permit(:percent, :bulk_amount, :merchant_id)
  end
end
