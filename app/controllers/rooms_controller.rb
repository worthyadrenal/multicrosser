

class RoomsController < ApplicationController
  def show
    raise ActionController::RoutingError.new('Source not Found') unless params[:source] == 'guardian'
    raise ActionController::RoutingError.new('Series not Found') unless params[:series].in?(Series::SERIES)
    @crossword = crossword
    @parsed_crossword = JSON.parse(crossword)
    @url = url
  end

  def crossword_identifier
    [params[:source], params[:series], params[:identifier]].join('/')
  end
  helper_method :crossword_identifier

def crossword
  key = "crossword-series-#{params[:series]}"
  crosswords_json = Redis.new.get(key)
  raise ActionController::RoutingError.new("Crossword series not found") unless crosswords_json

  crosswords = JSON.parse(crosswords_json)
  crossword_data = crosswords.find { |c| c["identifier"] == params[:identifier] }

  raise ActionController::RoutingError.new("Crossword not found") unless crossword_data

  crossword_data.to_json
end


#  def crossword
#    if redis.exists(crossword_identifier)
#      redis.get(crossword_identifier)
#    else
#      get_crossword_data.tap {|data| redis.set(crossword_identifier, data) }
#    end
#  end

  def get_crossword_data
  url = "https://www.theguardian.com/crosswords/#{params[:series]}/#{params[:identifier]}.json"
  response = Faraday.get(url)

  raise ActionController::RoutingError.new('Not Found') unless response.success?

  json = JSON.parse(response.body)
  crossword = json["crossword"]

  raise ActionController::RoutingError.new('Crossword data missing') unless crossword

  crossword.to_json
end


#  def get_crossword_data
#    response = Faraday.get(url)
#    html = Nokogiri::HTML(response.body)
#    crossword_element = html.css('.js-crossword')
#    raise ActionController::RoutingError.new('Element not Found') unless crossword_element.any?
#    crossword_element.first['data-crossword-data']
#  end

  def url
    "https://www.theguardian.com/crosswords/#{params[:series]}/#{params[:identifier]}"
  end

  def redis
    @redis ||= Redis.new
  end
end
