require 'capybara/cucumber'
require 'capybara/webkit'

Capybara.configure do |config|
  config.default_driver = :webkit
end

