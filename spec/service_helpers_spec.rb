require 'spec_helper'

class String
  def name; self end
end

class Model; end

include ActiveRecord::Periodic

describe '.fallback_column' do
  before(:each) do
    def columns(cols)
      Model.stub!(:columns).and_return(cols)
    end
  end

  it 'should choose created_on prior to updated_at column' do
    columns [ 'created_on', 'updated_at' ]
    ServiceHelpers.fallback_column(Model).should == 'created_on'
  end

  it 'should choose updated_on if no created_at/on or updated_at found' do
    columns [ 'updated_on' ]
    ServiceHelpers.fallback_column(Model).should == 'updated_on'
  end

  it 'should choose created_at prior to created_on' do
    columns [ 'created_on', 'created_at' ]
    ServiceHelpers.fallback_column(Model).should == 'created_at'
  end

  it 'should be silent if no suitable column is given or found' do
    columns [ 'something_else' ]
    lambda {
      ServiceHelpers.fallback_column(Model)
    }.should_not raise_error
  end
end
