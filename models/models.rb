require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'
require 'dm-types'
require 'dm-validations'
require 'sinatra'
require 'bcrypt'

# => http://datamapper.org/docs/associations.html

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

class Base
  include DataMapper::Resource
  property :id, Serial
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date
end

class User < Base
  property :username, String, :length => 1..15
  property :email, String, :length => 6..125, :unique => true
  property :password, BCryptHash
  property :recover_password, String
  property :role, String, :default => 'user'
  has 1, :user_information # => (One-to-One)
  has 1, :user_media       # => (One-to-One)
  has n, :user_socials     # => has n and belongs_to (or One-To-Many)
  has n, :songs            # => has n and belongs_to (or One-To-Many)
  has n, :albums           # => has n and belongs_to (or One-To-Many)
end

class UserMedia
  include DataMapper::Resource
  property :profile_img_url, Text, :default => "profiles/default_profile.jpg", :lazy => false
  property :banner_img_url, Text, :default => "banners/default_banner.jpg", :lazy => false

  belongs_to :user, :key => true
end

class UserInformation
  include DataMapper::Resource
  property :display_name, String, :length => 2..50
  property :first_name, String, :length => 2..50
  property :last_name, String, :length => 2..50
  property :country, String, :length => 2..50
  property :city, String, :length => 2..50
  property :bio, Text, :length => 10..225

  belongs_to :user, :key => true
end

class UserSocial
  include DataMapper::Resource
  property :id, Serial
  property :url, Text
  property :name, String

  belongs_to :user
end

class Album
  # => Crear imagen default
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :date, Date
  property :likes, Integer, :default => 0
  property :album_img_url, Text, :default => "album/default_album.jpg", :lazy => false
  has n, :songs, :through => Resource
  has n, :comment_albums # => has n and belongs_to (or One-To-Many)
                         # => CommentSong ----> comment_songs
  belongs_to :user
end

class Song
  # => Crear imagen default
  include DataMapper::Resource
  property :id, Serial
  property :url_song, Text
  property :title, Text
  property :description, Text
  property :genre, String
  property :type, Enum[:original, :remix, :live, :recording, :demo, :work, :effect, :other], :default => :original
  property :license, Enum[:creative_commons, :all_right_reserved]
  property :replay, Integer, :default => 0
  property :likes, Integer, :default => 0
  property :album_img_url, Text, :default => "songs/default_song.png", :lazy => false
  has n, :albums, :through => Resource
  has n, :comment_songs # => has n and belongs_to (or One-To-Many)
                        # => CommentSong ----> comment_songs
  belongs_to :user
end

class CommentAlbum
  include DataMapper::Resource
  property :id, Serial
  property :text, String
  property :likes, Integer, :default => 0

  belongs_to :album
end

class CommentSong
  include DataMapper::Resource
  property :id, Serial
  property :text, String
  property :likes, Integer, :default => 0

  belongs_to :song
end

DataMapper.finalize.auto_upgrade!
