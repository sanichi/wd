class PagesController < ApplicationController
  # see https://github.com/CanCanCommunity/cancancan/wiki/Non-RESTful-Controllers
  authorize_resource class: false

  def env
    dirs = `ls /home/sanichi/.passenger/native_support 2>&1`
    vers = dirs.scan(/\d*\.\d*\.\d*/)
    @passenger_version = vers.any? ? vers.last : "not found"
    vers = ActiveRecord::Base.connection.execute('select version();').values[0][0] rescue "oops"
    @postgres_version = vers.match(/(1[4-6]\.\d+)/)? $1 : "not found"
    @host = ENV["HOSTNAME"] || `hostname`.chop.sub(".local", "")
  end

  def home
    @blogs = Blog.where(draft: false, pin: true).updated_des
    @blogs+= Blog.where(draft: false, pin: false).created_des.limit(5)
  end
end
