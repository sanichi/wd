require 'mechanize'

def update?(type, old, new, count=1)
  if old == new
    puts "  #{type} #{old} (no change)"
    false
  elsif @continue
    true
  else
    print "  #{type} #{old} => #{new} update [Ynqc]? "
    case gets.chomp
    when /\Ac(ontinue)?\z/i
      @continue = true
    when "", /\Ay(es)?\z/i
      true
    when /\Ano?\z/i
      false
    when /\A(q(uit)?|e?x(it)?)\z/i
      puts "OK, I'm stopping"
      exit
    else
      if count < 3
        update?(type, old, new, count + 1)
      else
        puts "you're not making sense, I'm quitting"
        exit
      end
    end
  end
end

def abort(ctx, msg)
  puts "abort in context: #{ctx} with error: #{msg}"
  exit
end

def be_nice
  sleep 0.1
end

def fide_rating(id)
  begin
    be_nice
    page = @agent.get("https://ratings.fide.com/profile/#{id}")
    rating = page.xpath('.//div[contains(@class,"profile-top-rating-dataCont")]/div[contains(@class,"profile-top-rating-data") and span="std"]/text()')[1].text.squish.to_i
    raise "invalid rating #{rating}" unless rating > 0 && rating <= Player::MAX_RATING
    rating
  rescue StandardError => e
    abort("FIDE rating (ID #{id})", e.message)
  end
end

def sca_rating(id)
  rand(4000)
end

@agent = Mechanize.new

Player.by_rating.all.each do |p|
  puts p.name

  if p.fide_id.present? && p.fide_rating.present?
    old = p.fide_rating
    new = fide_rating(p.fide_id)
    p.update_column(:fide_rating, new) if update?("FIDE", old, new)
  end

  if p.sca_id.present? && p.sca_rating.present? && false
    old = p.sca_rating
    new = sca_rating(p.sca_id)
    p.update_column(:sca_rating, new) if update?("SCA", old, new)
  end
end
