require "rubygems"
require "bundler/setup"
require "twitter"
require "wordnik"
require "awesome_print"

Wordnik.configure do |config|
  config.api_key = ENV['WORDNIK_API_KEY']
  config.username = ENV['WORDNIK_USERNAME']
  config.password = ENV['WORDNIK_PASSWORD']
  config.logger = Logger.new('/dev/null')
end

Wordnik.authenticate

class Search
  
  attr_accessor :results
  
  def initialize(options={})
    @results = []
    defaults = {
      lang: "en",
      result_type: "recent",
      rpp: 100
    }
    options = defaults.merge(options)

    1.upto(15) do |page|
      options[:page] = page
      Twitter.search("is not a word", options).each do |_|
        result = Result.new(_.text)
        @results << result if result.valid?
      end
    end
    
    @results
  end
  
  def outcasts
    # Reject the words with definitions!
    @outcasts ||= @results.reject{|_| _.has_dictionary_def? }
  end
  
  def outcasts_as_request_object
    outcasts.map do |_|
      {'word' => _.word}
    end
  end
  
end

class Result
  
  attr_accessor :text, :word, :outcast
  
  def initialize(text)
    self.text = text
    matches = self.text.scan(/\"?\'?([a-z|-]+)\"?\'? is not a word/i).flatten
    self.word = matches.first.downcase unless matches.empty?
  end
  
  def valid?
    word && word.size > 0
  end
  
  def has_dictionary_def?
    @has_dictionary_def ||= Wordnik.word.get_definitions(self.word, :limit => 1).size > 0
  end
    
end

class Reaper
  
  def self.run
    Wordnik.word_list.add_words_to_word_list(
      'outcasts',
      Search.new.outcasts_as_request_object,
      :username => Wordnik.configuration.username
    )
  end
  
end