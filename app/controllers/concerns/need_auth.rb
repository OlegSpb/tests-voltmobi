module NeedAuth
  extend ActiveSupport::Concern

  included do
    before_action :check_access
  end

  private

  def check_access
    unless user_signed_in?
      flash[:error] = 'Need authorization!'

      redirect_to new_account_session_path and return
    end
  end
end