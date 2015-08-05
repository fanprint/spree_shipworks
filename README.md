SpreeShipworks
==============

This gem provides API for your spree shop, that allows shipworks to process your orders.

Integrating
-----------

Add gem into your Gemfile:

```
gem 'spree_shipworks', git: 'git@github.com:bypotatoes/spree_shipworks.git', branch: '3-0-stable'
```

If you need, patch your `Spree::ApiController` through `api_controller_decorator.rb`
```
Spree::ApiController.class_eval do
  # code goes here
end
```
Load shipworks aplication and [add a Generic Module store](http://support.shipworks.com/support/solutions/articles/4000048147-adding-a-generic-module-store)

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

    $ bundle
    $ bundle exec rake test_app
    $ bundle exec rspec spec

Copyright (c) 2013 [name of extension creator], released under the New BSD License
