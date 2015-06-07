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
In this version added distance field to each point. Distance is calculated on record save

### Important!
To provide compatibility with old records (without distance) in database special
method `ensure_value_has_distance_and_elevation_and_save!` was added to trace model.

Now its called on each GET request to caluculate distance and get elevation if necessary.

You need to run the calculation process in background to update all old records to new format and then remove
this method. You can use following rake task for that:

```ruby
rake trace:update_records
```

