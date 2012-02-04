module Periods
  module Scopes
    def self.included(base)
      base.class_eval do
        scope :span, lambda { |*args|
          if args.first.kind_of? Hash
            args.first.inject(scoped) do |memo, pair|
              span = ::Periods::Span[pair.last]

              field = pair.first.class_variable_get("@@periods_field")

              memo.where(pair.first.arel_table[field].gteq(span.beginning.to_s(:db))).
                where(pair.first.arel_table[field].lt(span.end.to_s(:db)))
            end

          elsif args.first.kind_of?(String) && args.last.kind_of?(Hash)
            self.span(args.last.merge({ self => args.first }))

          elsif args.first.kind_of? String
            self.span(self => args.first)

          else
            raise ArgumentError.new "Use: .span(String), .span(Hash) or .span(String, Hash). Given: #{args.inspect}"
          end
        }
      end
    end
  end
end

