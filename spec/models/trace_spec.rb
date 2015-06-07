require 'spec_helper'

module TracesApi
  describe Trace do
    before { Trace.all.destroy_all }

    it 'creates new record' do
      expect { Trace.create attributes_for :trace1 }.to change { Trace.count }.from(0).to(1)
    end

    describe 'validations' do
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
          [{"longitude" => 78.58,"latitude" => 125.545, "distance" => 0}],
          [{"longitude" => 78.58,"latitude" => 125.545, "elevation" => 780}],
          [{"longitude" => 78.58,"latitude" => 125}],
          [{"longitude" => 78.58, latitude: 125.545}],
          [{"longitude" => 78.58,"latitude" => 125.545}, {"longitude" => 78.58,"latitude" => 125.545}],
        ].each { |good_value| expect(Trace.new value: good_value).to be_valid }
      end
    end

    describe '#value_has_distances?' do
      it 'is false if at least one distance is not set' do
        trace = Trace.new value: [{latitude: 1, longitude: 1, distance: 0},
                                  {latitude: 2, longitude: 2},
                                  {latitude: 3, longitude: 3, distance: 78}]
        expect(trace.send :value_has_distances?).not_to be
      end
      it 'is true if at all distances are not set' do
        trace = Trace.new value: [{latitude: 1, longitude: 1, distance: 0},
                                  {latitude: 2, longitude: 2, distance: 13},
                                  {latitude: 3, longitude: 3, distance: 78}]
        expect(trace.send :value_has_distances?).to be
      end
    end

    describe '#ensure_value_has_distance!' do
      let(:trace) { build :trace1 }

      it 'is called after on saving record' do
        allow(trace).to receive :ensure_value_has_distance!
        trace.save
        expect(trace).to have_received(:ensure_value_has_distance!).once
      end

      it 'adds distance if it is not provided' do
        initial_value = [
          {"latitude" => 32.9377784729004, "longitude" => -117.230392456055},
          {"latitude" => 32.937801361084,  "longitude" => -117.230323791504},
          {"latitude" => 32.9378204345703, "longitude" => -117.230278015137},
          {"latitude" => 32.9378204345703, "longitude" => -117.230239868164},
          {"latitude" => 32.9378318786621, "longitude" => -117.230209350586},
          {"latitude" => 32.9378814697266, "longitude" => -117.230102539062},
          {"latitude" => 32.9378890991211, "longitude" => -117.230072021484},
          {"latitude" => 32.9379081726074, "longitude" => -117.230018615723},
          {"latitude" => 32.9379005432129, "longitude" => -117.22998046875 },
          {"latitude" => 32.937931060791,  "longitude" => -117.229949951172},
          {"latitude" => 32.9379615783691, "longitude" => -117.229919433594}
        ]

        result_value = [
          {latitude: 32.9377784729004, longitude: -117.230392456055, distance: 0},
          {latitude: 32.937801361084,  longitude: -117.230323791504, distance: 6},
          {latitude: 32.9378204345703, longitude: -117.230278015137, distance: 11},
          {latitude: 32.9378204345703, longitude: -117.230239868164, distance: 15},
          {latitude: 32.9378318786621, longitude: -117.230209350586, distance: 18},
          {latitude: 32.9378814697266, longitude: -117.230102539062, distance: 29},
          {latitude: 32.9378890991211, longitude: -117.230072021484, distance: 32},
          {latitude: 32.9379081726074, longitude: -117.230018615723, distance: 38}, # its 37 in sample. But it seems 38 is correct value
          {latitude: 32.9379005432129, longitude: -117.22998046875,  distance: 41},
          {latitude: 32.937931060791,  longitude: -117.229949951172, distance: 46},
          {latitude: 32.9379615783691, longitude: -117.229919433594, distance: 50}
        ]

        trace = Trace.new value: initial_value
        expect { trace.send :ensure_value_has_distance! }.to change { trace.value.to_json }
          .from(initial_value.to_json).to(result_value.to_json)
      end

    end

    describe '#value_has_elevations?' do
      it 'is false if at least one elevation is not set' do
        trace = Trace.new value: [{latitude: 1, longitude: 1, distance: 0, elevation: 1378},
                                  {latitude: 2, longitude: 2, distance: 13},
                                  {latitude: 3, longitude: 3, distance: 78, elevation: 1378}]
        expect(trace.send :value_has_elevations?).not_to be
      end
      it 'is true if at all elevations are not set' do
        trace = Trace.new value: [{latitude: 1, longitude: 1, distance: 0, elevation: 1378},
                                  {latitude: 2, longitude: 2, distance: 13, elevation: 1379},
                                  {latitude: 3, longitude: 3, distance: 78, elevation: 1378}]
        expect(trace.send :value_has_elevations?).to be
      end
    end


    describe '#ensure_value_has_elvation!' do
      let(:trace) { build :trace1 }

      it 'is called after on saving record' do
        allow(trace).to receive :ensure_value_has_elevation!
        trace.save
        expect(trace).to have_received(:ensure_value_has_elevation!).once
      end

      it 'adds elevation if it is not provided' do
        initial_value = [
          {"latitude" => 32.9377784729004, "longitude" => -117.230392456055},
          {"latitude" => 32.937801361084,  "longitude" => -117.230323791504}
        ]

        result_value = [
          {latitude: 32.9377784729004, longitude: -117.230392456055, elevation: 4139},
          {latitude: 32.937801361084,  longitude: -117.230323791504, elevation: 4139}
        ]

        trace = Trace.new value: initial_value
        expect { trace.send :ensure_value_has_elevation! }.to change { trace.value.to_json }
          .from(initial_value.to_json).to(result_value.to_json)
      end

    end


  end
end
