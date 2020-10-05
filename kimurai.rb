# infinite_scroll_spider.rb
require 'kimurai'
require 'pry-byebug'

class InfiniteScrollSpider < Kimurai::Base
  @name = "infinite_scroll_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://fr.coursera.org/browse/computer-science"]

  def parse(response, url:, data: {})
    courses_path = ".slick-slide a"
    elements = response.css(courses_path)
    follow_links = []
    follow_links.push(elements.map { |element| element.attributes["href"].value }).flatten
    count = follow_links.count
    loop do
      browser.execute_script("window.scrollBy(0,10000)") ; sleep 2
      response = browser.current_response
      elements = response.css(courses_path)
      binding.pry
      if count == new_count
        logger.info "> Pagination is done" and break
      else
        count = new_count
        logger.info "> Continue scrolling, current count is #{count}..."
      end
    end

    posts_headers = response.xpath(posts_headers_path).map(&:text)
    logger.info "> All posts from page: #{posts_headers.join('; ')}"
  end

  def extract_data(follow_links)
    follow_links.each do |link|
      html = open("#{BASE}#{link}")
      doc = Nokogiri::HTML(html)
      unless doc.css(".banner-title").empty?
        course = {
          link: link,
          title: doc.css(".banner-title")&.text,
          tagline: doc.at("div[data-test='banner-title-container']")&.text,
          number_star_rating: doc.at("span[data-test='number-star-rating']")&.text,
          number_of_eval: doc.at("div.ratings-count-expertise-style")&.text,
          instructor_img: doc.at("div.instructor-count-display img")&.attributes&.try(:[], :src)&.value,
          instructor_name: doc.at("div.instructor-count-display span")&.text,
          #returns nil dont know why
          finaid: doc.at("button[data-track-component='finaid']")&.text,
          # cant find all instances weird
          metrics: doc.at('.rc-ProductMetrics'),
          skills: doc.search('.skills-sdp-content-exp span[title]').map { |item| item&.text },
          description: doc.at('.description')&.text,
          applied_learning_project: doc.at('[data-e2e="applied-learning-project"]')&.text,
        }
        csv << course.values
      else
        next
      end
    end
  end
end

InfiniteScrollSpider.crawl!
