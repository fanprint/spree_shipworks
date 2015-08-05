module Spree
  Shipment.class_eval do
    # just added the touch
    def update!(order)
      old_state = state
      new_state = determine_state(order)
      update_column :state, new_state
      touch
      after_ship if new_state == 'shipped' and old_state != 'shipped'
    end
  end
end