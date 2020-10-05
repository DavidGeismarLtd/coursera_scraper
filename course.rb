require 'httparty'
require 'nokogiri'
require 'pry-byebug'
require 'json'
require 'open-uri'
require 'csv'

module Coursera
  class Course
    attr_accessor(
      :link,
      :title,
      :tagline,
      :number_star_rating,
      :number_of_eval,
      :instructor_img,
      :instructor_name,
      :finaid,
      :metrics,
      :skills,
      :description,
      :applied_learning_project
    )
    def initialize(options={})
      options.each do |k, v|
        send("#{k}=", v)
      end
    end

    def to_hash
       self.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = self.instance_variable_get(var) }
    end

    def append(csv)
      csv << self.values
    end
  end
end
#
# CSV.open("data.csv", "w") do |csv|
#   csv << ["link", "title",
#     "tagline", "number_star_rating",
#     "number_of_eval", "instructor_img",
#     "instructor_name", "finaid", "metrics",
#     "skills", "description", "applied_learning_project"]
#   BASE = "https://fr.coursera.org"
#   link = "/browse/computer-science"
#   html = open("#{BASE}#{link}")
#   doc = Nokogiri::HTML(html)
#   elements = doc.css('.slick-slide a')
#   follow_links = elements.map { |element| element.attributes["href"].value }
#
#
#   follow_links.each do |link|
#     html = open("#{BASE}#{link}")
#     doc = Nokogiri::HTML(html)
#     unless doc.css(".banner-title").empty?
#       link = link
#       title = doc.css(".banner-title")&.text
#       tagline = doc.at("div[data-test='banner-title-container']")&.text
#       number_star_rating = doc.at("span[data-test='number-star-rating']")&.text
#       number_of_eval = doc.at("div.ratings-count-expertise-style")&.text
#       instructor_img = doc.at("div.instructor-count-display img")&.attributes["src"]&.value
#       instructor_name = doc.at("div.instructor-count-display span")&.text
#       #returns nil dont know why
#       finaid = doc.at("button[data-track-component='finaid']")&.text
#       # cant find all instances weird
#       metrics = doc.at('.rc-ProductMetrics')
#       skills = doc.search('.skills-sdp-content-exp span[title]').map { |item| item&.text }
#       description = doc.at('[data-e2e="description"]')&.text
#       applied_learning_project = doc.at('[data-e2e="applied-learning-project"]')&.text
#       csv << [link, title,
#         tagline, number_star_rating,
#         number_of_eval, instructor_img,
#         instructor_name, finaid, metrics,
#         skills, description, applied_learning_project]
#     else
#       next
#     end
#   end
# end
