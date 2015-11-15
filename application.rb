require 'sinatra/base'

class WorkshopApp < Sinatra::Base
  set :admin_logged_in, false

  get '/' do
    'Hello WorkshopApp!'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
