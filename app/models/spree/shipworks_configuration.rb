module Spree
  class ShipworksConfiguration < Preferences::Configuration

    # if true, sends to shipworks each *shipment*, instead of each order.
    # Note: shipworks will not known this and will treat every shipment as a
    # normal single order.
    preference :use_split_shipments, :boolean, default: false
    # do not process shipments from these stock locations
    # need use_split_shipments = true
    preference :stock_location_ids_blacklist, :array, default: []
  end
end