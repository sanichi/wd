# Helpers
def url(path, date, priority, freq="yearly")
  puts <<-EOL
  <url>
    <loc>https://wanderingdragonschess.club/#{path}</loc>
    <lastmod>#{date}</lastmod>
    <changefreq>#{freq}</changefreq>
    <priority>#{priority}</priority>
  </url>
  EOL
end

# Start XML
puts %Q(<?xml version="1.0" encoding="UTF-8"?>)
puts %Q(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">)

# Home page
last_blog = Blog.pluck(:updated_at).max.to_date
url("", last_blog, 1.0, "weekly")

# Blogs, first those with slugs and then the others.
url("blogs", last_blog, 0.9, "weekly")
Blog.where(draft: false).where.not(slug: nil).each do |b|
  url("blogs/#{b.slug}", b.updated_at.to_date, 0.9)
end
Blog.where(draft: false).where(slug: nil).each do |b|
  url("blogs/#{b.id}", b.updated_at.to_date, 0.8)
end

# Games
url("games", Game.pluck(:updated_at).max.to_date, 0.8, "weekly")
Game.all.each do |g|
  url("games/#{g.id}", g.updated_at.to_date, 0.4)
end

# Players
last_player = Player.pluck(:updated_at).max.to_date
url("players", last_player, 0.9, "monthly")
Player.all.each do |p|
  url("players/#{p.id}", p.updated_at.to_date, 0.8)
end

# Books
url("books", Book.pluck(:updated_at).max.to_date, 0.7, "monthly")
Book.all.each do |b|
  url("books/#{b.id}", b.updated_at.to_date, 0.3)
end

# Dragons
url("dragons", Dragon.pluck(:updated_at).max.to_date, 0.7, "yearly")

# Contacts
url("contacts", last_player, 0.9, "monthly")

# Help
url("help", "2019-11-04", 0.7)

# Sign in
url("signin", "2019-10-26", 0.2)

# Finish XML
puts %Q(</urlset>)
