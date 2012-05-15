=begin
    Copyright 2012 Tasos Laskos <tasos.laskos@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
=end

require 'rubygems'
require 'bundler/setup'

# define all namespaces here so that we won't have
# to keep re-opening their modules/containers
module Roundabout
    module RPC
    end

    class HTTP
        class Response
        end
    end
end

# require everything and be done with it, we need them all anyways
Dir.glob( File.dirname( __FILE__ ) + '/**/*.rb' ).each { |p| require p }
