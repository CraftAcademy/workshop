require 'capybara/cucumber'
require 'capybara/webkit'

Capybara.configure do |config|
  #config.run_server = true
  config.default_driver = :webkit
  #config.default_wait_time = 5
  #config.app_host = "file://localhost#{Dir.getwd}"
  #config.javascript_driver = :poltergeist
end

