require 'rack/test'
require 'rubygems'
require 'rack/test'
require 'rspec'
require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'

Dir.glob('./{helpers,controllers,models}/*.rb').each {|file| require file }

module FormHelpers
  def selector string
    find :css, string # selector('#any_class').click
  end
  def submit_form
    find('button[type="submit"]').click
  end
end

Capybara.app = Rack::Builder.new do
  map('/assets') {  run ApplicationController.sprockets }
  map('/tracks') { run Rack::Directory.new("./tracks") }
  map('/music') { run MusicController }
  map('/auth') { run AuthController }
  map('/admin') { run AdminController }
  map('/') { run WebsiteController }
end.to_app

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.app_host = "http://localhost:8000"

Capybara.server_host = "localhost"

Capybara.server_port = "8000"

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include FormHelpers, :type => :feature
  config.expect_with :rspec do |c|
    c.syntax = :expect # expect vs should
  end
  config.include Capybara::DSL
  config.include Capybara::RSpecMatchers
end

=begin

Spec for controllers:      $ bundle exec rspec spec/spec_controller/file.rb
Spec for database models:  $ bundle exec rspec spec/spec_models/file.rb
Spec for any class:        $ bundle exec rspec spec/spec_class/file.rb

=end