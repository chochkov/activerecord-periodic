module ActiveRecord
  module Periods
    module Has
      def self.included(base)
        base.class_eval do
          def self.has_time_span_scopes(column = nil, opts = {})
            column =
              if column.nil?
                columns = self.columns.map(&:name)
                supported = [
                  'created_at',
                  'created_on',
                  'updated_at',
                  'updated_on'
                ]
                found = supported.select do |c|
                  columns.include?(c)
                end
                found.any? && found.first || raise(::Periods::NoColumnGiven)
              else
                column
              end

            self.class_variable_set("@@periods_field", column.to_sym)

            self.class_eval do
              include ::Periods::Scopes
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Periods::Has)

