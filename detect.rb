#!/usr/bin/ruby

require 'open-uri'
require 'net/http'
require 'json'

ORIGIN = 'http://localhost:4646/'

def request(cmd)
  JSON.parse(URI.open("#{ORIGIN}v1/#{cmd}").read)
end

def detect!(allocs)
  out = []
  index_collisions_cont = Hash.new{|hsh, key|
    hsh[key] = Hash.new{|h,k| h[k] = [] }
  }
  
  max_version = allocs.map{|j| j['JobVersion'] }.max
  allocs.each do |j|
    client_status = j['ClientStatus']
    next if client_status == 'complete' 
    id, version, name = j['ID'], j['JobVersion'], j['Name']
    if client_status == 'running'
      index_collisions_cont[version][name] << id
    end
  end

  has_collisions = false
  index_collisions_cont.each do |ver, index_collisions|
    index_collisions.each do |name, ids|
      next if ids.size == 1
      puts("Collision detected:" + " #{ver.to_s} #{name}: #{ids.join(', ')}")
      has_collisions = true
    end
  end
  
  exit 1 if has_collisions
end

id = 'fail'
detect!(request("job/#{id}/allocations"))

