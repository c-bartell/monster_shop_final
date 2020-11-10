class Merchant::DiscountsController < Merchant::BaseController
  def index
    @merchant = current_user.merchant
  end

  def new
    @discount = Discount.new
  end

  def create
    @discount = Discount.new(discount_params)
    validate_record(:new)
  end

  def edit
    discount
  end

  def update
    discount.update(discount_params)
    validate_record(:edit)
  end

  private
  def discount_params
    params.require(:discount).permit(:percent, :bulk_amount, :merchant_id)
  end

  def discount
    @discount ||= Discount.find(params[:id])
  end

  def validate_record(endpoint)
    if discount.save
      redirect_to merchant_discounts_path
    else
      flash[:errors] = discount.errors.full_messages.to_sentence.capitalize + '.'
      render endpoint
    end
  end
end
