module ActiveRecord::Periodic

  # The scopes from this module get included if `has_time_span_scopes`
  # gets called in an ActiveRecord model like:
  #
  #   Visit < ActiveRecord::Base
  #     has_time_span_scopes
  #   end
  #
  module DefaultScopes
    def self.included(klass)
      default_scope_name = klass.periods_default_scope_name

      if klass.respond_to?(default_scope_name)
        klass.singleton_class.class_eval do
          undef_method(default_scope_name)
        end
      end

      klass.scope default_scope_name, lambda { |*args|
        if args.first.kind_of?(Hash)
          args.first.inject(klass.where(nil)) do |memo, pair|
            span = ::ActiveRecord::Periodic::Span[pair.last]

            if span.finite?

              column =
                if pair.first.kind_of? Class
                  c = pair.first.periods_has_time_span_scopes_column
                  pair.first.arel_table[c]
                elsif pair.first.kind_of? Symbol
                  klass.arel_table[pair.first]
                else
                  raise ::ActiveRecord::Periodic::NoColumnGiven
                end

              memo.where(column.gteq(span.beginning.to_s(:db))).
                where(column.lt(span.end.to_s(:db)))
            else
              memo
            end
          end

        elsif args.first.kind_of?(String) && args.last.kind_of?(Hash)
          klass.send(default_scope_name, args.last.merge({ klass => args.first }))

        elsif args.first.kind_of?(String)
          klass.send(default_scope_name, klass => args.first)

        else
          raise ArgumentError.new <<-ERROR
            Expected: String, Hash or [ String, Hash ]. Got: #{args.inspect}"
          ERROR
        end
      }
    end
  end

  # If `:with_all_scopes => true` option is passed when including the extension like:
  #
  #   Visit < ActiveRecord::Base
  #     has_time_span_scopes :with_all_scopes => true
  #   end
  #
  #   Visit.today
  #   Visit.tomorrow
  #   Visit.last_month
  #   Visit.this_year
  #   Visit.next_week
  #
  # etc. become valid scopes serving as chainable shortcuts.
  #
  module OptionalScopes
    def self.included(klass)
      %w(year month week day).each do |period|
        %w(last this next).each do |pointer|
          name = "#{pointer}_#{period}"
          text = "#{pointer} #{period}"
          klass.scope name, klass.send(klass.periods_default_scope_name, text)
        end
      end

      %w(yesterday today tomorrow).each do |day|
        klass.scope day, klass.send(klass.periods_default_scope_name, day)
      end
    end
  end
end

