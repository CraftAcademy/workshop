require 'sinatra/base'
require 'padrino-helpers'
require './lib/course'

class WorkshopApp < Sinatra::Base
  register Padrino::Helpers
  set :protect_from_csrf, true
  set :admin_logged_in, false

  get '/' do
    erb :index
  end

  get '/courses/index' do
    erb :'courses/index'
  end

  get '/courses/create' do
    erb :'courses/create'
  end

  post '/courses/create' do
    # TODO: place Course creation code here:
    erb :'courses/index'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
