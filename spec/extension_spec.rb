require 'spec_helper'

describe 'Submodels and STI' do
  before(:all) do
    class Regular < User
      has_time_span_scopes :last_purchase_on
    end

    class Customer < User
      has_time_span_scopes :first_purchase_on
    end
  end

  before(:each) do
    @registered_on     = Time.now - 3.days
    @first_purchase_on = Time.now - 2.days
    @last_purchase_on  = Time.now - 1.days

    Factory(:regular,  :last_purchase_on  => @last_purchase_on)
    Factory(:customer, :first_purchase_on => @first_purchase_on)
    Factory(:user,     :registered_on     => @registered_on)
  end

  it 'should let subclasses span on their own fields' do
    Regular.span("the day #{@last_purchase_on}").size.should == 1
    Customer.span("the day #{@last_purchase_on}").size.should == 0
    User.span("the day #{@last_purchase_on}").size.should == 0

    Customer.span("the day #{@first_purchase_on}").size.should == 1
    Regular.span("the day #{@first_purchase_on}").size.should == 0
    User.span("the day #{@first_purchase_on}").size.should == 0

    User.span("the day #{@registered_on}").size.should == 1
    Customer.span("the day #{@registered_on}").size.should == 0
    Regular.span("the day #{@registered_on}").size.should == 0
  end
end

describe 'Scope names' do
  it 'customizing scope names is optional' do
    class Admin < ActiveRecord::Base
      has_time_span_scopes :last_purchase_on, :scope_name => :timespan
    end

    Admin.respond_to?(:timespan).should be_true
    Admin.respond_to?(:span).should be_false
  end
end

describe 'OptionalScopes' do
  it 'optionally adds additional scopes' do
    class Admin < ActiveRecord::Base
      has_time_span_scopes :last_purchase_on, :scope_name => :timespan, :with_all_scopes => true
    end

    Admin.respond_to?(:last_month).should be_true
    Admin.respond_to?(:this_month).should be_true
    Admin.respond_to?(:next_month).should be_true
    Admin.respond_to?(:this_week).should be_true
    Admin.respond_to?(:today).should be_true
    Admin.respond_to?(:yesterday).should be_true
    Admin.respond_to?(:tomorrow).should be_true
    Admin.respond_to?(:last_year).should be_true
  end
end
