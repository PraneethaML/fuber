module ApiParams  
  def bookCabInvalidParams
    {
      "cust_src_lat"  => 0,
      "cust_src_long" => 1,
      "cust_dest_lat" => 2,
      "cust_dest_long" => 0,
      "pink_preference" => false
    }
  end

  def bookCabParams
    {
      "src_lat"  => 0,
      "src_long" => 1,
      "dest_lat" => 2,
      "dest_long" => 0,
      "pink_pref" => true
    }
  end

  def acceptRideParams
    {
      "cust_src_lat"  => 1,
      "cust_src_long" => 1,
      "cust_dest_lat" => 2,
      "cust_dest_long" => 2,
      "pink_pref" => false,
      "cab_id" => 1
    }
  end

  def startRideParams 
    {
      "src_lat" => 1,
      "src_long" => 0,
      "cab_id" => 1,
      "ride_id" => 1 
    }
  end

  def endRideParams 
    {
      "dest_lat" => 1,
      "dest_long" => 0,
      "cab_id" => 1,
      "ride_id" => 1  
    }
  end

  def getFareParams 
    {
      "ride_id" => 1
    }
  end

end