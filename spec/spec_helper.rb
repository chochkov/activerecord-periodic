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

ActiveRecord::Base.connection.create_table :customers, :force => true do |t|
  t.integer :id
  t.datetime :registered_on
end

require 'periods'
require 'factory_girl'

class Order < ActiveRecord::Base
  belongs_to :product
  has_time_span_scopes :cool_timer
end

class Product < ActiveRecord::Base
  has_many :orders
  has_time_span_scopes
end

FactoryGirl.define do
  factory :product do
    name 'The business'
  end

  factory :order do
  end
end

