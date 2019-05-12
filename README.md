
# README

* Ruby version  - 2.4.2

* Instructions to run the application
	- `git clone https://github.com/PraneethaML/fuber.git`
	- `cd fuber_app/`
	- `bundle install`
	- `rails s` 

* How to run the test suite
	-  `rspec spec/request/api_spec.rb`

* Details on the code 
		
	-  It has 3 models 
		- Ride : to store details of the trip 
			- A new is created whenever driver accepts the ride
				- Pink preference of the customer, distance from source to destination is saved as soon as the ride is created. These cols help us in calculating the fare

			- Ride details will get updated as the ride progresses
				- On starting a ride ride_start time will be updated
				- On ending a ride ride_end_time will be updated

		- Customer: is used to store details of the customer like source, destination, preference for pink
			- A new record for customer is created as soon as the driver accepts the ride

		- Cab: We assume that some cabs are signed up with fuber already(create some sample cab records from rails console)

		- This database architecture is as follows for this application

			- Ride belongs_to Cab & Customer
			- Customer has_many Rides
			- Cab has_many Rides

	- Logic of the application is written in fuber_controller
		- fuber_app/app/controllers/fuber_controller.rb

		- Gist of each method in the controller 
			- getAvailableCabs: Searches for all the available cabs in the app and 		     				returns their cab_id to the view where it is displayed

			- bookCab: Takes customer source and destination location and their        			   preference for pink car as input parameters and returns the 			   	   cab that is assisgned

		    - checkPinkCabsAvailability: It check for available pink cabs and returns a 							boolean value based on the search

		    - checkCabsAvailability: It checks for all the available cabs and returns a 						 boolean value

		    - getClosestPinkCab: It takes customer source location as parameters and 						 searches for the nearest pink cab available. Since we 						 assumed earth is flat it uses distance formula of 							 coordinate geometry based on pythogoras theorem ie 						 sq.root (x2-x1)^2 + (y2-y1)^2

		    - getClosestCab: It takes customer's source location as parameters and 						 searches for the nearest available cab

		    - acceptRide: It takes customer source and destination and their preference 			  for pink as parameters. It creates a new Ride record with the 			  given details. Also since the driver accepted the trip it 				  makes that cab as unavailable

		    - startRide: It takes customer source location as parameters. It updates 				 Ride record with start time, and also since the cab is now 				 ready to pickup at customer place, updates cab location to 				 customer's source location

		    - endRide: It takes customer destination location as parameters. It updates 		   Ride record with end time, and also since the cab dropped the 			   customer at their destination, it updates cab location to   				   customer destination and makes it available for the next ride 

		    - getFare: It takes the ride_id as input and calculates the fare accordingly 			based on the information available in ride record 

* Api calls
		
		<!-- renders available_cabs.html -->
		- get /available_cabs 
			{ 2,3,4} 

		<!-- customer enters source and destination and tries to book a cab -->
		- POST /book_cab
			params: 
			{
				"src_lat" : 8,
				"src_long": 2,
				"dest_lat": 4,
				"dest_long":0,
				"pink_pref": false
			}
			Response: 
			{
			    "message": "success! assigned cab",
			    "cab_id": "3"
			}

		<!-- Driver of Cab 3 gets a notification and accepts the ride-->
		- POST /accept_ride
			params:
			{
				"cust_src_lat" : 1,
				"cust_src_long": 1,
				"cust_dest_lat": 2,
				"cust_dest_long":2,
				"pink_pref": false,
				"cab_id": 3,
				"cust_id": 1
			}
			Response: 
			{
			    "message": "going to customer location",
			    "ride_id": 14
			}

		<!--  Driver goes to customer location and customer hops in. Starts the ride!-->
		- POST /start_ride
			params:
			{
				"src_lat": 1,
				"src_long": 1,
				"cab_id": 3,
				"ride_id": 14	
			}
			Response:
			{
			    "message": "Ride started!"
			}

		<!-- Driver reaches the destination and ends the ride. -->
		- POST /end_ride
			params:
			{
				"dest_lat": 2,
				"dest_long": 2,
				"cab_id": 3,
				"ride_id": 14	
			}
			Response:
			{
			    "message": "Ride ended!"
			}

		<!-- Driver requests for fare -->
		- POST /get_fare
			params:
			{
				"ride_id": 14
			}
			Response:
			{
			    "message": "You owe total 7 dogecoins",
			    "extra_cost": 0
			}

* Future Enhancements 
	
	- Frontend:
		- Add screen for customer to book the cab
			- On clicking the `book cab` button it should trigger /book_cab api
		
		- Add screens for Driver to accept, start, end the ride and get fare 
			- Have the buttons for all those actions which triggers their api    	respectively

		- Add background image of a map(using google maps api) on `available_cabs` view and show the cabs and customer at their respective locations

	- Backend 
		- Enable customer and driver authentication

		- When the data for cabs is more, it becomes inefficient to calculate the distance of all available cabs and then find the closest. Instead we can put a limit on radius and search closest cabs in that radius.


* ...

# fuber
