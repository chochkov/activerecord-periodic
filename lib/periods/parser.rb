module Periods
  class Parser
    def self.[](text)
      text = text.strip.gsub(/\s+/, ' ')

      if matches = text.match(/^from(.+)until(.+)$/)
        return matches.captures.map { |match| Chronic.parse(match) }
      end

      if text =~ /^all|full$/i
        return nil
      end

      # correct for yesterday and today
      text = if text =~ /^yesterday$/i
          'the day 1 days ago'
        elsif text =~ /^today$/i
          'the day 0 days ago'
        else
          text
        end

      if t = text.match(/^the ((day)|(week)|(month)|(year)) (.+)$/) { Chronic.parse($6) }
        return [ t.send(:"beginning_of_#{$1}"), t.send(:"end_of_#{$1}") ]
      end

      text.gsub(/\s/, '').match(/^((last)|(next))(\d+)*((day)|(week)|(month)|(year))s?$/) do
        current_time = Time.now
        return(
          if $1 == 'last'
            [
              current_time.ago(($4 || 1).to_i.send($5)).send("beginning_of_#{$5}"),
              current_time.ago(1.send($5)).send("end_of_#{$5}")
            ]
          else
            [
              current_time.in(1.to_i.send($5)).send("beginning_of_#{$5}"),
              current_time.in(($4 || 1).to_i.send($5)).send("end_of_#{$5}"),
            ]
          end
        )
      end

      text.match(/^this ((day)|(week)|(month)|(year))$/) do
        current_time = Time.now
        return [ current_time.send("beginning_of_#{$1}"), current_time.send("end_of_#{$1}") ]
      end

      words = text.split
      count = words.grep(/\d+/).first.to_i
      span  = text.match(/\d+\s((second)|(minute)|(hour)|(day)|(week)|(month)|(year))/)
      span  = span && span[1]
      time_span = text.match(/the\s((day)|(week)|(month)|(year))/)
      time_span = time_span && time_span[1]
      position = if words.grep(/ago/).any?
          :"-"
        elsif words.grep(/after/).any?
          :"+"
        end

      if ! time_span.blank?
        start = Time.now.send(position, count.send(span)).send("beginning_of_#{time_span}")
        finish = start + 1.send(time_span)
        [ start, finish ]
      else
        Time.now.send(position, count.send(span))
      end
    end
  end
end

