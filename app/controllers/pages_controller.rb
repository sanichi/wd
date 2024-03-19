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
    # Read "pin" as "old" as this parameter is now being used in a different way than originally intended.
    # * pin/old = false => item is new (by default) and should be on home page (in last updated order)
    # * pin/old = true  => item is old (needs edit) and normally shouldn't be on home page
    @blogs = Blog.where(draft: false, pin: false).updated_des

    # However, if there are not many new ones, supplement with some old ones.
    if (count = Blog.where(draft: false, pin: false).count) < 5
      @blogs+= Blog.where(draft: false, pin: true).created_des.limit(5 - count)
    end
  end
end
