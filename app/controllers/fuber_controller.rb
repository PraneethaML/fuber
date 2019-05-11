class FuberController < ApplicationController
	protect_from_forgery with: :null_session

	def bookCab
		src_lat = params[:src_lat]
		src_long = params[:src_long]
		dest_lat = params[:dest_lat]
		dest_long = params[:dest_long]
		pink_pref = params[:pink_pref]

		if pink_pref
			isPinkCabAvailable = checkPinkCabsAvailability
			if isPinkCabAvailable
				assigned_cab = getClosestPinkCab(src_lat, src_long)
				render json: '{"message" => "success! cab assigned id #{assigned_cab}" assigned_cab}', status: :ok
			else
				render json: "{sorry couldn't find cab}", status: :unprocessable_entity
			end
			
		else
			isCabAvailable = checkCabsAvailability
			if isCabAvailable
				assigned_cab = getClosestCab(src_lat, src_long)
				render json: "{success! assigned cab id}: #{assigned_cab}", status: :ok		
			else
				render json: "{failure! sorry couldn't find cabs}", status: :unprocessable_entity
			end
		end
	end


	def checkPinkCabsAvailability
		pink_cabs_count = Cab.where(:is_pink => true).count
		return true if pink_cabs_count > 0
	end

	def checkCabsAvailability
		available_cabs_count = Cab.where(:is_available => true).count
		return true if available_cabs_count > 0
	end

	def getClosestPinkCab(src_lat,src_long)
		available_pink_cabs = Cab.where(:is_pink => true)
		distance = {}
		for cab in available_pink_cabs
			lat_diff_sq = (cab.lat - src_lat) ** 2
			long_diff_sq = (cab.long - src_long) ** 2
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
			pink_preference: cust_pink_pref,
			cab_id: cab_id
			)
		cab = Cab.find_by(id: cab_id)
		cab.update_attributes!(is_available: false)

		lat_diff_sq = (dest_lat.to_i - src_lat.to_i) ** 2
		long_diff_sq = (dest_long.to_i - src_long.to_i) ** 2
		distance_to_cover  = Math.sqrt(lat_diff_sq + long_diff_sq)

		Ride.create!(
			cab_id: cab.id,
			customer_id: customer.id,
			dist_travelled: distance_to_cover
			pink_pref: cust_pink_pref
			)
		render json: "{going to customer location}", status: :ok
	end

	def startRide
		if(params.has_key?(:src_lat) && params.has_key?(:src_long) && params.has_key?(:cab_id) && params.has_key?(:customer_id))
			cust_src_lat = params[:src_lat]
			cust_src_long = params[:src_long]
			cab_id = params[:cab_id]
			customer_id = params[:customer_id]
			Ride.update_attributes!(:ride_start_time) = Time.now
			Cab.update_attributes!(lat: src_lat ,long: src_long)
			render json: '{"message" => "Ride started!"}', status: :ok
		else
			render json: '{"message" => "Sorry! Unable to start ride."}', status: :unprocessable_entity
		end
	end

	def endRide
		if(params.has_key?(:dest_lat) && params.has_key?(:dest_long) && params.has_key?(:cab_id) && params.has_key?(:customer_id))
			cust_src_lat = params[:dest_lat]
			cust_src_long = params[:dest_long]
			cab_id = params[:cab_id]
			customer_id = params[:customer_id]
			Ride.update_attributes!(:ride_end_time) = Time.now
			Cab.update_attributes!(lat: dest_lat ,long: dest_long, is_available: true)
			render json: '{"message" => "Ride ended!"}', status: :ok
		else
			render json: '{"message" => "Sorry! Unable to end ride."}', status: :unprocessable_entity
		end
	end

	def get_fare
		if(params.has_key?(:ride_id))
			ride = Ride.find_by(:ride_id)
			if ride.nil?	
				render json: '{"message" => "Sorry! Unable to find ride with the given id."}', status: :unprocessable_entity
			else
				distance_covered = ride.dist_travelled
				time_taken = ((ride.ride_end_time - ride.ride_start_time)/60).to_i
			end
		else
			render json: '{"message" => "Sorry! Unable to calculate the error."}', status: :unprocessable_entity
		end
	end

end

