module SpreeShipworks
  class UpdateStatus
    include Dsl

    def call(params)
      # TODO process comments params
      if SpreeShipworks::Config.use_split_shipments
        if shipment = Spree::Shipment.find_by_number(params['order'])
          shipment.send("#{params['status']}!".to_sym)

          response do |r|
            r.element 'UpdateSuccess'
          end
        end
      else
        if order = Spree::Order.find_by_number(params['order'])
          order.shipments.each do |shipment|
            shipment.send("#{params['status']}!".to_sym)
          end

          response do |r|
            r.element 'UpdateSuccess'
          end
        end
      end

    rescue ActiveRecord::RecordNotFound
      error_response("NOT_FOUND", "Unable to find an order with ID of '#{params['order']}'.")
    rescue StateMachines::InvalidTransition, NoMethodError => error
      error_response("INVALID_STATUS", error.to_s)
    rescue => error
      error_response("INTERNAL_SERVER_ERROR", error.to_s)
    end
  end
end
