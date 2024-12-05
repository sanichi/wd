# Correct common human typos in old blogs.
#
# Orr, Mark(2100) => Orr, Mark (2100)
# Jorge , Blanko  => Jorge, Blanco
#
# These adjustments will be incorporated into validation for future blogs.
#
# development:                      ruby lib/misc/corrections.rb
# production:  RAILS_ENV=production ruby lib/misc/corrections.rb

require_relative "../../config/environment"

Rails.application.eager_load!

Blog.order(:id).all.each do |b|
  story_1 = b.story
  sumry_1 = b.summary

  story_2 = story_1&.gsub(/(\w)(\(\d{4}\))/, '\1 \2')&.gsub(/\s+,/, ',')
  sumry_2 = sumry_1&.gsub(/(\w)(\(\d{4}\))/, '\1 \2')&.gsub(/\s+,/, ',')
  
  if story_1 != story_2
    b.update_column(:story, story_2)
    puts "st#{b.id}"
  end

  if sumry_1 != sumry_2
    b.update_column(:summary, sumry_2)
    puts "su#{b.id}"
  end
end
