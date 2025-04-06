require 'open-uri'
require 'json'
require 'time'
require 'redis'

class Crossword
  def initialize(crossword_data)
    @title = crossword_data.fetch('title')
    @source = crossword_data.fetch('source')
    @series = crossword_data.fetch('series')
    @identifier = crossword_data.fetch('identifier')
    @date = crossword_data.fetch('date')
  end

  attr_reader :title, :source, :series, :identifier

  def date
    return nil unless @date.present?
    (Time.xmlschema(@date).utc + 2.hours).to_date
  end

  def name
  return title if date.nil?

  formatted_time = date.strftime("%A %-d %b")
  if title.include?(' No ')
    number = title.split(' No ').last
    "#{formatted_time} (No #{number})"
  else
    formatted_time
  end
  end


 # commenting out old name method.
 # def name
 #   formatted_time = date.strftime("%A %-d %b")
 #   if title.include?(' No ')
 #     number = title.split(' No ').last
 #     "#{formatted_time} (No #{number})"
 #   else
 #     "#{formatted_time}"
 #   end
 # end

  def ==(other)
    other && other.instance_of?(Crossword) && other.identifier == self.identifier
  end

def to_json(*args)
  to_h.to_json(*args)
end

def save
  # Save individual crossword JSON
  individual_key = "crossword:#{self.source}:#{self.series}:#{self.identifier}"
  redis.set(individual_key, to_json)

  # Also maintain a list of recent crosswords per series
  list_key = "crossword-series-#{self.series}"
  crosswords = JSON.parse(redis.get(list_key) || '[]').map { |data| Crossword.new(JSON.parse(data)) }

  if crosswords.none? { |existing| existing == self }
    crosswords.unshift(self)
    redis.set(list_key, crosswords.take(5).map(&:to_json).to_json)
  end
end

#def save
#  key = "crossword-series-#{self.series}"
#
  # ✅ Parse Redis and convert each JSON string into a hash *first*
#  stored = JSON.parse(redis.get(key) || '[]')
#  crosswords = stored.map do |data|
    # Parse the JSON string *inside* the array if needed
#    data = JSON.parse(data) if data.is_a?(String)
#    Crossword.new(data)
#  end

#  unless crosswords.any? { |existing| existing == self }
#    crosswords.unshift(self)
#    # ✅ Save array of hashes, not array of JSON strings
#    redis.set(key, crosswords.take(5).map(&:to_h).to_json)
#  end
#end
  

def to_h
  {
    "title" => @title,
    "source" => @source,
    "series" => @series,
    "identifier" => @identifier,
    "date" => @date
  }
  end


  def redis
    @redis ||= Redis.new
  end

  # ✅ Class method to fetch a Guardian crossword and save it
  def self.fetch_from_source(series, identifier)
    raise "Unsupported series" unless %w[cryptic quick prize].include?(series)

    url = "https://www.theguardian.com/crosswords/#{series}/#{identifier}.json"
    puts "Fetching: #{url}"

    begin
      crossword_data = JSON.parse(URI.open(url).read)
      data = crossword_data["crossword"]
      return nil unless data
      puts "Got data: #{crossword_data.keys.join(', ')}"
    rescue => e
      puts "ERROR: #{e.class} - #{e.message}"
      return nil
    end
    
    crossword = Crossword.new({
      "title" => data["name"],
      "source" => "guardian",
      "series" => series,
      "identifier" => identifier,
      "date" => data["date"]
    })

    crossword.save
    crossword
  end
end

