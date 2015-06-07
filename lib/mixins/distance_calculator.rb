require 'geo-distance'

module DistanceCalcualtor
  def value_has_distances?
    value.map do |point|
      point.has_key?(:distance) or point.has_key?('distance')
    end.all?
  end

  def ensure_value_has_distance!
    return if value_has_distances?
    self.value.map! &:symbolize_keys!
    self.value.first.merge! distance: 0
    current_distance = 0
    (1..value.count-1).each do |i|
      current_distance += distance_between_points(value[i], value[i-1])
      self.value[i].merge! distance: current_distance.to_i
    end
  end


  def distance_between_points p1, p2
    GeoDistance::Haversine.geo_distance(p1[:latitude], p1[:longitude], p2[:latitude], p2[:longitude]).to_meters
  end
end
