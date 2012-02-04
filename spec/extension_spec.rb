require 'spec_helper'

class AddUpdatedOn < ActiveRecord::Migration
  def self.up
    add_column Product.arel_table.name, :updated_on, :datetime
  end

  def self.down
    remove_column Product.arel_table.name, :updated_on
  end
end

class RemoveCreatedAt < ActiveRecord::Migration
  def self.up
    remove_column Product.arel_table.name, :created_at
  end

  def self.down
    add_column Product.arel_table.name, :created_at, :datetime
  end
end

describe do
  before(:each) do
    AddUpdatedOn.up
    Product.reset_column_information
  end

  after(:each) do
    AddUpdatedOn.down
    Product.reset_column_information
  end

  it 'should default to created_on prior to updated_at column' do
    created = Time.now - 2.days
    updated = created + 1.day
    Factory(:product, :created_at => created, :updated_on => updated)
    Product.span("the day #{created}").size.should == 1
    Product.span("the day #{updated}").size.should == 0
  end
end

describe do
  before(:each) do
    AddUpdatedOn.up
    RemoveCreatedAt.up
    Product.reset_column_information
  end

  after(:each) do
    RemoveCreatedAt.down
    AddUpdatedOn.down
    Product.reset_column_information
  end

  it 'should default to updated_on if theres no created_at' do
    updated = Time.now - 1.day
    Factory(:product, :updated_on => updated)
    Product.span("the day #{updated - 1.day}").size.should == 0
    Product.span("the day #{updated}").size.should == 1
  end
end

describe do
  it "raises an error if no appropriate field is there" do
    lambda {
      class Customer < ActiveRecord::Base
        has_time_span_scopes
      end
    }.should raise_error(Periods::NoColumnGiven)
  end

  it "shouldnt raise error if coumn is given" do
    lambda {
      class Customer < ActiveRecord::Base
        has_time_span_scopes :registered_on
      end
    }.should_not raise_error
  end
end
