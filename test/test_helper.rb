require 'rubygems'
require 'ruby-debug'
require 'fakeweb'
require 'test/unit'

$: << File.expand_path('../../lib', __FILE__)
require 'drifter'

  
# nodoc
def open_web_response(filename)
  path_to_file = [File.dirname(__FILE__), 'responses', filename].join('/')
  File.open(path_to_file, 'r') { |f| f.read }
end


# nodoc
def save_web_response(uri, filename)
  path_to_file = [File.dirname(__FILE__), 'responses', filename].join('/')
  response = Net::HTTP.get(uri.host, uri.request_uri)
  File.open(path_to_file, 'w') { |f| f.write response }
end
