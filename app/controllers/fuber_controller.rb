class FuberController < ApplicationController
	protect_from_forgery with: :null_session

	
	def getAvailableCabs
		@cabs = Cab.where(:is_available => true)
		render 'available_cabs'

		# for api use below code 
		
		# total_available_cabs = cabs.count
		# cab_ids = cabs.pluck(:id)
		# if total_available_cabs > 0
		# 	render json: {"message" => "#{total_available_cabs} found near you", "cab_ids" => "#{cab_ids}"}.to_json, status: :ok
		# else
		# 	render json: {"message" => "No cabs found near you"}.to_json, status: :unprocessable_entity
		# end
		
	end

	def bookCab	
		required = [:src_lat, :src_long, :dest_lat, :dest_long, :pink_pref]
		if required.all? {|k| params.has_key? k}
			src_lat = params[:src_lat]
			src_long = params[:src_long]
			dest_lat = params[:dest_lat]
			dest_long = params[:dest_long]
			pink_pref = params[:pink_pref]

			if pink_pref
				isPinkCabAvailable = checkPinkCabsAvailability
				if isPinkCabAvailable
					assigned_cab = getClosestPinkCab(src_lat, src_long)	
					render json: {"message" => "success! cab assigned", "cab_id" => "#{assigned_cab}"}.to_json, status: :ok
				else
					render json: {"message" => "sorry couldn't find cab"}.to_json, status: :unprocessable_entity
				end
				
			else
				isCabAvailable = checkCabsAvailability
				if isCabAvailable
					assigned_cab = getClosestCab(src_lat, src_long)
					render json: {"message" => "success! assigned cab" , "cab_id" => "#{assigned_cab}"}.to_json, status: :ok		
				else
					render json: {"message" => "failure! sorry couldnt find cabs"}.to_json, status: :unprocessable_entity
				end
			end
		else
			render json: {"message" => "failure! Invalid input"}.to_json, status: :unprocessable_entity
		end	
	end

	def checkPinkCabsAvailability
		pink_cabs_count = Cab.where(:is_pink => true, :is_available => true).count
		return true if pink_cabs_count > 0
	end

	def checkCabsAvailability
		available_cabs_count = Cab.where(:is_available => true).count
		return true if available_cabs_count > 0
	end

	def getClosestPinkCab(src_lat,src_long)
		available_pink_cabs = Cab.where(:is_pink => true, :is_available => true)
		distance = {}
		for cab in available_pink_cabs
			lat_diff_sq = (cab.lat.to_i - src_lat.to_i) ** 2
			long_diff_sq = (cab.long.to_i - src_long.to_i) ** 2
			distance[cab.id] = Math.sqrt(lat_diff_sq + long_diff_sq)
		end
		distance.key(distance.values.min)

	end

	def getClosestCab(src_lat,src_long)
		available_cabs = Cab.where(:is_available => true)
		distance = {}
		for cab in available_cabs
			lat_diff_sq = ((cab.lat).to_i - (src_lat).to_i) ** 2
			long_diff_sq = ((cab.long).to_i - (src_long).to_i) ** 2
			distance[cab.id] = Math.sqrt(lat_diff_sq + long_diff_sq)
		end
		distance.key(distance.values.min)
	end

	def acceptRide
		cust_src_lat = params[:src_lat]
		cust_src_long = params[:src_long]
		cust_dest_lat = params[:dest_lat]
		cust_dest_long = params[:dest_long]
		cust_pink_pref = params[:pink_pref]
		cab_id = params[:cab_id]
		
		customer = Customer.create!(
			src_lat: cust_src_lat,
			src_long: cust_src_long,
			dest_lat: cust_dest_lat,
			dest_long: cust_dest_long,
			cab_id: cab_id
			)
		cab = Cab.find_by(id: cab_id)
		cab.update_attributes!(is_available: false)

		lat_diff_sq = (cust_dest_lat.to_i - cust_src_lat.to_i) ** 2
		long_diff_sq = (cust_dest_long.to_i - cust_src_long.to_i) ** 2
		distance_to_cover  = Math.sqrt(lat_diff_sq + long_diff_sq)

		ride = Ride.create!(
			cab_id: cab.id,
			customer_id: customer.id,
			dist_travelled: distance_to_cover,
			pink_pref: cust_pink_pref
			)
		render json: {"message" => "going to customer location", "ride_id" => ride.id}.to_json, status: :ok
	end

	def startRide
		if(params.has_key?(:src_lat) && params.has_key?(:src_long) && params.has_key?(:ride_id) && params.has_key?(:cab_id))
			cust_src_lat = params[:src_lat]
			cust_src_long = params[:src_long]
			ride_id = params[:ride_id]
			cab_id = params[:cab_id]
			
			ride = Ride.find_by(:id => ride_id)

			if ride.nil? || ride.ride_start_time != nil || ride.ride_end_time != nil
				render json: {"message" => "Invalid ride. Please check your ride details"}.to_json, status: :unprocessable_entity
			else
				ride.update_attributes!(ride_start_time: Time.now)
				cab = Cab.find_by(:id => cab_id)
				cab.update_attributes!(lat: cust_src_lat ,long: cust_src_long)
				
				render json: {"message" => "Ride started!"}.to_json, status: :ok
			end
		else
			render json: {"message" => "Sorry! Unable to start ride."}.to_json, status: :unprocessable_entity
		end
	end

	def endRide
		if(params.has_key?(:dest_lat) && params.has_key?(:dest_long) && params.has_key?(:cab_id) && params.has_key?(:ride_id))
			cust_dest_lat = params[:dest_lat]
			cust_dest_long = params[:dest_long]
			cab_id = params[:cab_id]
			ride_id = params[:ride_id]

			ride = Ride.find_by(:id => ride_id)

			if ride.nil? || ride.ride_start_time == nil || ride.ride_end_time != nil
				render json: {"message" => "Invalid ride. Please check your ride details"}.to_json, status: :unprocessable_entity
			else
				ride.update_attributes!(ride_end_time: Time.now)
				
				cab = Cab.find_by(:id => cab_id)
				cab.update_attributes!(lat: cust_dest_lat ,long: cust_dest_long, is_available: true)
				
				render json: {"message" => "Ride ended!"}.to_json, status: :ok
			end	
		else
			render json: {"message" => "Sorry! Unable to end ride."}.to_json, status: :unprocessable_entity
		end
	end

	def getFare
		if(params.has_key?(:ride_id))
			ride = Ride.find_by(:id => params[:ride_id])
			if ride.nil?	
				render json: {"message" => "Sorry! Unable to find ride with the given id."}.to_json, status: :unprocessable_entity
			else
				distance_covered = ride.dist_travelled
				time_taken = ((ride.ride_end_time - ride.ride_start_time)/60).to_i
				pink_pref = ride.pink_pref
				fare = 0
				if pink_pref
				 	# 1 dogecoin per minute, and 2 dogecoin per kilometer. Pink cars cost an additional 5 dogecoin.
					fare = (time_taken * 1) + (distance_covered * 2) + 5
					render json: {"message" => "You owe total #{fare} dogecoins", "extra_cost" => 5}.to_json, status: :ok
				else
					fare = (time_taken * 1) + (distance_covered * 2)
					render json: {"message" => "You owe total #{fare} dogecoins", "extra_cost" => 0}.to_json, status: :ok
				end 
			end
		else
			render json: {"message" => "Sorry! Unable to calculate the error."}.to_json, status: :unprocessable_entity
		end
	end

end

