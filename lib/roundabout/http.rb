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

require 'em-http-request'

#
# Default HTTP interface
#
# Runs asynchronously for extra performance and uses EventMachine::HttpRequest.
#
# All HTTP instances passed to the {Crawler} must implement this API.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
#
class Roundabout::HTTP

    # @return   [Integer]   amount of requests which haven't yet gotten a response
    attr_reader :pending_requests

    #
    # @param    [Hash]  opts Connection, request and header options
    #                       * connection: EventMachine::HttpRequest connection options
    #                       * request: EventMachine::HttpRequest request options
    #                       * headers: request headers hash
    #
    def initialize( opts = {} )
        @default_headers = {
            'User-Agent' => 'Roundabout-crawler/' + Roundabout::VERSION.to_s
        }.merge( opts[:headers] || {} )

        @connection_options = {}.merge( opts[:connection] || {} )
        @request_options = {
            #redirects: 5,
            keepalive: true
        }.merge( opts[:request] || {} )

        @pending_requests = 0
    end

    #
    # @param    [Block]  block  to call once all requests have completed ({#pending_requests} == 0)
    #
    def on_complete( &block )
        raise 'Required block missing!' if !block_given?
        @on_complete = block
    end

    #
    # Performs a GET request
    #
    # @param    [String]    url
    # @param    [Hash]      opts    EventMachine::HttpRequest request options
    # @param    [Block]     block   to be passed the {Response}
    #
    def get( url, opts = {}, &block )
        request( :get, url, opts, &block )
    end

    private
    def request( method, url, opts = {}, &block )
        @pending_requests += 1
        opts[:head] ||= {}
        opts[:head].merge!( @default_headers )

        http = EventMachine::HttpRequest.new( url, @connection_options ).
            send( method, opts.merge( @request_options ) )

        decrement_counter = proc {
            @pending_requests -= 1
            call_on_complete if @pending_requests == 0
        }
        http.callback {
            block.call( Response.new( http ) )
            decrement_counter.call
        }
        http.errback {
            puts 'REQUEST ERROR!'
            decrement_counter.call
        }
    end

    def call_on_complete
        @on_complete.call if @on_complete
    end

end
