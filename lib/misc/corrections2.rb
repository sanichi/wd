# Correct more common typos in old blogs.
#
# 1) tab                => space
# 2) space(s) + newline => newline
#
# These adjustments will be incorporated into validation for future blogs.
#
# development:                      ruby lib/misc/corrections2.rb
# production:  RAILS_ENV=production ruby lib/misc/corrections2.rb

require_relative "../../config/environment"

Rails.application.eager_load!

Blog.order(:id).all.each do |b|
  old_story = b.story
  old_sumry = b.summary

  new_story = old_story&.gsub(/\t/, " ")&.gsub(/[ ]+\n/, "\n")
  new_sumry = old_sumry&.gsub(/\t/, " ")&.gsub(/[ ]+\n/, "\n")

  if new_sumry != old_sumry
    b.update_column(:summary, new_sumry)
    puts "sumry #{b.id}"
  end

  if new_story != old_story
    b.update_column(:story, new_story)
    puts "story #{b.id}"
  end
end
