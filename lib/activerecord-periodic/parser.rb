module ActiveRecord::Periodic
  class Parser
    attr_accessor :text

    def initialize(text)
      text = text.strip.gsub(/\s+/, ' ')

      # correct for yesterday and today
      @text =
        if text =~ /^yesterday$/i
          'the day 1 days ago'
        elsif text =~ /^today$/i
          'the day 0 days ago'
        elsif text =~ /^tomorrow$/i
          'the day after 1 day'
        else
          text
        end
    end

    class << self
      alias :[] :new
    end

    def parse
      match? && @parsed || raise(TextParsingError)
    end

    private

    def match?
      full? || from_until? || the? || last? || this? || by_words?
    end

    def full?
      !!
      if text =~ /^all|full$/i
        @parsed = [ MINUS_INFINITY, INFINITY ]
      end
    end

    def from_until?
      !!
      if matches = text.match(/^from(.+)until(.+)$/)
        @parsed = matches.captures.map { |match| Chronic.parse(match) }
      end
    end

    def the?
      t = text.match(/^the ((day)|(week)|(month)|(year)) (.+)$/) {
        Chronic.parse($6)
      }

      !!
      if t
        @parsed = [ t.send(:"beginning_of_#{$1}"), t.send(:"end_of_#{$1}") ]
      end
    end

    def last?
      regex = /^(the)?((last)|(next))(\d+)*((day)|(week)|(month)|(year))s?$/

      !!
      text.gsub(/\s/, '').match(regex) do
        current_time = Time.now
        @parsed =
          if $2 == 'last'
            [
              current_time.ago(($5 || 1).to_i.send($6)).send("beginning_of_#{$6}"),
              current_time.ago(1.send($6)).send("end_of_#{$6}")
            ]
          else
            [
              current_time.in(1.to_i.send($6)).send("beginning_of_#{$6}"),
              current_time.in(($5 || 1).to_i.send($6)).send("end_of_#{$6}"),
            ]
          end
      end
    end

    def this?
      !!
      text.match(/^this ((day)|(week)|(month)|(year))$/) do
        current_time = Time.now
        @parsed = [
          current_time.send("beginning_of_#{$1}"),
          current_time.send("end_of_#{$1}")
        ]
      end
    end

    def by_words?
      words = text.split
      count = words.grep(/\d+/).first.to_i
      span  = text.match(/\d+\s((second)|(minute)|(hour)|(day)|(week)|(month)|(year))/)
      span  = span && span[1]
      aggregate = text.match(/the\s((day)|(week)|(month)|(year))/)
      aggregate = aggregate && aggregate[1]

      return false unless aggregate && span

      position =
        if words.grep(/ago/).any?
          :"-"
        elsif words.grep(/after/).any?
          :"+"
        end

      start  = Time.now.send(position, count.send(span)).send("beginning_of_#{aggregate}")
      finish = start.send("end_of_#{aggregate}")
      !! @parsed = [ start, finish ]
    end
  end
end

