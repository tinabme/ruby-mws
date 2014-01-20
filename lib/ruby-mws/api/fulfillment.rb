require 'builder'

module MWS
  module API

    class Fulfillment < Base
      include Feeds
	  
      ## Takes an array of hash AmazonOrderID,FulfillmentDate,CarrierName,ShipperTrackingNumber,sku,quantity
      ## Returns true if all the orders were updated successfully
      ## Otherwise raises an exception
      def post_ship_confirmation(merchant_id, ship_info)
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
          ship_info.each do |shp|
            env.Message do |msg|
              msg.MessageID(i += 1)
              msg.OrderFulfillment do |orf|
                orf.AmazonOrderID(shp.AmazonOrderID)
			    orf.FulfillmentDate(shp.FulfillmentDate.to_time.iso8601)
                orf.FulfillmentData do |fd|
                  fd.CarrierCode(shp.CarrierCode)
                  fd.ShippingMethod()
                  fd.ShipperTrackingNumber(shp.ShipperTrackingNumber)
                end
                if shp.sku != ''
                  orf.Item do |itm|
                    itm.MerchantOrderItemID(shp.sku)
                    itm.MerchantFulfillmentItemID(shp.sku)
                    itm.Quantity(shp.quantity)
                  end
                end
              end
            end
          end
        end
		submit_feed('_POST_ORDER_FULFILLMENT_DATA_', xml)

      end
    end
  end
end