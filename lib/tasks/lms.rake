namespace :lms do
  desc "Map LMS fixture IDs to event IDs for a season, e.g. bin/rails 'lms:fixtures[12]'"
  task :fixtures, [:season_id] => :environment do |_, args|
    season_id = args[:season_id].to_i
    unless LmsFixture::SEASONS.key?(season_id)
      known = LmsFixture::SEASONS.map { |id, name| "#{id} (#{name})" }.join(", ")
      abort "Usage: bin/rails 'lms:fixtures[SEASON_ID]'. Known seasons: #{known}"
    end

    existing = LmsFixture.where(season_id: season_id).count
    if existing > 0
      puts "Season #{season_id} (#{LmsFixture::SEASONS[season_id]}) already has #{existing} fixtures."
      abort "Not a terminal, so not overwriting." unless $stdin.tty?
      print "[q]uit or [o]verwrite? "
      abort "Quit, nothing changed." unless $stdin.gets.to_s.strip.downcase.start_with?("o")
    end

    begin
      counts = LmsFixture.import(season_id)
    rescue LmsApi::Error, LmsFixture::ImportError => e
      abort "#{e.message}. Nothing changed."
    end
    counts.each do |name, n|
      line = "#{name.ljust(LmsFixture::MAX_EVENT_NAME)} #{n} fixtures"
      line += "  WARNING: no #{LmsFixture::CLUB} teams in this division" if n.zero?
      puts line
    end
    puts "Stored #{counts.values.sum} fixtures for season #{season_id} (#{LmsFixture::SEASONS[season_id]})."
  end
end
