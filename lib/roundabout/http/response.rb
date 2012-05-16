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

#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
#
class Roundabout::HTTP::Response
    # @return   [Integer]   response code
    attr_reader :code

    # @return   [String]   effective url
    attr_reader :url

    # @return   [String]   response body
    attr_reader :body

    # @return   [Hash]   response headers
    attr_reader :headers

    # @param    [Hash]    opts
    def initialize( opts )
        opts.each { |k, v| instance_variable_set( "@#{k}".to_sym, v ) }
    end
end
