module TracesApi
  class TracesApp < NYNY::App
    before { headers['Content-Type'] = 'application/json' }

    get '/' do
      {
        total_count: Trace.all.count,
        traces: Trace.all.limit(limit).skip(offset)
      }.to_json
    end

    get '/:id' do
      resque_from_not_found_error do
        Trace.find(params[:id]).to_json
      end
    end

    post '/' do
      trace = Trace.new trace_params
      status trace.save ? 201 : 422
      trace.to_json
    end

    post '/:id' do
      resque_from_not_found_error do
        trace = Trace.find(params[:id])
        status 422 unless trace.update trace_params
        trace.to_json
      end
    end

    delete '/:id' do
      resque_from_not_found_error do
        Trace.find(params[:id]).delete
        status 204
      end
    end

    private

    helpers do
      def trace_params
        { value: JSON.parse(request.body.read) }
      rescue JSON::ParserError
        { value: [] }
      end

      def resque_from_not_found_error &block
        yield
      rescue Mongoid::Errors::DocumentNotFound
        status 404
        {status: 404, error: 'trace not found'}.to_json
      end

      def limit
        users_limit = (params[:limit] || 10).to_i
        (1..100).include?(users_limit) ? users_limit : 10
      end

      def offset
        [(params[:offset] || 0).to_i, 0].max
      end

    end

  end
end
