class Merchant::DiscountsController < Merchant::BaseController
  def index
    @merchant = current_user.merchant
  end

  def new
    @discount = Discount.new
  end

  def create
    @discount = Discount.new(discount_params)
    if @discount.save
      redirect_to merchant_discounts_path
    else
      flash[:errors] = @discount.errors.full_messages.to_sentence.capitalize + '.'
      render :new
    end
  end

  def edit
    discount
  end

  def update
    discount.update(discount_params)
    redirect_to merchant_discounts_path
  end

  private
  def discount_params
    params.require(:discount).permit(:percent, :bulk_amount, :merchant_id)
  end

  def discount
    @discount ||= Discount.find(params[:id])
  end
end
