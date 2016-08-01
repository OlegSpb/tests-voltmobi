require 'rails_helper'

RSpec.describe Web::Account::TasksController, type: :controller do

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

  shared_examples 'redirect_to account_tasks_path' do
    context 'then' do
      it { expect(response).to redirect_to(account_tasks_path) }
    end
  end

  shared_examples "должно вернуть 403 ошибку и 'web/forbidden'" do
    context 'When forbidden' do
      context 'then server' do
        it { expect(response).to render_template("web/forbidden") }
      end
      context 'then request' do
        it { expect(response).to have_http_status(403) }
      end
    end
  end

  shared_examples "должно вернуть 403 ошибку и 'Forbidden!'" do
    context 'When forbidden' do
      context 'then response.body' do
        it { expect(response.body).to eq("Forbidden!") }
      end
      context 'then request' do
        it { expect(response).to have_http_status(403) }
      end
    end
  end

  shared_examples "успешный рендер темплейта" do
    context "then" do
      it do
        expect(response).to render_template(template_name)
        expect(response).to have_http_status(200)
      end
    end
  end

  shared_examples 'eq @tasks' do
    context 'Controller private method load_tasks' do
      it { expect(controller.send(:load_tasks)).to eq(@tasks) }
    end
  end

  shared_examples 'not_eq @tasks' do
    context 'Controller private method load_tasks' do
      it { expect(controller.send(:load_tasks)).not_to eq(@tasks) }
    end
  end

  shared_examples 'eq @task' do
    context 'Controller private method loaded_task' do
      it { expect(controller.send(:loaded_task)).to eq(@task) }
    end
  end

  shared_examples 'not_eq @task' do
    context 'Controller private method loaded_task' do
      it { expect(controller.send(:loaded_task)).not_to eq(@task) }
    end
  end


  let(:user1){
    FactoryGirl.create(:user_with_tasks, tasks_count: 10)
  }
  let(:user1_tasks){
    user1.tasks
  }

  let(:user2){
    FactoryGirl.create(:user_with_tasks, tasks_count: 1)
  }

  let(:user3){
    FactoryGirl.create(:user_with_tasks, tasks_count: 1)
  }

  let(:user2_tasks){
    user2.tasks
  }

  let(:admin) do
    FactoryGirl.create_list(:user_with_tasks, 3, tasks_count: 10)
    FactoryGirl.create(:admin)
  end

  let(:admin_tasks){
    Task.all
  }

  describe 'GET #index as Guest' do

    before(:each) do
      get :index
    end

    include_examples 'redirect_to new_account_session'
  end

  describe 'GET #index as user.' do
    let(:template_name){ 'index' }

    before(:each) do
      request.session[:user_id] = user1.id
      @tasks = user1_tasks.reload
      get :index
    end

    context 'When success' do
      include_examples "успешный рендер темплейта"
    end

    include_examples "eq @tasks"
  end

  describe 'GET #index as admin' do
    let(:template_name){ 'index' }

    before(:each) do
      request.session[:user_id] = admin.id
      @tasks = admin_tasks.reload
      get :index
    end

    context 'When success' do
      include_examples "успешный рендер темплейта"
    end

    include_examples "eq @tasks"
  end



  describe 'GET #show as Guest' do

    before(:each) do
      get :show, id: user1_tasks.reload.first
    end

    include_examples 'redirect_to new_account_session'
  end

  describe 'GET #show fake Task as User ' do
    let(:template_name){ 'show' }

    before(:each) do
      request.session[:user_id] = user1.id

      @tasks = user1_tasks.reload
      @task = user2.tasks.reload.first

      get :show, id: @task.id
    end

    include_examples "должно вернуть 403 ошибку и 'web/forbidden'"
    include_examples 'not_eq @task'
  end

  describe 'GET #show as User' do
    let(:template_name){ 'show' }

    before(:each) do
      @tasks = user1_tasks.reload
      @task = @tasks.first
      request.session[:user_id] = user1.id

      get :show, id: @task.id
    end

    context 'When success' do
      include_examples "успешный рендер темплейта"
    end

    include_examples 'eq @task'
  end

  describe 'GET #show as Admin' do
    let(:template_name){ 'show' }

    before(:each) do
      request.session[:user_id] = admin.id

      @tasks = admin_tasks.reload
      @task = @tasks.first

      get :show, id: @task.id
    end

    context 'When success' do
      include_examples "успешный рендер темплейта"
    end

    include_examples 'eq @task'
  end





  shared_examples 'Guest' do
    let(:user_id){ 0 }
    let(:task){ user1_tasks.reload.last }
  end

  shared_examples 'sign_in user1 and get user1.tasks.last' do
    let(:user_id){ user1.id }
    let(:task) do
      FactoryGirl.create(:task, user: user1)
      user1_tasks.reload.last
    end
  end
  shared_examples 'sign_in user1 and get user2.tasks.last' do
    let(:user_id){ user1.id }
    let(:task) do
      FactoryGirl.create(:task, user: user2)

      user2_tasks.reload.last
    end
  end

  shared_examples 'sign_in admin and get user1.tasks.last' do
    let(:user_id){ admin.id }
    let(:task) do
      FactoryGirl.create(:task, user: user1)

      admin_tasks.reload.last
    end
  end



  shared_examples 'PATCH #update_state' do
    before(:each) do
      request.session[:user_id] = user_id
      patch :update_state, id: task.id, to: event
    end
  end

  shared_examples 'PATCH #update_state - wrong event name' do
    context 'When event is wrong' do
      context 'then response.body' do
        it { expect(response.body).to eq('Wrong event name!') }
      end
      context 'then request' do
        it { expect(response).to have_http_status(400) }
      end
    end
  end

  shared_examples 'PATCH #update_state - State not updated' do
    context 'When state not updated' do
      context 'then response.body' do
        it { expect(response.body).to eq('State not updated!') }
      end
      context 'then request' do
        it { expect(response).to have_http_status(403) }
      end
    end
  end



  describe 'PATCH #update_state as Guest.' do
    include_examples 'Guest'

    let(:event){ '' }

    include_examples 'PATCH #update_state'

    include_examples 'redirect_to new_account_session'
  end

  describe 'PATCH #update_state as User with wrong event.' do
    include_examples 'sign_in user1 and get user1.tasks.last'

    let(:event){ '' }

    include_examples 'PATCH #update_state'
    include_examples 'PATCH #update_state - wrong event name'
  end

  describe 'PATCH #update_state as User with "State not updated".' do
    include_examples 'sign_in user1 and get user1.tasks.last'

    let(:event){ 'restart' }

    include_examples 'PATCH #update_state'
    include_examples 'PATCH #update_state - State not updated'
  end

  describe 'PATCH #update_state as User with wrong user2 task.id.' do

    include_examples 'sign_in user1 and get user2.tasks.last'

    let(:event){ '' }

    include_examples 'PATCH #update_state'
    include_examples "должно вернуть 403 ошибку и 'web/forbidden'"
  end

  describe 'PATCH #update_state as User with success.' do

    include_examples 'sign_in user1 and get user1.tasks.last'

    let(:event)         { 'start' }
    let(:template_name) { 'update_state' }

    include_examples 'PATCH #update_state'

    context 'When success' do
      include_examples "успешный рендер темплейта"
    end
  end

  describe 'PATCH #update_state as Admin with wrong task.id.' do

    include_examples 'sign_in admin and get user1.tasks.last'

    let(:event) { '' }
    let(:task)  { Task.new(id: -1) }

    include_examples 'PATCH #update_state'
    include_examples "должно вернуть 403 ошибку и 'web/forbidden'"
  end

  describe 'PATCH #update_state as Admin with success.' do

    include_examples 'sign_in admin and get user1.tasks.last'

    let(:event){
      'start'
    }

    let(:template_name){
      'update_state'
    }

    include_examples 'PATCH #update_state'
    context 'When success' do
      include_examples "успешный рендер темплейта"
    end
  end



  shared_examples 'GET #edit' do
    before(:each) do
      request.session[:user_id] = user_id
      get :edit, id: task.id
    end
  end

  shared_examples 'XHR GET #edit' do
    before(:each) do
      request.session[:user_id] = user_id
      xhr :get, :edit, id: task.id
    end
  end

  describe 'GET #edit as Guest.' do
    include_examples 'Guest'

    include_examples 'GET #edit'

    include_examples 'redirect_to new_account_session'
  end

  describe 'GET #edit as User with wrong user2 task.id.' do

    include_examples 'sign_in user1 and get user2.tasks.last'

    include_examples 'GET #edit'
    include_examples "должно вернуть 403 ошибку и 'web/forbidden'"
  end
  describe 'GET #edit as User with wrong user2 task.id(xhr).' do

    include_examples 'sign_in user1 and get user2.tasks.last'

    include_examples 'XHR GET #edit'
    include_examples "должно вернуть 403 ошибку и 'Forbidden!'"
  end

  describe 'GET #edit as User with success.' do

    include_examples 'sign_in user1 and get user1.tasks.last'

    let(:template_name){ 'edit' }

    include_examples 'GET #edit'
    context 'When success' do
      include_examples "успешный рендер темплейта"
    end
  end

  describe 'GET #edit as Admin with wrong task.id.' do
    include_examples 'sign_in admin and get user1.tasks.last'

    let(:task){ Task.new(id: -1) }

    include_examples 'GET #edit'
    include_examples "должно вернуть 403 ошибку и 'web/forbidden'"
  end

  describe 'GET #edit as Admin with success.' do

    include_examples 'sign_in admin and get user1.tasks.last'

    let(:template_name){ 'edit' }

    include_examples 'GET #edit'
    context 'When success' do
      include_examples "успешный рендер темплейта"
    end
  end





  shared_examples 'PATCH #update' do
    let(:attr) do
      { name: 'new title', description: 'new description' }
    end

    before(:each) do
      request.session[:user_id] = user_id
      put :update, id: task.id, task: attr

      task.reload
    end
  end

  shared_examples 'task успешно создан или обновлен' do
    context 'When success,' do
      context 'user' do
        it { expect(response).to redirect_to(account_task_path(task)) }
      end

      context 'task.name' do
        it { expect(task.name).to eql(attr[:name]) }
      end

      context 'task.description' do
        it { expect(task.description).to eql(attr[:description]) }
      end
    end
  end


  describe 'PATCH #update as Guest.' do
    include_examples 'Guest'

    include_examples 'PATCH #update'

    include_examples 'redirect_to new_account_session'
  end


  describe 'PATCH #update as User with wrong user2 task.id.' do
    include_examples 'sign_in user1 and get user2.tasks.last'

    include_examples 'PATCH #update'

    include_examples "должно вернуть 403 ошибку и 'web/forbidden'"
  end

  describe 'PATCH #update as User with success.' do

    include_examples 'sign_in user1 and get user1.tasks.last'

    include_examples 'PATCH #update'

    let(:attr) do
      { name: 'new title', description: 'new description', user_id: user2.id }
    end

    include_examples 'task успешно создан или обновлен'

    context 'When role is "user"' do
      context 'task.user_id' do
        it do
          expect(task.user_id).to eql(user_id)
          expect(task.user_id).not_to eql(attr[:user_id])
        end
      end
    end
  end

  describe 'PATCH #update as User with errors.' do
    include_examples 'sign_in user1 and get user1.tasks.last'

    include_examples 'PATCH #update'

    let(:template_name){ 'edit' }

    let(:attr) do
      { name: '', description: 'new description' }
    end

    context 'When not updated' do
      include_examples "успешный рендер темплейта"
    end

  end


  describe 'PATCH #update as Admin with success.' do

    include_examples 'sign_in admin and get user1.tasks.last'

    include_examples 'PATCH #update'

    let(:attr) do
      { name: 'new title', description: 'new description', user_id: user2.id }
    end

    include_examples 'task успешно создан или обновлен'
  end

  describe 'PATCH #update as Admin with success (2).' do

    include_examples 'sign_in admin and get user1.tasks.last'

    include_examples 'PATCH #update'

    let(:attr) do
      { name: 'new title', description: 'new description' }
    end

    include_examples 'task успешно создан или обновлен'
  end

  describe 'PATCH #update as Admin with errors.' do
    include_examples 'sign_in admin and get user1.tasks.last'

    include_examples 'PATCH #update'

    let(:template_name){ 'edit' }

    let(:attr) do
      { name: 'new title', description: 'new description', user_id: 0 }
    end

    context 'When have errors' do
      include_examples "успешный рендер темплейта"
    end
  end

  describe 'PATCH #update as Admin with errors (2).' do
    include_examples 'sign_in admin and get user1.tasks.last'

    include_examples 'PATCH #update'

    let(:template_name){ 'edit' }

    let(:attr) do
      { name: '', description: 'new description' }
    end

    context 'When have errors' do
      include_examples "успешный рендер темплейта"
    end
  end






  shared_examples 'DELETE #destroy' do
    before(:each) do
      request.session[:user_id] = user_id
      delete :destroy, id: task.id
    end
  end


  describe 'DELETE #destroy as Guest.' do
    include_examples 'Guest'

    include_examples 'DELETE #destroy'

    include_examples 'redirect_to new_account_session'
  end


  describe 'DELETE #destroy as User with wrong user2 task.id.' do
    include_examples 'sign_in user1 and get user2.tasks.last'

    include_examples 'DELETE #destroy'

    include_examples "должно вернуть 403 ошибку и 'web/forbidden'"
  end

  describe 'DELETE #destroy as User with success.' do
    include_examples 'sign_in user1 and get user1.tasks.last'

    include_examples 'DELETE #destroy'

    include_examples 'redirect_to account_tasks_path'
  end


  describe 'DELETE #destroy as Admin with wrong task.id.' do
    include_examples 'sign_in admin and get user1.tasks.last'

    let(:task){ Task.new(id: -1) }

    include_examples 'DELETE #destroy'

    include_examples "должно вернуть 403 ошибку и 'web/forbidden'"
  end

  describe 'DELETE #destroy as Admin with success.' do
    include_examples 'sign_in admin and get user1.tasks.last'

    include_examples 'DELETE #destroy'

    include_examples 'redirect_to account_tasks_path'
  end





  shared_examples 'GET #new' do
    before(:each) do
      request.session[:user_id] = user_id
      get :new
    end
  end

  describe 'GET #new as Guest.' do
    include_examples 'Guest'

    include_examples 'GET #new'

    include_examples 'redirect_to new_account_session'
  end

  describe 'GET #new as User.' do
    include_examples 'sign_in user1 and get user1.tasks.last'

    include_examples 'GET #new'

    let(:template_name){ 'new' }

    context 'When ok' do
      include_examples "успешный рендер темплейта"
    end
  end

  describe 'GET #new as Admin.' do
    include_examples 'sign_in admin and get user1.tasks.last'

    include_examples 'GET #new'

    let(:template_name){ 'new' }

    context 'When ok' do
      include_examples "успешный рендер темплейта"
    end
  end





  shared_examples 'POST #create' do
    let(:attr) do
      { name: 'new title', description: 'new description' }
    end

    let(:task)do
      task = stub_model(Task, attributes: attr)
      task
    end

    before(:each) do
      request.session[:user_id] = user_id
      allow(Task).to receive(:new).and_return(task)

      post :create, task: attr
    end
  end

  shared_examples 'перепроверяем параметры модели' do
    context '"task.valid?"' do
      it{ expect(task.valid?).to eq(true) }
    end

    context '"task.user_id"' do
      it{ expect(task.user_id).to eq(attr[:user_id]) }
    end
    context '"task.name"' do
      it{ expect(task.name).to eq(attr[:name]) }
    end
    context '"task.description"' do
      it{ expect(task.description).to eq(attr[:description]) }
    end
  end


  describe 'POST #create as Guest.' do
    include_examples 'Guest'

    include_examples 'POST #create'

    include_examples 'redirect_to new_account_session'
  end


  describe 'POST #create as User.' do
    include_examples 'sign_in user1 and get user1.tasks.last'

    include_examples 'POST #create'
    let(:attr) do
      { name: 'new title', description: 'new description', user_id: user_id }
    end

    include_examples 'task успешно создан или обновлен'

    context 'When success,' do
      include_examples 'перепроверяем параметры модели'
    end
  end

  describe 'POST #create as User with errors.' do
    include_examples 'sign_in user1 and get user1.tasks.last'

    include_examples 'POST #create'

    let(:template_name){ 'new' }

    let(:attr) do
      { name: '', description: 'new description' }
    end

    context 'When not created' do

      include_examples "успешный рендер темплейта"

      context '"valid?"' do
        it{ expect(task.valid?).to eq(false) }
      end
    end

  end


  describe 'POST #create as Admin with success.' do

    include_examples 'sign_in admin and get user1.tasks.last'

    include_examples 'POST #create'

    let(:attr) do
      { name: 'new title', description: 'new description', user_id: user2.id }
    end

    include_examples 'task успешно создан или обновлен'

    context 'When success,' do
      include_examples 'перепроверяем параметры модели'
    end
  end

  describe 'POST #create as Admin with errors.' do
    include_examples 'sign_in admin and get user1.tasks.last'

    include_examples 'POST #create'

    let(:template_name){ 'new' }

    let(:attr) do
      { name: 'new title', description: 'new description' }
    end

    context 'When not created' do
      include_examples "успешный рендер темплейта"

      context '"valid?"' do
        it{ expect(task.valid?).to eq(false) }
      end
    end
  end

  describe 'POST #create as Admin with errors (2).' do
    include_examples 'sign_in admin and get user1.tasks.last'

    include_examples 'POST #create'

    let(:template_name){ 'new' }

    let(:attr) do
      { name: '', description: 'new description', user_id: user2.id }
    end

    context 'When not created' do
      include_examples "успешный рендер темплейта"

      context '"valid?"' do
        it{ expect(task.valid?).to eq(false) }
      end
    end
  end

end
