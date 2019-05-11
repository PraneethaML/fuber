Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

post '/book_cab' => 'fuber#bookCab' 
# post '/accept_ride' => 'fuber#acceptRide'
post '/start_ride' => 'fuber#startRide'
post '/end_ride' => 'fuber#endRide'
post '/get_fare' => 'fuber#getFare'
get '/available_cabs' => 'fuber#getAvailableCabs'
end

