require 'mongoid'

class GPSPointsValidator < ActiveModel::Validator
  def validate(record)
    if record.value.present?
      unless has_only_gps_points?(record.value)
        record.errors[:value] << 'is not an array of gps points'
      end
    end
  end

  private

  ALLOWED_KEYS = [:latitude, :longitude, :distance, :elevation]
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
  before_save :ensure_value_has_elevation!

  def as_json options
    if valid?
      {"id" => id.to_s,"value" => value}
    else
      {"errors" => errors}
    end
  end

  # This method is added to add distances and elevations to old records if they are requested
  # TODO: Remove this method after all old records in db are saved with distances and elevations
  def ensure_value_has_distance_and_elevation_and_save!
    save unless value_has_distances? && value_has_elevations?
    self
  end

  private

  include DistanceCalcualtor
  include ElevationLoader

end
