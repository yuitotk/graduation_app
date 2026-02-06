class InquiriesController < ApplicationController
  before_action :require_login

  def new
    @inquiry = current_user.inquiries.build
  end

  def confirm
    @inquiry = current_user.inquiries.build(inquiry_params)
    if @inquiry.valid?
      render :confirm
    else
      render :new, status: :unprocessable_entity
    end
  end

  def create
    @inquiry = current_user.inquiries.build(inquiry_params)
    if @inquiry.save
      redirect_to done_inquiries_path, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def done; end

  private

  def inquiry_params
    params.require(:inquiry).permit(:name, :email, :body)
  end
end
