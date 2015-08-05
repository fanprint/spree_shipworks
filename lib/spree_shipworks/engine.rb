module SpreeShipworks
  class Engine < Rails::Engine
    require 'spree/core'
    #isolate_namespace Spree
    engine_name 'spree_shipworks'
    isolate_namespace SpreeShipworks

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
      SpreeShipworks.order_class = if SpreeShipworks::Config.use_split_shipments
        'SpreeShipworks::Shipments'
      else
        'SpreeShipworks::Orders'
      end
    end

    config.to_prepare &method(:activate).to_proc

    initializer "spree.shipworks.environment", :before => :load_config_initializers do |app|
      SpreeShipworks::Config = Spree::ShipworksConfiguration.new
    end

    config.to_prepare do
      Dir.glob(Rails.root + "app/decorators/**/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end

  end
end
