# Correct even more common typos in old blogs.
#
# zero or more spaces and a single newline between sentences => one space
#
# i.e. to take a new paragraph you need to enter two newlines
#
# These adjustments will be incorporated into validation for future blogs.
#
# development:                      ruby lib/misc/corrections3.rb
# production:  RAILS_ENV=production ruby lib/misc/corrections3.rb

require_relative "../../config/environment"

Rails.application.eager_load!

PAT = /([a-z])([.!?])([ ]*\n[ ]*|[ ]{2,})([A-Z])/
RPL = "\\1\\2 \\4"

Blog.order(:id).all.each do |b|
  old_story = b.story
  old_sumry = b.summary

  new_story = old_story&.gsub(PAT, RPL)
  new_sumry = old_sumry&.gsub(PAT, RPL)

  if new_sumry != old_sumry
    b.update_column(:summary, new_sumry)
    puts "sumry #{b.id}"
  end

  if new_story != old_story
    b.update_column(:story, new_story)
    puts "story #{b.id}"
  end
end
