# Helper
def url(path, date, priority, freq="yearly")
  url = "https://wanderingdragonschess.club/#{path}"
  puts <<-EOL
  <url>
    <loc>#{url}</loc>
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

# Blogs, first those with tags and then the others.
url("blogs", last_blog, 0.9, "weekly")
Blog.where(draft: false).where.not(tag: nil).each do |b|
  url("blogs/#{b.tag}", b.updated_at.to_date, 0.9)
end
Blog.where(draft: false).where(tag: nil).each do |b|
  url("blogs/#{b.id}", b.updated_at.to_date, 0.8)
end

# Players
url("players", Player.pluck(:updated_at).max.to_date, 0.9, "monthly")
Player.all.each do |p|
  url("players/#{p.id}", p.updated_at.to_date, 0.8)
end

# Sign in
url("signin", "2019-10-26", 0.2)

# Finish XML
puts %Q(</urlset>)
