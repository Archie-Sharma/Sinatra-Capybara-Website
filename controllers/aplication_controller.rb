Bundler.require
require 'sinatra/base'
require 'sinatra/flash'
require_relative '../models/models'

class ApplicationController < Sinatra::Base
  register Sinatra::Flash
  helpers Apphelpers

  # => config
  configure do
    enable :sessions
    enable :logging
    enable :show_exceptions
    set :template_engine, :erb
    set :views, 'views'
    set :public_folder, 'public'
    set :static, true
    set :static_cache_control, [:public, max_age: 0]
    set :session_secret, '1a2s3d4f5g6h7j8k9l'
  end


  configure :development do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
    set :email_address => 'smtp.gmail.com',
    :email_user_name => 'daz',
    :email_password => 'secret',
    :email_domain => 'localhost.localdomain'
  end

  configure :production do
    DataMapper.setup(:default, ENV['DATABASE_URL'])
    set :email_address => 'smtp.sendgrid.net',
    :email_user_name => ENV['SENDGRID_USERNAME'],
    :email_password => ENV['SENDGRID_PASSWORD'],
    :email_domain => 'heroku.com'
  end

  def send_message
    Pony.mail(
      :from => params[:name] + "<" + params[:email] + ">",
      :to => 'daz@gmail.com',
      :subject => params[:name] + " has contacted you",
      :body => params[:message],
      :port => '587',
      :via => :smtp,
      :via_options => {
        :address              => 'smtp.gmail.com',
        :port                 => '587',
        :enable_starttls_auto => true,
        :user_name            => 'email@gmail',
        :password             => 'password',
        :authentication       => :plain,
        :domain               => 'localhost.localdomain'
    })
  end

  not_found do
    render :erb, :'error/not_found'
  end

end
