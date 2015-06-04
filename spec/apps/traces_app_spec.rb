require 'spec_helper'

module TracesApi
  describe TracesApp do
    include Rack::Test::Methods
    let(:app) { described_class.new }

    describe 'GET /' do
      let :response do
        get '/'
        last_response
      end

      context 'when no traces are saved' do
        before { Trace.all.destroy_all }

        it('has status 200') { expect(response.status).to eq 200 }
        it('returns empty array'){ expect(response.body).to eq '{"total_count":0,"traces":[]}' }
      end

      context 'with 3 traces' do
        before do
          Trace.all.destroy_all
          create(:trace1)
          create(:trace2)
          create(:trace3)
        end

        it('has status 200') { expect(response.status).to eq 200 }

        it('returns array of traces') do
          traces_json = serialized_traces Trace.all
          expect(response.body).to eq "{\"total_count\":3,\"traces\":#{traces_json}}"
        end

        it('returns array of traces with limit') do
          get '/', limit: 2

          traces_json = serialized_traces Trace.all.to_a.first(2)

          expect(last_response.body).to eq "{\"total_count\":3,\"traces\":#{traces_json}}"
        end

        it('sets offset to 0 if it is < 0') do
          get '/', limit: 2, offset: -78
          traces_json = serialized_traces Trace.all.to_a.first(2)
          expect(last_response.body).to eq "{\"total_count\":3,\"traces\":#{traces_json}}"
        end

        it('returns array of traces with limit and offset') do
          get '/', limit: 2, offset: 1
          traces_json = serialized_traces Trace.all.to_a.last(2)
          expect(last_response.body).to eq "{\"total_count\":3,\"traces\":#{traces_json}}"
        end

        it('returns empty array if offset is too large') do
          get '/', limit: 2, offset: 78
          expect(last_response.body).to eq "{\"total_count\":3,\"traces\":[]}"
        end
      end

      context 'with 150 traces' do
        before do
          Trace.all.destroy_all
          while (Trace.all.count < 150)
            create(:trace1)
          end
        end

        it('sets limit to default(10) if it is not set') do
          get '/'
          data = JSON.parse last_response.body
          expect(data['traces'].count).to eq 10
        end

        it('sets limit to default(10) if it is invalid') do
          [nil, [], {}, -78, 0, 101, 'azaza'].each do |bad_value|
            get '/', limit: bad_value
            data = JSON.parse last_response.body
            expect(data['traces'].count).to eq 10
          end
        end

        it('uses provided limit if it is correct') do
          [1, 100, 51, '48', 26.0].each do |good_value|
            get '/', limit: good_value
            data = JSON.parse last_response.body
            expect(data['traces'].count).to eq good_value.to_i
          end
        end
      end
    end

    describe 'GET /:id' do
      let(:response) do
        get "/#{record.id}"
        last_response
      end
      context 'when record exists' do
        let(:record) { create :trace1 }

        it('has status 200') { expect(response.status).to eq 200 }
        it('has valid trace') { expect(response.body).to eq serialized_trace(record) }
      end

      context 'when record doesn\'t exist' do
        let(:record) { build :trace1 }

        it('has status 404') { expect(response.status).to eq 404 }
        it('has nice json error') { expect(response.body).to eq '{"status":404,"error":"trace not found"}' }
      end
    end

    describe 'POST /' do
      before {Trace.all.destroy_all}

      let(:response) do
        post "/", input_data
        last_response
      end

      context 'when provided correct trace data' do
        let(:input_data) { attributes_for(:trace1)[:value].to_json }

        it('has status 201') { expect(response.status).to eq 201 }
        it('creates record') do
          expect { post "/", input_data }.to change { Trace.count }.from(0).to(1)
          expect(Trace.first.value.to_json).to eq input_data
        end
        it('returns serialized record to user') do
          expect(response.body).to eq serialized_trace(Trace.first)
        end
      end

      context 'when provided data is empty' do
        let(:input_data) { '' }
        it('has status 422') { expect(response.status).to eq 422 }
        it('returns nice error') { expect(response.body).to eq '{"errors":{"value":["can\'t be blank"]}}'}
      end

      context 'when provided data is invalid' do
        let(:input_data) { '[{"latitude":"seven","longitude":78.965645}]' }
        it('has status 422') { expect(response.status).to eq 422 }
        it('returns nice error') { expect(response.body).to eq '{"errors":{"value":["is not an array of gps points"]}}'}
      end
    end

    describe 'POST /:id' do
      before {Trace.all.destroy_all}

      let(:response) do
        post "/#{record.id}", input_data
        last_response
      end

      context 'when provided correct trace data' do
        let(:record) { create :trace2 }
        let(:input_data) { attributes_for(:trace1)[:value].to_json }

        it('has status 200') { expect(response.status).to eq 200 }
        it('updates record') do
          expect { post "/#{record.id}", input_data }.to change { record.reload.value.to_json }.to(input_data)
        end
        it('returns serialized record to user') do
          expect(response.body).to eq serialized_trace(Trace.first)
        end
      end

      context 'when record doesn\'t exist' do
        let(:record) { build :trace1 }
        let(:input_data) { attributes_for(:trace1)[:value].to_json }

        it('has status 404') { expect(response.status).to eq 404 }
        it('has nice json error') { expect(response.body).to eq '{"status":404,"error":"trace not found"}' }
      end

      context 'when provided data is empty' do
        let(:record) { create :trace2 }
        let(:input_data) { '' }
        it('has status 422') { expect(response.status).to eq 422 }
        it('returns nice error') { expect(response.body).to eq '{"errors":{"value":["can\'t be blank"]}}'}
        it('doesn\'t update record') do
          expect { post "/#{record.id}", input_data }.not_to change { record.reload.value.to_json }
        end
      end

      context 'when provided data is invalid' do
        let(:record) { create :trace2 }
        let(:input_data) { '[{"latitude":"seven","longitude":78.965645}]' }
        it('has status 422') { expect(response.status).to eq 422 }
        it('returns nice error') { expect(response.body).to eq '{"errors":{"value":["is not an array of gps points"]}}'}
        it('doesn\'t update record') do
          expect { post "/#{record.id}", input_data }.not_to change { record.reload.value.to_json }
        end
      end

    end

    describe 'DELETE /:id' do
      let(:response) do
        delete "/#{record.id}"
        last_response
      end
      context 'when record exists' do
        let(:record) { create :trace1 }

        it('has status 204') { expect(response.status).to eq 204 }
        it('has empty response') { expect(response.body).to eq '' }
      end

      context 'when record doesn\'t exist' do
        let(:record) { build :trace1 }

        it('has status 404') { expect(response.status).to eq 404 }
        it('has nice json error') { expect(response.body).to eq '{"status":404,"error":"trace not found"}' }
      end
    end

    def serialized_traces array
      '[' + array.map { |t| serialized_trace t }.join(',') + ']'
    end
    def serialized_trace trace
      "{\"id\":\"#{trace.id.to_s}\",\"value\":#{trace.value.to_json}}"
    end
  end
end
