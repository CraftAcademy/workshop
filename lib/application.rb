require 'sinatra/base'
require 'padrino-helpers'
require 'data_mapper'
require './lib/course'
require './lib/user'
require './lib/delivery'
require 'pry'

class WorkshopApp < Sinatra::Base
  register Padrino::Helpers
  set :protect_from_csrf, true
  enable :sessions
  set :session_secret, '11223344556677'

  env = ENV['RACK_ENV'] || 'development'
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/workshop_#{env}")
  DataMapper::Model.raise_on_save_failure = true
  DataMapper.finalize
  DataMapper.auto_upgrade!

  before do
    @user = User.get(session[:user_id]) unless is_user?
  end

  register do
    def auth(type)
      condition do
        restrict_access = Proc.new { session[:flash] = 'You are not authorized to access this page'; redirect '/' }
        restrict_access.call unless send("is_#{type}?")
      end
    end
  end

  helpers do
    def is_user?
      @user != nil
    end

    def current_user
      @user
    end
  end

  get '/' do
    erb :index
  end

  get '/courses/index' do
    @courses = Course.all
    erb :'courses/index'
  end

  get '/courses/create', auth: :user do
    erb :'courses/create'
  end

  post '/courses/create' do
    Course.create(title: params[:course][:title], description: params[:course][:description])
    redirect 'courses/index'
  end

  get '/courses/:id/add_date', auth: :user do
    @course = Course.get(params[:id])
    erb :'courses/add_date'
  end

  post '/courses/new_date', auth: :user do
    course = Course.get(params[:course_id])
    course.deliveries.create(start_date: params[:start_date])
    redirect 'courses/index'
  end

  get '/users/register' do
    erb :'users/register'
  end

  post '/users/create' do
    begin
      User.create(name: params[:user][:name],
                  email: params[:user][:email],
                  password: params[:user][:password],
                  password_confirmation: params[:user][:password_confirmation])
      session[:flash] = "Your account has been created, #{params[:user][:name]}"
      redirect '/'
    rescue
      session[:flash] = 'Could not register you... Check your input.'
      redirect '/users/register'
    end
  end

  get '/users/login' do
    erb :'users/login'
  end

  post '/users/session' do
    @user = User.authenticate(params[:email], params[:password])
    session[:user_id] = @user.id
    session[:flash] = "Successfully logged in  #{@user.name}"
    redirect '/'
  end

  get '/users/logout' do
    session[:user_id] = nil
    session[:flash] = 'Successfully logged out'
    redirect '/'
  end


  # start the server if ruby file executed directly
  run! if app_file == $0
end
