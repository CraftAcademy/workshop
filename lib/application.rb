require 'sinatra/base'
require 'sinatra/contrib/all'

class WorkshopApp < Sinatra::Base
  register Sinatra::Contrib
  set :admin_logged_in, false

  get '/' do
    erb :index
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
