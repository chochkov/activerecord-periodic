require 'spec_helper'

def assert(start, finish, text)
  parsed = ActiveRecord::Periodic::Parser[text].parse
  parsed.first.to_i.should == start.to_i
  parsed.second.to_i.should == finish.to_i
end

describe ActiveRecord::Periodic::Parser do
  it "should know what you're talking about" do
    assert \
      Time.now.ago(2.days).beginning_of_day,
      Time.now.ago(2.days).end_of_day,
      'the day 2 days ago'

    assert \
      Time.now.ago(2.weeks).beginning_of_day,
      Time.now.ago(2.weeks).end_of_day,
      'the day 2 weeks ago'

    assert \
      Time.now.ago(2.days).beginning_of_week,
      Time.now.ago(2.days).end_of_week,
      'the week 2 days ago'

    assert \
      Time.now.ago(1.weeks).beginning_of_week,
      Time.now.ago(1.weeks).end_of_week,
      'the week 1 weeks ago'

    assert \
      (Time.now + 20.days).beginning_of_week,
      (Time.now + 20.days).end_of_week,
      'the week after 20 days'

    assert \
      (Time.now - 1.day).beginning_of_day,
      (Time.now - 1.day).end_of_day,
      'yesterday'

    a = Time.now
    assert \
      a.beginning_of_day,
      a.end_of_day,
      'today'
  end

  it "should strip and clean whitespaces before processing" do
    assert \
      Time.now.ago(2.days).beginning_of_day,
      Time.now.ago(2.days).end_of_day,
      '   the   day 2 days ago  '
  end

  it "should recognize specific periods" do
    assert \
      Time.parse('2011-11-11').beginning_of_day,
      Time.parse('2011-11-11').end_of_day,
      'the day 2011-11-11'

    assert \
      Time.parse('2011-11-11').beginning_of_week,
      Time.parse('2011-11-11').end_of_week,
      'the week 2011-11-11'
  end

  it "should understand this" do
    assert \
      Time.now.beginning_of_week,
      Time.now.end_of_week,
      'this week'

    assert \
      Time.now.beginning_of_year,
      Time.now.end_of_year,
      'this year'
  end

  it "should understand last" do
    assert \
      Time.now.ago(1.month).beginning_of_month,
      Time.now.ago(1.month).end_of_month,
      'last month'

    assert \
      Time.now.ago(1.week).beginning_of_week,
      Time.now.ago(1.week).end_of_week,
      'last week'

    assert \
      Time.now.ago(1.week).beginning_of_week,
      Time.now.ago(1.week).end_of_week,
      'the last week'
  end

  it "should understand next" do
    assert \
      Time.now.in(1.week).beginning_of_week,
      Time.now.in(1.week).end_of_week,
      'next week'

    assert \
      Time.now.in(1.year).beginning_of_year,
      Time.now.in(1.year).end_of_year,
      'next year'
  end

  it "should understand last 3 months (days, weeks..)" do
    assert \
      Time.now.ago(3.month).beginning_of_month,
      Time.now.ago(1.month).end_of_month,
      'last 3 months'

    assert \
      Time.now.in(1.year).beginning_of_year,
      Time.now.in(3.year).end_of_year,
      'the next 3 years'

    assert \
      Time.now.in(1.year).beginning_of_year,
      Time.now.in(3.year).end_of_year,
      'next 3 years'
  end

  it "should understand from .. until .. and parse the arguments through Chronic" do
    a = Time.now
    assert \
      a.ago(3.months),
      a,
      'from 3 months ago until now'

    a = Chronic.parse('2011-11-11 00:00')
    b = Chronic.parse('2011-11-11')
    assert \
      a,
      b,
      'from 2011/11/11 00:00 until 2011/11/11'
  end

  it "should ignore case" do
    assert \
      Time.now.yesterday.beginning_of_day,
      Time.now.yesterday.end_of_day,
      'yESterdaY'
  end

  it "should raise error if the expression given doesnt make sense" do
    lambda {
      ActiveRecord::Periodic::Parser['this is silly input'].parse
    }.should raise_error(ActiveRecord::Periodic::TextParsingError)
  end
end

