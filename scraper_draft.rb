require 'httparty'
require 'nokogiri'
require 'pry-byebug'
require 'json'
require 'open-uri'

BASE = "https://fr.coursera.org"
link = "/browse/computer-science?page=3"
html = open("#{BASE}#{link}")
doc = Nokogiri::HTML(html)
elements = doc.css('.slick-slide a')
follow_links = elements.map { |element| element.attributes["href"].value }
binding.pry
follow_links
doc.css(".rc-ProductOfferings a")
# # titles = []
# follow_links.each do |link|
#   html = open("#{BASE}#{link}")
#   doc = Nokogiri::HTML(html)
#   unless doc.css(".banner-title").empty?
#     title = doc.css(".banner-title").text
#     tagline = doc.at("div[data-test='banner-title-container']").text
#     number_star_rating = doc.at("span[data-test='number-star-rating']").text
#     number_of_eval = doc.at("div.ratings-count-expertise-style").text
#     instructor_img = doc.at("div.instructor-count-display img").attributes["src"].value
#     instructor_name = doc.at("div.instructor-count-display span").text
#     #returns nil dont know why
#     finaid = doc.at("button[data-track-component='finaid']").text
#     # cant find all instances weird
#     metrics = doc.at('.rc-ProductMetrics')
#     skills = doc.search('.skills-sdp-content-exp span[title]').map(&:text)
#     description = doc.at('[data-e2e="description"]').text
#     applied_learning_project = doc.at('[data-e2e="applied-learning-project"]').text
#
#     titles.push title.text
#   else
#     next
#   end
# end
#
#
# html = open('https://fr.coursera.org/specializations/introduction-scripting-in-python')
# doc = Nokogiri::HTML(html)
# binding.pry
# doc
