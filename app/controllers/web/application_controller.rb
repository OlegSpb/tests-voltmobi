class Web::ApplicationController < ApplicationController
  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :is_admin?

  private

  def current_user
    return @current_user if @current_user.present?

    if session[:user_id].present?
      @current_user ||= User.where(id: session[:user_id]).first
    end
  end

  def user_signed_in?
    current_user.present? ? true : false
  end

  def is_admin?
    user_signed_in? && current_user.role == 'admin'
  end

end
