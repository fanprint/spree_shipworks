module SpreeShipworks
  module Xml
    module Address
      def to_shipworks_xml(name, context)
        context.element name do |a|
          a.element 'FullName',   self.full_name
          a.element 'Company',    ""#self.user.try(:company)
          a.element 'Street1',    self.address1
          a.element 'Street2',    self.address2
          a.element 'City',       self.city
          a.element 'State',      self.state.try(:abbr)
          a.element 'PostalCode', self.zipcode
          a.element 'Country',    self.country.try(:iso_name)
          a.element 'Phone',      self.phone
          a.element 'Fax',        ''
          a.element 'Email',      ""#self.user.try(:email)
        end
      end
    end # Address

    module Note
      def to_shipworks_xml(context, note)
        context.element 'Notes' do |n|
          n.element 'Note', note
        end
      end
    end # Note

    module Adjustment
      def to_shipworks_xml(context)
        if self.amount.present?
          context.element 'Total', format("%01.2f", self.amount.abs),
                                    :id => self.id,
                                    :name => self.label,
                                    :impact => self.impact
        end
      end

      def impact
        if amount && amount < 0
          'subtract'
        elsif amount && amount > 0
          'add'
        else
          'none'
        end
      end
    end # Adjustment

    module Creditcard
      def to_shipworks_xml(context)
        context.element 'CreditCard' do |cc|
          cc.element 'Type',    self.cc_type || 'unknown' if self.respond_to?(:cc_type)
          cc.element 'Owner',   self.name || '' rescue ''
          cc.element 'Number',  self.display_number || '' rescue ''
          cc.element 'Expires', self.expires || '' rescue ''
          cc.element 'CCV',     self.verification_value if self.verification_value? rescue ''
        end
      end

      def expires
        "#{month}/#{year}" if month.present? || year.present?
      end
    end # CreditCard

    module LineItem
      def to_shipworks_xml(context)
        context.element 'Item' do |i|
          i.element 'ItemID',    self.id                                                if self.id.present?
          i.element 'ProductID', self.product.id                                        if self.product.present?
          i.element 'Code',      self.variant.sku                                       if self.variant.present?
          i.element 'SKU',       self.variant.sku                                       if self.variant.present?
          i.element 'Name',      self.variant.name                                      if self.product.present?
          i.element 'Quantity',  self.quantity
          i.element 'UnitPrice', format("%01.2f", self.price)
          i.element 'UnitCost',  format("%01.2f", self.variant.cost_price)              if self.variant.present? && self.variant.cost_price
          i.element 'Weight',    self.variant.weight || 0.0                             if self.variant.present?

          i.element 'Attributes' do |attributes|
            self.variant.option_values.each do |option|
              attributes.element 'Attribute' do |attribute|
                attribute.element 'AttributeID',  option.option_type_id
                attribute.element 'Name',         option.option_type.presentation
                attribute.element 'Value',        option.presentation
              end
            end

            self.ad_hoc_option_values.each do |option|
              attributes.element 'Attribute' do |attribute|
                attribute.element 'AttributeID',  option.ad_hoc_option_type.option_type_id
                attribute.element 'Name',         option.ad_hoc_option_type.option_type.presentation
                attribute.element 'Value',        option.option_value.presentation
                attribute.element 'Price',        option.price_modifier
              end
            end if respond_to?(:ad_hoc_option_values)
          end
        end
      end
    end # LineItem

    module Order
      def to_shipworks_xml(context)
        context.element 'Order' do |order_context|
          order_context.element 'OrderNumber',    self.id
          order_context.element 'OrderDate',      self.created_at.to_s(:db).gsub(" ", "T")
          order_context.element 'LastModified',   self.updated_at.to_s(:db).gsub(" ", "T")
          order_context.element 'ShippingMethod', self.shipping_method.try(:name)
          order_context.element 'StatusCode',     self.state
          order_context.element 'CustomerID',     self.user.try(:id)

          if self.special_instructions.present?
            self.special_instructions.extend(Note)
            self.special_instructions.to_shipworks_xml(order_context, self.special_instructions)
          end


          if self.ship_address
            self.ship_address.extend(Address)
            self.ship_address.to_shipworks_xml('ShippingAddress', order_context)
          end

          if self.bill_address
            self.bill_address.extend(Address)
            self.bill_address.to_shipworks_xml('BillingAddress', order_context)
          end

          if self.payments.first.present?
            payment = self.payments.first.extend(::SpreeShipworks::Xml::Payment)
            payment.to_shipworks_xml(order_context)
          end

          order_context.element 'Items' do |items_context|
            self.line_items.each do |item|
              next if item.quantity == 0
              item.extend(LineItem)
              item.to_shipworks_xml(items_context) if item.variant.present?
            end
          end if self.line_items.present?

          order_context.element 'Totals' do |totals_context|
            self.adjustments.each do |adjustment|
              adjustment.extend(Adjustment)
              adjustment.to_shipworks_xml(totals_context)
            end
          end
        end
      end
    end # Order

    module Payment
      def to_shipworks_xml(context)
        context.element 'Payment' do |payment_context|
          payment_context.element 'Method', self.payment_source.class.name.split("::").last
          if self.source.present? && self.source.respond_to?(:cc_type)
            self.source.extend(Creditcard)
            self.source.to_shipworks_xml(payment_context)
          end
        end
      end
    end # Payment

  end
end
