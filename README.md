[![Build
Status](https://secure.travis-ci.org/chochkov/active_record_periodic.png)](https://secure.travis-ci.org/chochkov/active_record_periodic.png)

*** Introduction

Periods gem adds scopes to your `ActiveRecord` models that let you make time span queries
much easier. Lets say it's Christams today, take a look:

    ```ruby
    class Order < ActiveRecord::Base
      has_time_span_scopes
    end

    Order.span('yesterday')
    # WHERE (`orders`.`created_at` >= '2011-12-23 00:00:00') AND (`orders`.`created_at` < '2011-12-23 23:59:59')

    Order.span('the day 3 days ago')
    # WHERE (`orders`.`created_at` >= '2011-12-20 00:00:00') AND (`orders`.`created_at` < '2011-12-20 23:59:59')

    Order.span('this month')
    # WHERE (`orders`.`created_at` >= '2011-12-01 00:00:00') AND (`orders`.`created_at` < '2011-12-27 23:59:59')

    ```

*** Usage

You can use these language structures to describe time scopes with `Periods`

'the day 5 days ago'
'the week 5 weeks ago'
'the week 5 months ago'
'from 21/12/2012 until 23/12/2012'
'last week'

*** Complete (and short) list of features

`created_at`, `created_on`, `updated_at`, `updated_on` are in that order the
default attributes, which would be scoped on. If those aren't found and no
other field is set `Order.span('yesterday')` would simply return `scoped`
(no change to the query).

To change the default attributes:

    ```ruby
    class Product < ActiveRecord::Base
      has_time_span_scopes :manufactured_on
    end
    ```

In this case if no `:manufactured_on` field is found, a `Periods::NoColumnGiven`
error would be raised.

Furthermore you can do more complicated time-scoping on more than one attribute.

    ```ruby
    class Product < ActiveRecord::Base
      has_time_span_scopes :manufactured_on
    end

    Product.span('this year', :delivered_on => 'this month')

    ```

Or you can use it on associations like:

    ```ruby
    Product.joins([ :orders, :customers ]).span('this year',
      Order    => { :confirmed_on  => 'the day 3 weeks ago' },
      Customer => { :date_of_birth => 'the year 1980' }
    )
    ```

With an alternative model definition, the above query could be simplified:

    ```ruby
    class Product < ActiveRecord::Base
      has_time_span_scopes
    end

    class Order < ActiveRecord::Base
      has_time_span_scopes :confirmed_on
    end

    class Customer < ActiveRecord::Base
      has_time_span_scopes :date_of_birth
    end

    Product.joins([ :orders, :customers ]).span('this year',
      Order    => 'the day 3 weeks ago',
      Customer => 'the year 1980'
    )
    ```

Furthermore you can configure the scope name using:

    ```ruby
    class Order < ActiveRecord::Base
      has_time_span_scopes :confirmed_on, :scope_name => :period
    end

    Order.period('last week')
    ```

*** Optional Scopes

Further flexibility could be gained by including these optional scopes:

    ```ruby
    class Order < ActiveRecord::Base
      has_time_span_scopes :confirmed_on, :with_all_scopes => true
    end

    Order.yesterday
    Order.today
    Order.tomorrow
    Order.last_week
    Order.this_week
    Order.next_week

    # The last three have respective variations for:
    # :minute, :hour, :day, :week, :month, :year
    # Eg. Order.last_year, etc.
    ```

And since those return `ActiveRecord::Relation` themselves, you can chain on:

    ```ruby
    Order.yesterday.where(:city => 'Berlin')
    ```

