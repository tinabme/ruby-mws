require 'builder'

module MWS
  module API

    class Fulfillment < Base
      include Feeds

      def_request [:list_inventory_supply, :list_inventory_supply_by_next_token],
        :verb => :get,
        :uri => '/FulfillmentInventory/2010-10-01',
        :version => '2010-10-01',
        :lists => {
          :seller_skus => "SellerSkus.member"
        },
        :mods => [
          lambda {|r| r.inventory_supply_list = [r.inventory_supply_list.member].flatten}
        ]

      # Takes an array of hash AmazonOrderID,FulfillmentDate,CarrierName,ShipperTrackingNumber,SKU,Quantity
      # Returns true if all the orders were updated successfully
      # Otherwise raises an exception
      def post_ship_confirmation(merchant_id, hash)
        # Shipping Confirmation is done by sending an XML "feed" to Amazon
        
        xml = ""
        builder = Builder::XmlMarkup.new(:indent => 2, :target => xml)
        builder.instruct! # <?xml version="1.0" encoding="UTF-8"?>
        builder.AmazonEnvelope(:"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", :"xsi:noNamespaceSchemaLocation" => "amzn-envelope.xsd") do |env|
          env.Header do |head|
            head.DocumentVersion('1.01')
            head.MerchantIdentifier(merchant_id)
          end
          env.MessageType('OrderFulfillment')
          i = 0
          hash.each do |sku,quantity|
            env.Message do |msg|
              msg.MessageID(i += 1)
              msg.OperationType('Update')
              msg.Inventory do |inv|
                inv.SKU(sku)
                inv.Quantity(quantity)
              end
            end
          end
        end

        submit_feed('_POST_ORDER_FULFILLMENT_DATA_', xml)
      end

      
    end

  end
end