require 'mongoid'
require 'geo-distance'


class GPSPointsValidator < ActiveModel::Validator
  def validate(record)
    if record.value.present?
      unless has_only_gps_points?(record.value)
        record.errors[:value] << 'is not an array of gps points'
      end
    end
  end

  private

  ALLOWED_KEYS = [:latitude, :longitude, :distance]
  REQUIRED_KEYS = [:latitude, :longitude]

  def has_only_gps_points? array
    array.map do |point|
      point.is_a?(Hash) &&
      (REQUIRED_KEYS - point.symbolize_keys.keys).empty? &&
      (point.symbolize_keys.keys - ALLOWED_KEYS).empty? &&
      point.values.map {|v| v.is_a? Numeric }.all?
    end.all?
  end
end


class Trace
  include Mongoid::Document
  field :value, type: Array

  validates_presence_of :value
  validates_with GPSPointsValidator

  before_save :ensure_value_has_distance!

  def as_json options
    if valid?
      {"id" => id.to_s,"value" => value}
    else
      {"errors" => errors}
    end
  end

  # This method is added to add distances to old records if they are requested
  # TODO: Remove this method after all old records in db are saved with distances
  def ensure_value_has_distance_and_save!
    save unless value_has_distances?
    self
  end


  private

  def ensure_value_has_distance!
    return if value_has_distances?
    self.value.map! &:symbolize_keys!
    self.value.first.merge! distance: 0
    current_distance = 0
    (1..value.count-1).each do |i|
      current_distance += self.class.distance_between(value[i], value[i-1])
      self.value[i].merge! distance: current_distance.to_i
    end
  end


  def self.distance_between p1, p2
    GeoDistance::Haversine.geo_distance(p1[:latitude], p1[:longitude], p2[:latitude], p2[:longitude]).to_meters
  end

  def value_has_distances?
    value.map do |point|
      point.has_key?(:distance) or point.has_key?('distance')
    end.all?
  end

end
