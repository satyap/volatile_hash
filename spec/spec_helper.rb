require 'rubygems'
require 'bundler/setup'

require 'volatile_hash'

RSpec.configure do |config|
      # some (optional) config here
      config.mock_with :rr
end

