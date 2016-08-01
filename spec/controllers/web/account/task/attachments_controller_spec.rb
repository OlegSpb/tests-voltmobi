require 'rails_helper'

RSpec.describe Web::Account::Task::AttachmentsController, type: :controller do

  shared_examples 'redirect_to new_account_session' do
    context 'When need authorization' do
      context 'then server' do
        it { expect(response).to redirect_to(new_account_session_path) }
      end
      context 'then flash[:error]' do
        it { expect(flash[:error]).to match('Need authorization!') }
      end
    end
  end

  shared_examples "успешный рендер темплейта" do
    context "then" do
      it { expect(response).to render_template(template_name) }
      it { expect(response).to have_http_status(200) }
    end
  end

  shared_examples 'redirect_to account_task' do
    context 'When success' do
      context 'then server' do
        it { expect(response).to redirect_to(account_task_path(task_id)) }
      end
    end
  end

  shared_examples "404 ошибка" do
    context "then" do
      it { expect(response).to render_template('web/not_found') }
      it { expect(response).to have_http_status(404) }
    end
  end


  let!(:user){ FactoryGirl.create(:user_with_tasks, tasks_count: 10) }
  let!(:admin){ FactoryGirl.create(:admin) }

  let(:template_name){ 'new' }


  describe 'GET #new' do

    before(:each) do
      request.session[:user_id] = user_id

      get :new, task_id: task_id
    end

    let(:user_id){ user.id }

    let(:task_id){ user.tasks.last.id }

    context 'as Guest.' do
      let(:user_id){ 0 }
      let(:task_id){ 0 }

      include_examples "redirect_to new_account_session"
    end

    context 'as User.' do
      include_examples "успешный рендер темплейта"
    end

    context 'as User with wrong task_id.' do
      let(:task_id){ 0 }

      include_examples "404 ошибка"
    end


    context 'as Admin.' do
      let(:user_id){ admin.id }

      include_examples "успешный рендер темплейта"
    end

    context 'as Admin with wrong task_id.' do
      let(:user_id){ admin.id }
      let(:task_id){ 0 }

      include_examples "404 ошибка"
    end
  end


  describe 'POST #create' do
    before(:each) do
      request.session[:user_id] = user_id

      post :create, task_id: task_id, task_attachment: attr
    end

    let(:user_id) { user.id }
    let(:task_id) { user.tasks.last.id }
    let(:attr)    { {file: ''} }

    context 'as Guest.' do
      let(:attr){ {file: ''} }
      let(:user_id){ 0 }

      include_examples "redirect_to new_account_session"
    end

    context 'as User with wrong params.' do
      let(:attr){ {file: ''} }

      include_examples "успешный рендер темплейта"
    end

    context 'as User.' do
      # Не работает О_о
      after(:each) { attachment.destroy }

      let(:attachment) do
        attachment = stub_model(TaskAttachment, attributes: attr)
        allow(TaskAttachment).to receive(:new).and_return(attachment)

        attachment
      end

      context 'When document uploaded' do
        let(:attr){
          {file: fixture_file_upload('files/doc.docx', 'application/bin')}
        }
        let(:task_id) do
          task = user.tasks.last
          @attachment = attachment

          task.id
        end

        context 'then' do
          context 'attachment.file.url' do
            it{ expect(attachment.file.url).not_to eq(nil) }
          end
          context 'attachment.file.url(:thumb)' do
            it{ expect(attachment.file.url(:thumb)).to eq(nil) }
          end
        end

        include_examples "redirect_to account_task"
      end

      context 'When image uploaded' do
        let(:attr){
          {file: fixture_file_upload('files/img.png', 'image/png')}
        }

        let(:task_id) do
          task = user.tasks.last
          @attachment = attachment

          task.id
        end

        context 'then' do
          context 'attachment.file.url' do
            it{ expect(attachment.file.url).not_to eq(nil) }
          end
          context 'attachment.file.url(:thumb)' do
            it{ expect(attachment.file.url(:thumb)).not_to eq(nil) }
          end
        end

        include_examples "redirect_to account_task"
      end
    end
  end
end
