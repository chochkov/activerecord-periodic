module Periods
  class ServiceHelpers
    # Given an ActiveRecord::Base subclass @param klass
    # return a default Datetime column to span on
    def self.fallback_column(klass)
      columns  = klass.columns.map(&:name)
      expected = [
        'created_at',
        'created_on',
        'updated_at',
        'updated_on'
      ]
      column = expected.select { |c| columns.include?(c) }.first
      column || raise(NoColumnGiven)
    end
  end
end

