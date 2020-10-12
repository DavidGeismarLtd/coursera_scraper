# infinite_scroll_spider.rb
require 'kimurai'
require 'pry-byebug'

class InfiniteScrollSpider < Kimurai::Base
  @name = "infinite_scroll_spider"
  @engine = :selenium_chrome
  # change start uri https://fr.coursera.org/browse
  @start_urls = ["https://fr.coursera.org/browse"]
  BASE_URI = "https://www.coursera.org"

  def parse(response, url:, data: {})
    follow_topics.each do |topic|
      #on courses page
      base_courses_uri = "#{BASE_URI}#{topic}"
      browser.visit(base_courses_uri)
      response = browser.current_response
      # extracting base
      extract_links(follow_links(response))
      # extracting pages
      (2..3).each do |page_num|
        browser.visit("#{base_courses_uri}?page=#{page_num}")
        response = browser.current_response
        extract_links(follow_links(response))
      end
      course_links = follow_links(browser.current_response)
      extract_links(course_links)
    end
  end


  def follow_topics
    response = browser.current_response
    topic_paths = '[data-click-key="browse.browse.click.explore_domains_card"]'
    elements = response.css(topic_paths)
    elements.map { |element| element.attributes["href"].value }
  end

  def follow_links(response)
    courses_path = ".slick-slide a"
    elements = response.css(courses_path)
    elements.map { |element| element.attributes["href"].value }
  end

  def extract_links(follow_links)
    follow_links.each do |link|
      link = "#{BASE_URI}#{link}"
      browser.visit(link)
      sleep 2
      response = browser.current_response
      extract_link(response, link)
    end
  end

  def extract_link(response, link)

    resource =
      if link.include?("degree")
        extract_degree(response, link)
      else
        extract_general(response, link)
      end
    binding.pry

    save_to "scraped_coursera.json", resource, format: :pretty_json, position: true
  end

  def extract_degree(response, link)

    degree_data = base_data(response, link)
    ["admissions", "academics", "student-experience", "careers", "about"].each do |degree_feature|
      browser.visit("#{link}/#{degree_feature}")
      response = browser.current_response
      degree_data.merge!(send("#{degree_feature.gsub('-', '_')}_data", response, link))
    end
    degree_data
  end


  def base_data(response, link)
    {
      training_type: "degree",
      link: link,
      title: response.css(".page-title")&.text,
      tagline: response.at(".programHighlights > h2")&.text,
      description: response.at(".programHighlights")&.text,
      feature_at_a_glance: response.at(".rc-AtAGlance")&.text,
      deadline_info: response.at(".finalDeadlineInfo")&.text,
    }
  end

  def admissions_data(response, link)
    {
      programAudience: response.at(".programAudience")&.text,
      applicationProcess: response.at(".programAudience")&.text,
      FinancialSection: response.at(".rc-FinancialSection")&.text
    }
  end

  def academics_data(response, link)
    {
      curriculum: response.at(".curriculum")&.text,
      programLength: response.at(".programLength")&.text,
      programFlexibility: response.at(".programFlexibility")&.text,
    }

  end

  def student_experience_data(response, link)
    {
      programBenefitsOverview: response.at(".programBenefitsOverview")&.text,
      studentExperienceHighlights: response.at(".rc-StudentExperienceHighlights")&.text,
    }
  end

  def careers_data(response, link)
    {
      career_outcome: response.at(".career-outcome")&.text,
      career_services: response.at(".career-services")&.text
    }
  end

  def about_data(response, link)
    {
      about: response.at(".rc-AboutCard")&.text
    }
  end
  def extract_general(response, link)
      {
        link: link,
        title: response.css(".banner-title")&.text || response.css(".page-title"),
        tagline: response.at("div[data-test='banner-title-container']")&.text || response.at(".programHighlights > h2")&.text,
        number_star_rating: response.at("span[data-test='number-star-rating']")&.text&.delete("stars") || response.at('.XDPRating span')&.text&.delete("stars"),
        number_of_eval: response.at("div.ratings-count-expertise-style")&.text || response.at('.rc-RatingLink')&.text,
        expertise_score: response.at(".expertise-rating-item__score")&.text,
        main_instructor_img: response.at("div.instructor-count-display img")&.attributes&.try(:[], 'src')&.value || response.at('.banner-instructor-info img')&.attributes&.try(:[], 'src')&.value,
        main_instructor_name: response.at("div.instructor-count-display span")&.text ||  response.at('.banner-instructor-info span')&.text,
        #returns nil dont know why
        finaid: response.at(".finaid-link")&.text,
        # cant find all instances weird
        metrics: response.at('.rc-ProductMetrics')&.text,
        skills: response.search('.Skills span[title]').map { |item| item&.text },
        description: response.at('.description')&.text,
        applied_learning_project: response.at('[data-e2e="applied-learning-project"]')&.text,
        LearnerOutcomes: response.at('.LearnerOutcomes__container')&.text,
        ProductGlance: response.at('.ProductGlance')&.text,
        instructors: response.at('.rc-InstructorListSection')&.text,
      }
    # end
  end

  def title_present?
    response.css(".banner-title") || response.css(".page-title")
  end
end

InfiniteScrollSpider.crawl!
