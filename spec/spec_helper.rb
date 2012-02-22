$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'active_record'
require 'sqlite3'

conn = { :adapter => 'sqlite3', :database => ':memory:' }
ActiveRecord::Base.establish_connection(conn)

ActiveRecord::Base.connection.create_table :orders, :force => true do |t|
  t.integer  :id
  t.integer  :product_id
  t.datetime :cool_timer
end

ActiveRecord::Base.connection.create_table :products, :force => true do |t|
  t.integer  :id
  t.datetime :created_at
  t.string   :name
end

ActiveRecord::Base.connection.create_table :users, :force => true do |t|
  t.integer  :id
  t.datetime :registered_on
  t.datetime :first_purchase_on
  t.datetime :last_purchase_on
  t.string   :type
end

require 'activerecord-periodic'
require 'factory_girl'

class Order < ActiveRecord::Base
  belongs_to :product
  has_time_span_scopes :cool_timer
end

class Product < ActiveRecord::Base
  has_many :orders
  has_time_span_scopes
end

class User < ActiveRecord::Base
  has_time_span_scopes :registered_on
end

FactoryGirl.define do
  factory :product do
    name 'The business'
  end

  factory :order

  factory :user

  factory :customer do
    type 'Customer'
  end

  factory :regular do
    type 'Regular'
  end
end

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
