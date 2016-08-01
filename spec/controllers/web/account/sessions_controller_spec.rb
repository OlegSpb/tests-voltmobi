require 'rails_helper'

RSpec.describe Web::Account::SessionsController, type: :controller do
  let(:user) { FactoryGirl.create(:user)}

  describe "GET #new" do
    it "Успешный ответ с 200м статусом" do
      get :new

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "Рендерится темплейт new" do
      get :new
      expect(response).to render_template("new")
    end

    it "Редирект в список тасков, если юзер авторизован" do
      allow(controller).to receive(:current_user).and_return(user)

      get :new

      expect(response).to redirect_to(account_tasks_path)
      expect(response).to have_http_status(302)

      expect(flash[:error]).to match('Already authorized!')
    end
  end

  describe  'POST #create' do
    it 'Рендерится темплейт new со статусом BAD_REQUEST, если аутентификация не удалась' do
      post :create, user: {email: '', password: ''}

      expect(response).to have_http_status(400)
      expect(response).to render_template("new")
    end

    it 'Редирект в список тасков, если юзер уже авторизован' do
      allow(controller).to receive(:current_user).and_return(user)

      post :create, user: {email: '', password: ''}

      expect(response).to redirect_to(account_tasks_path)
      expect(response).to have_http_status(302)

      expect(flash[:error]).to match('Already authorized!')
    end

    it 'Редирект при успешной аутентификации' do
      post :create, user: {email: user.email, password: user.email}

      expect(response).to redirect_to(account_tasks_path)
      expect(response).to have_http_status(302)
      expect(flash[:notice]).to match('Welcome!')
    end
  end

  describe 'DELETE #destroy' do
    it "Должен быть редирект на главную" do
      delete :destroy

      expect(response).to redirect_to(root_path)
      expect(response).to have_http_status(302)
    end

    it "Должен быть 200 ответ с Content-Type =  javascript от TurboLinks" do
      xhr :delete, :destroy

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(response.headers).to include("Content-Type" => match("text/javascript"))
    end
  end
end
