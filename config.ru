require 'rubygems'
require File.join(File.dirname(__FILE__), 'lib/application.rb')
use Rack::Static, urls: ['/css', '/js', '/img', '/fonts'], root: 'assets'

run WorkshopApp