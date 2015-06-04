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

  ALLOWED_KEYS = [:latitude, :longitude]

  def has_only_gps_points? array
    array.map do |point|
      point.is_a?(Hash) &&
      point.symbolize_keys.keys.sort == ALLOWED_KEYS &&
      point.values.map {|v| v.is_a? Numeric }.all?
    end.all?
  end
end


class Trace
  include Mongoid::Document
  field :value, type: Array

  validates_presence_of :value
  validates_with GPSPointsValidator

  def as_json options
    if valid?
      {"id" => id.to_s,"value" => value}
    else
      {"errors" => errors}
    end
  end

end
