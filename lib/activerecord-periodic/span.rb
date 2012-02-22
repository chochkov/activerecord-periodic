# This is a basic Span object that lets us do things like:
#
#   Examples:
#
#   Span['this year'].monthly do |month|
#     # month is a Span object representing each month of the year
#     # do something with it - like subperiodic reporting, time breakdowns, etc
#   end
#
#   Span['the last 3 months'].weekly do |week|
#     Aggregation.new(week).save
#     # or do something meaningful in your own context
#   end
#
# This lacks some handy methods and offers place for extension in next versions.
# For exmaple, it'd be cool to have Span['last week'].week? or cweek delegation,
# etc.
#
module ActiveRecord::Periodic
  class Span
    include Comparable # by length
    attr_accessor :beginning, :end

    def initialize(*args)
      args = args.flatten

      @beginning, @end =
        if args.size == 2 && args.all? { |a| a.kind_of?(Time) }
          [ args.first, args.last ]
        elsif (text = args.first).kind_of?(String)
          Parser[text].parse
        end
    end

    class << self
      alias :[] :new
    end

    # if the span is finite or not
    def finite?
      ! infinite?
    end

    # if the span is inifinte or not
    def infinite?
      @beginning == MINUS_INFINITY || @end == INFINITY
    end

    # if self and other have intersections in time
    def overlap?(other)
      ! disjoint(other)
    end

    # if self and other have no intersections in time
    def disjoint?(other)
      @end < other.beginning || other.end < @beginning
    end

    # is a Time object inside the span
    def inside?(time)
      @beginning <= time && time <= @end
    end

    # is a Time object outside of the span
    def outside?(time)
      ! inside?(time)
    end

    # compare by length of the time span
    def <=>(other)
      length <=> other.length
    end

    # compare by @beginning and @end of this and other (stricter than == method)
    def ===(other)
      to_a.map(&:to_i) == other.to_a.map(&:to_i)
    end

    def to_a
      [ @beginning, @end ]
    end

    def to_s
      "from #{@beginning} until #{@end}"
    end

    def to_i
      (@end - @beginning).floor + 1
    end

    alias :length :to_i

    # Define utility methods for breaking down time spans into smaller intervals
    #
    #   Examples:
    #
    #   Span['last week'].days
    #   # an array of Span objects each representing a day from that week.
    #
    #   Span['last month'].weekly do |week|
    #     # do something with that week object
    #   end
    #   # This will yield all weeks that started or ended in 'this month'
    #
    #   Span['last month'].weekly(true) do |week|
    #     # ...
    #   end
    #   # This will yield the complete weeks within that period only.
    #   # See `breakdown_by` for examples.
    #
    [ :hour, :day, :week, :month, :year ].each do |aggregate|
      define_method "#{aggregate}s" do |strict = false|
        breakdown_by(aggregate, strict)
      end

      define_method "#{aggregate}ly" do |strict = false, &block|
        per(aggregate, strict, &block)
      end unless aggregate.eql?(:day)

      define_method :daily do |strict = false, &block|
        per(:day, strict, &block)
      end
    end

    # aggegate is :hour, :day, :week, :month, :year
    #
    #   Examples:
    #
    #   Span['last week'].per(:day) # the same as Span['last week'].daily
    #
    def per(aggregate, strict = false)
      group = breakdown_by(aggregate, strict)
      if block_given?
        group.each { |member| yield member }.size
      else
        group
      end
    end

    private

    # This takes an `aggregate` in :hour, :day, :week, :month, :year and an
    # `strict` in true | false, default false.
    #
    # Returns an array of Span objects or an empty Array.
    #
    #    Examples:
    #
    #    Span['this month'].breakdown_by(:day)
    #    # an array with all days this month
    #
    #    Span['this month'].breakdown_by(:week, true)
    #    # return only weeks that started and ended during 'this month'
    #
    def breakdown_by(aggregate, strict = false)
      start  = @beginning.send("beginning_of_#{aggregate}")
      finish = @end.send("end_of_#{aggregate}")

      if outside?(start) && strict
        start = @beginning.in(1.send(aggregate)).send("beginning_of_#{aggregate}")
      end

      if outside?(finish) && strict
        finish = @end.ago(1.send(aggregate)).send("end_of_#{aggregate}")
      end

      result = []

      this_beginning = start
      this_end       = start.send("end_of_#{aggregate}")
      while this_end <= finish do
        result.push(Span[this_beginning, this_end])
        this_beginning = this_beginning.in(1.send(aggregate))
        this_end       = this_beginning.send("end_of_#{aggregate}")
      end
      result
    end
  end
end
