require 'httparty'
require 'nokogiri'
require 'pry-byebug'
require 'json'
require 'open-uri'
require 'csv'
require 'active_support/core_ext/object/try'
require './course.rb'

# :link,
# :title,
# :tagline,
# :number_star_rating,
# :number_of_eval,
# :instructor_img,
# :instructor_name,
# :finaid,
# :metrics,
# :skills,
# :description,
# :applied_learning_project
csv_text = File.read('./data.csv')
csv = CSV.parse(csv_text, :headers => true)
courses = []
csv.each do |row|
  courses.push Coursera::Course.new(row)
end

description_nil = courses.select { |course| course.description == nil }
tagline_nil = courses.select { |course| course.tagline == nil }
title_nil = courses.select { |course| course.title == nil }
binding.pry
title_nil
