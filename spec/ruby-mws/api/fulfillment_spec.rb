require 'spec_helper'

describe MWS::API::Inventory do

  before :all do
    EphemeralResponse.activate
    @mws = MWS.new(auth_params)
  end

  #context "requests" do


  describe "post_ship_confirmation" do
    before(:each) do
      @response = @mws.fulfillment.post_ship_confirmation(nil, nil)
    end

    it "should return xml" do
      @response.should include('<?xml version="1.0" encoding="UTF-8"?>')
    end

    it "should raise an ArgumentError error if no parameters passed" do
      expect { @mws.fulfillment.post_ship_confirmation }.to raise_error(ArgumentError)
    end
	
	it "should raise an error if argument is not array" do
		expect {arg[1].should be_an_instance_of(Array)}
	end
  end


  #end

end