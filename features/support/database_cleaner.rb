require 'database_cleaner'
require 'database_cleaner/cucumber'

DatabaseCleaner.strategy = :truncation

Around do |scenario, block|
  FileUtils.rm_rf Dir['pdf/test/**/*.pdf']
  FileUtils.rm_rf Dir['pdf/test/**/*.jpg']
  DatabaseCleaner.cleaning(&block)
end