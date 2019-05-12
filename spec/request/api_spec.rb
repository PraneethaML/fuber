require 'rails_helper'
require './spec/request/api_params.rb'
include ApiParams

describe 'api requests', type: :request do
  
  describe 'POST /book_cab' do
    it 'should give error when wrong params are sent' do
    	params = bookCabInvalidParams.to_json
    	post '/book_cab', params: params
    	expect(response).to have_http_status(422)
    end

    it 'should return correct cab when customer has color preference and cab is found' do
    	params = bookCabParams
    	post '/book_cab', params: params
    	parse_json = JSON(response.body)
    	cab_id = parse_json["cab_id"]
    	if !cab_id.nil?
    		is_pink = Cab.find_by(:id => cab_id.to_i).is_pink
    		expect(is_pink).to eq true
    	else
    		expect(response).to have_http_status(422)
    	end
    end

    it 'should not return unavailable cabs' do
    	params = bookCabParams
    	post '/book_cab', params: params
    	cabs = Cab.pluck(:is_available)
    	parse_json = JSON(response.body)
    	if cabs.include?(true)
    		expect(response).to have_http_status(200)
    	else
    		expect(response).to have_http_status(422)
    	end
    end
  end

  describe 'POST /start_ride' do
  	before(:each) do
  		params = acceptRideParams
  		post '/accept_ride', params: params
  	end

    it 'should not start a ride for ended trip' do
    	params = startRideParams
    	post '/start_ride', params: params 
    	expect(Ride.count).not_to eq 0
    	ride = Ride.find_by(:id => params['ride_id'])
    	expect(ride.ride_end_time).to eq nil
    end

    it 'should not start the ride without going to customer location' do
      params = startRideParams
      post '/start_ride', params: params 
      cab = Cab.find_by(:id => params['cab_id'])
      cab_lat = cab.lat
      cab_long = cab.long
      cust_lat = params['src_lat']
      cust_long = params['src_long']
      expect(cab_lat).to eq cust_lat
      expect(cab_long).to eq cust_long
    end
  end

  describe 'POST /end_ride' do
    before(:each) do
      params = acceptRideParams
      post '/accept_ride', params: params
      params = startRideParams
      post '/start_ride', params: params
    end

    it 'should make the cab available after ending' do
      params = endRideParams
      post '/end_ride', params: params 
      cab = Cab.find_by(:id => params['cab_id'])
      expect(cab.is_available).to eq true
    end

    it 'should not end the ride without going to destination' do
      params = endRideParams
      post '/end_ride', params: params 
      cab = Cab.find_by(:id => params['cab_id'])
      cab_lat = cab.lat
      cab_long = cab.long
      cust_dest_lat = params['dest_lat']
      cust_dest_long = params['dest_long']
      expect(cab_lat).to eq cust_dest_lat
      expect(cab_long).to eq cust_dest_long

    end

    it 'should always have ride end time greater than ride start time' do
      params = endRideParams
      post '/end_ride', params: params 
      ride = Ride.find_by(:id => params['ride_id'])
      start_time = ride.ride_start_time
      end_time = ride.ride_end_time
      expect(end_time).to be > start_time
    end
  end

  describe 'Post /accept_ride' do
    it 'should make the assigned car as unavailable for other customers' do
      params = acceptRideParams
      post '/accept_ride', params: params
      cab = Cab.find_by(:id => params['cab_id'])
      is_available = cab.is_available
      expect(is_available).to eq false
    end
  end

  describe 'POST /get_fare' do
    before do
      params = acceptRideParams
      post '/accept_ride', params: params
      params = startRideParams
      post '/start_ride', params: params
      params = endRideParams
      post '/end_ride', params: params 
    end
    it 'should not calculate extra color preference fare when the customer did not opt for it' do
      params = getFareParams
      post '/get_fare', params: params
      parse_json = JSON(response.body)
      extra_cost = parse_json['extra_cost']
      pink_pref_on_ride = Ride.find_by(id: params['ride_id']).pink_pref
      if pink_pref_on_ride
        expect(extra_cost).to eq 5
      else
        expect(extra_cost).to eq 0
      end
    end
  end
end
