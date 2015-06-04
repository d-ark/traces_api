# TracesApi

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'traces_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install traces_api

## Usage

You can run this app as simple Rack app:

    $ rackup

It provides full REST API for resource trace. The following routes are allowed:

```
  GET /traces         # get list of traces
  GET /traces/:id     # get trace by id
  POST /traces        # create trace
  POST /traces/:id    # update trace
  DELETE /traces/:id  # remove trace
```
