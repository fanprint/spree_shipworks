require 'spree_core'
require 'spree_shipworks/engine'
require 'spree_shipworks/dsl'

module SpreeShipworks

  mattr_accessor :order_class

  def self.order_class
    if @@order_class.is_a?(Class)
      raise "SpreeShipworks.order_class MUST be a String object, not a Class object."
    elsif @@order_class.is_a?(String)
      @@order_class.constantize
    end
  end
end
