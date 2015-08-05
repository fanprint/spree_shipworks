module SpreeShipworks
  class UpdateShipment
    include Dsl

    def call(params)
      if SpreeShipworks::Config.use_split_shipments
        shipment = Spree::Shipment.find_by_number(params['order'])
      else
        order = Spree::Order.find_by_number(params['order'])
        shipment = order.shipments.first
      end

      if shipment.try(:update_attributes, update_params(params))
        response do |r|
          r.element 'UpdateSuccess'
        end
      else
        Honeybadger.notify(error_response)
        error_response("UNPROCESSIBLE_ENTITY", "Could not update tracking information for Order ##{params['order']}")
      end

    rescue ActiveRecord::RecordNotFound
      error_response("NOT_FOUND", "Unable to find an order with ID of '#{params['order']}'.")
    rescue => error
      error_response("INTERNAL_SERVER_ERROR", error.to_s)
    end

    private

    def update_params(params)
      { :tracking => params['tracking'] }
    end
  end
end
