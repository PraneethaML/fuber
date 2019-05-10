class FuberController < ApplicationController

	def bookCab
		src_lat = params[:src_lat]
		src_long = params[:src_long]
		dest_lat = params[:dest_lat]
		dest_long = params[:dest_long]
		pink_pref = params[:pink_pref]

		if pink_pref
			isPinkCabAvailable = checkPinkCabsAvailability
			if isPinkCabAvailable
				getClosestPinkCab
				render json: "success! cab assigned", status: :ok
			else
				render json: "cannot find cabs", status: :unprocessable_entity
			end
			
		else
			isCabAvailable = checkCabsAvailability
			if isCabAvailable
				getClosestCab
				render json: "success! cab assigned", status: :ok		
			else
				render json: "success! cab assigned", status: :unprocessable_entity
			end
		end
	end


	def checkPinkCabsAvailability
	end

	def checkCabsAvailability
	end

	def getClosestPinkCab
	end

	def getClosestCab
	end

	def getFare
	end

	def endRide
	end

end

