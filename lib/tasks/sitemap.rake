# frozen_string_literal: true

namespace :sitemap do
  desc "Generate sitemap.xml"
  task generate: :environment do
    require "builder"

    host = ENV.fetch("SITEMAP_HOST", "https://waittimesni.schwadlabs.io")
    sitemap_path = Rails.public_path.join("sitemap.xml")

    xml = Builder::XmlMarkup.new(indent: 2)
    xml.instruct!

    sitemap = xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
      # Main pages
      %w[/ /dashboard /trends /compare /heatmap].each do |path|
        xml.url do
          xml.loc "#{host}#{path}"
          xml.changefreq "hourly"
          xml.priority(path == "/" ? "1.0" : "0.8")
        end
      end
    end

    File.write(sitemap_path, sitemap)
    puts "✅ Sitemap generated: #{sitemap_path}"
    puts "   URLs: #{sitemap.scan(/<url>/).count}"
  end

  desc "Generate gzipped sitemap"
  task generate_gzip: :generate do
    require "zlib"

    sitemap_path = Rails.public_path.join("sitemap.xml")
    gzip_path = Rails.public_path.join("sitemap.xml.gz")

    Zlib::GzipWriter.open(gzip_path) do |gz|
      gz.write File.read(sitemap_path)
    end

    puts "✅ Gzipped sitemap: #{gzip_path}"
    puts "   Size: #{File.size(gzip_path)} bytes"
  end
end
