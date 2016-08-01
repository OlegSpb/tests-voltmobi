require 'rails_helper'

RSpec.describe Web::ApplicationController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }

  describe 'Проверка #current_user' do
    it "Должен вернуть nil, если не авторизован" do
      expect(controller.send(:current_user)).to eq(nil)
      expect(controller.send(:user_signed_in?)).to eq(false)
    end

    it "Должен вернуть юзера, если установлена переменная контроллера" do
      controller.instance_variable_set('@current_user', user)

      expect(controller.send(:current_user)).to eq(user)
      expect(controller.send(:current_user)).to_not eq(user2)
    end

    it "Должен загрузить юзера из БД по user_id сессии и вернуть его" do
      request.session[:user_id] = user.id

      expect(controller.send(:current_user)).to eq(user)
      expect(controller.send(:current_user)).to_not eq(user2)
    end
  end
end
