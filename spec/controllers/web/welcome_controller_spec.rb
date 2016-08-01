require 'rails_helper'

RSpec.describe Web::WelcomeController, type: :controller do

  shared_examples "успешный рендер темплейта" do
    context "then" do
      it do
        expect(response).to render_template(template_name)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET #index as user.' do
    let(:template_name){ 'index' }

    before(:each) { get :index }

    context 'When success' do
      include_examples "успешный рендер темплейта"
    end
  end
end
