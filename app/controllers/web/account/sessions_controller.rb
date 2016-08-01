class Web::Account::SessionsController < Web::ApplicationController

  before_action :check_not_authorized, except: :destroy

  def new

  end

  def create
    @user_params = params.required(:user).permit('email', 'password')

    user = User.find_by_email(@user_params['email'])

    if user.present? && user.try(:authenticate, @user_params['password'])
      session[:user_id] = user.id

      flash[:notice] = 'Welcome!'
      redirect_to account_tasks_path and return
    end

    render action: :new, status: 400
  end

  def destroy
    reset_session

    redirect_to root_path
  end

  private

  def check_not_authorized
    if user_signed_in? && !current_user.new_record?

      flash[:error] = 'Already authorized!'
      redirect_to account_tasks_path
    end
  end

end
