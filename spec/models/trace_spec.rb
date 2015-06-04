require 'spec_helper'

module TracesApi
  describe Trace do
    before { Trace.all.destroy_all }

    it 'creates new record' do
      expect { Trace.create attributes_for :trace1 }.to change { Trace.count }.from(0).to(1)
    end

    it 'validates presence of value' do
      trace = Trace.new
      expect(trace).not_to be_valid
      expect(trace.errors[:value]).to eq ['can\'t be blank']
    end

    it 'validates that value is valid array of points' do
      [
        [{"longitude" => 78.58, "latitude" => 125.545}, "text"],                                                            # not hash
        [{"longitude" => 78.58, "latitude" => 125.545}, {"not-longitude" => 78.58,"latitude" => 125.545}],                  # invalid title (not-longitude)
        [{"longitude" => 78.58, "latitude" => 125.545}, {"latitude" => 125.545}],                                           # missed longitude
        [{"longitude" => 78.58, "latitude" => 125.545}, {"apptitude" => 78.59,"longitude" => 78.58,"latitude" => 125.545}], # extra title (apptitude)
        [{"longitude" => 78.58, "latitude" => 125.545}, {"longitude" => "seventeen","latitude" => 125.545}]                 # not a number value
      ].each do |bad_value|
        trace = Trace.new value: bad_value
        expect(trace).not_to be_valid
        expect(trace.errors[:value]).to eq ['is not an array of gps points']
      end
    end

    it 'allowes valid arrays of points' do
      [
        [{"longitude" => 78.58,"latitude" => 125.545}],
        [{"longitude" => 78.58,"latitude" => 125}],
        [{"longitude" => 78.58, latitude: 125.545}],
        [{"longitude" => 78.58,"latitude" => 125.545}, {"longitude" => 78.58,"latitude" => 125.545}],
      ].each { |good_value| expect(Trace.new value: good_value).to be_valid }
    end
  end
end
