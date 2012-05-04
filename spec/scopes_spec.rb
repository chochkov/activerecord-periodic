require 'spec_helper'

describe 'Simple Scoping' do
  before(:each) do
    Order.delete_all
    Factory(:order, :cool_timer => Time.now - 2.days)
  end

  it "should .span should scope with per given span" do
    Order.span('the day 1 day ago').size.should == 0
    Order.span('the day 2 day ago').size.should == 1
  end
end

describe 'Scoping with joins' do
  before(:each) do
    Order.delete_all
    Product.delete_all
    p1 = Factory(:product, :id => 1, :created_at => Time.now - 2.days)
    p2 = Factory(:product, :id => 2, :created_at => Time.now - 3.days)
    Factory(:order, :cool_timer => Time.now - 2.days, :product_id => p1.id)
    Factory(:order, :cool_timer => Time.now - 2.days, :product_id => p1.id)
    Factory(:order, :cool_timer => Time.now - 1.days, :product_id => p2.id)
  end

  it "should apply correctly with joins" do
    Order.joins(:product).size.should == 3
    Product.joins(:orders).size.should == 3
    Order.joins(:product).span('the day 1 day ago').size.should == 1
    Product.joins(:orders).span('the day 2 day ago').size.should == 2

    Product.joins(:orders).span({
      Product => 'the day 4 days ago',
      Order   => 'the day 2 days ago'
    }).size.should == 0

    Product.joins(:orders).span({
      Product => 'the day 2 days ago',
      Order   => 'the day 2 days ago'
    }).size.should == 2

    Product.joins(:orders).span({
      Product => 'the day 3 days ago',
      Order   => 'the day 1 days ago'
    }).size.should == 1
  end

  it "should allow flexibility in calling" do
    Product.joins(:orders).span({
      Product => 'the day 4 weeks ago',
      Order   => 'the week 3 weeks ago'
    }).to_a.should ==
      Product.joins(:orders).span(
        'the day 4 weeks ago',
        Order => 'the week 3 weeks ago'
      ).to_a
  end

  it "should return full scope if given 'full' or 'all'" do
    Order.span('full').size.should == Order.count
    Order.span('all').size.should == Order.count
  end

  it "should return the ones done today" do
    Order.span('today').size.should == 0
    Order.span('full').size.should == 3
    Factory(:order, :cool_timer => Time.now)
    Order.span('full').size.should == 4
    Order.span('today').size.should == 1
  end
end

