require 'rest-client'

module ElevationLoader
  def value_with_only_coords
    value.map {|p| p.symbolize_keys.slice :latitude, :longitude }
  end

  def ensure_value_has_elevation!
    return if value_has_elevations?
    response = RestClient.post 'https://codingcontest.runtastic.com/api/elevations/bulk',
                               value_with_only_coords.to_json,
                               content_type: 'application/json'
    JSON.parse(response).each.with_index do |elevation, i|
      self.value[i].merge! elevation: elevation
    end
  end


  def value_has_elevations?
    value.map do |point|
      point.has_key?(:elevation) or point.has_key?('elevation')
    end.all?
  end
end
