require 'sinatra/base'
require 'padrino-helpers'
require 'data_mapper'
require 'course'
require 'user'
require 'pry'

class WorkshopApp < Sinatra::Base
  register Padrino::Helpers
  set :protect_from_csrf, true
  set :admin_logged_in, false

  env = ENV['RACK_ENV'] || 'development'
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/workshop_#{env}")
  DataMapper::Model.raise_on_save_failure = true
  DataMapper.finalize
  DataMapper.auto_upgrade!

  get '/' do
    erb :index
  end

  get '/courses/index' do
    @courses = Course.all
    erb :'courses/index'
  end

  get '/courses/create' do
    erb :'courses/create'
  end

  post '/courses/create' do
    Course.create(title: params[:course][:title], description: params[:course][:description])
    redirect 'courses/index'
  end

  get '/users/register' do
    erb :'users/register'
  end

  post '/users/create' do
    User.create(name: params[:user][:name], email: params[:user][:email], password_digest: params[:user][:password] )
    redirect '/'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
