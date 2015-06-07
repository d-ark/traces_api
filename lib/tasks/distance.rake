#!/bin/ruby

require 'traces_api'


namespace :trace do

  task :update_records do
    puts "Will check #{Trace.all.count} records. It can take a while. Stop it with Ctrl+C if necessary"

    Trace.all.to_a.map.with_index do |trace, i|
      trace.ensure_value_has_distance_and_elevation_and_save!!
      puts "Checked #{i} of #{Trace.all.count} records" if i%100 == 0 && i > 0
    end
  end
end
