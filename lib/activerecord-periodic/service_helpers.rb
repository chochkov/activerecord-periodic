module ActiveRecord::Periodic
  class ServiceHelpers
    # Given an ActiveRecord::Base subclass @param klass
    # return a default Datetime column to span on
    def self.fallback_column(klass)
      # if there's no column, be quiet at this stage
      columns  = klass.columns.map(&:name) rescue []
      expected = [
        'created_at',
        'created_on',
        'updated_at',
        'updated_on'
      ]
      column = expected.select { |c| columns.include?(c) }.first
      column
    end
  end
end
