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

    def finite?
      ! infinite?
    end

    def infinite?
      @beginning == MINUS_INFINITY || @end == INFINITY
    end

    def overlap?(other)
      ! disjoint(other)
    end

    def disjoint?(other)
      @end < other.beginning || other.end < @beginning
    end

    def <=>(other)
      length <=> other.length
    end

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

    [ :hour, :day, :week, :month, :year ].each do |aggregate|
      define_method "#{aggregate}s" do
        breakdown_by(aggregate)
      end
    end

    # [ :hourly, :daily, :weekly, :monthly, :yearly ].each do |aggregate|
    #  define_method aggregate do |&block|
    #    per(aggregate, &block)
    #  end
    # end

    def per(aggregate)
      group = breakdown_by(aggregate)
      if block_given?
        group.each { |member| yield member }.size
      else
        group
      end
    end

    private

    def breakdown_by(aggregate)
      a = []
      b = beginning.send("beginning_of_#{aggregate}")
      while true do
        a.push(Span[b, b.send("end_of_#{aggregate}")])
        break if (new_beginning = b + 1.send(aggregate)) >= self.end
        b = new_beginning
      end
      a
    end
  end
end

