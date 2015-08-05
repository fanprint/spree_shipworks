require 'spree_shipworks/xml'

module SpreeShipworks
  class Shipments
    VALID_STATES          = %w(complete resumed)
    VALID_SHIPMENT_STATES = ::Spree::Shipment.state_machine.events.collect(&:name)

    def self.since(start_date = nil)
      scope = Spree::Shipment.joins(:order).
                where(:'spree_orders.state' => VALID_STATES, state: 'ready').
                order('spree_shipments.updated_at asc')

      if SpreeShipworks::Config.stock_location_ids_blacklist.any?
        scope = scope.where('spree_shipments.stock_location_id NOT IN (?)', SpreeShipworks::Config.stock_location_ids_blacklist)
      end

      if start_date && start_date.to_s != ''
        scope = scope.where('spree_shipments.updated_at > ?', DateTime.parse(start_date.to_s).advance(seconds: 1))
      end

      scope
    end

    # AR::Base#find_each and AR::Base#find_in_batches do not allow support ordering or limiting
    # This method mimicks the behavior of #find_in_batches, but is specific to the needs of the
    # ShipWorks API since it will break after the maxcount has been reached AND the updated_at
    # attribute has changed since the last order that was found.
    def self.since_in_batches(start_string, maxcount_string)
      if !block_given?
        raise ArgumentError.new("block not given")
      end

      begin
        date = DateTime.parse(start_string)
      rescue
        raise ArgumentError.new("the start variable is invalid")
      end

      batch_size = maxcount_string.to_i
      if batch_size.to_s != maxcount_string
        raise ArgumentError.new("the maxcount variable is invalid")
      end

      batch = 0
      broken = false
      counter = 0
      last_updated_at = nil
      relation = self.since(date).limit(batch_size)

      Spree::Shipment.uncached do
        shipments = relation.offset(batch_size * batch).all
        while shipments.any?
          shipments.each do |shipment|
            counter += 1
            if counter > batch_size && last_updated_at != shipment.updated_at
              broken = true
              break
            end
            shipment.extend(Xml::Shipment)
            last_updated_at = shipment.updated_at
            yield shipment
          end
          break if shipments.size < batch_size || broken
          shipments = relation.offset(batch_size * (batch += 1)).all
        end
      end
    end
  end
end
