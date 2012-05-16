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

require 'typhoeus'

#
# Default HTTP interface
#
# Runs asynchronously for extra performance and uses Typhoeus.
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
    #                       * connection: Typhoeus::Hydra options
    #                       * request: Typhoeus::Request options
    #                       * headers: request headers hash
    #
    def initialize( opts = {} )
        @default_headers = {
            'User-Agent' => 'Roundabout-crawler/' + Roundabout::VERSION.to_s
        }.merge( opts[:headers] || {} )

        @connection_options = {
            max_concurrency: 20
        }.merge( opts[:connection] || {} )

        @request_options = {
            follow_location:               true,
            max_redirects:                 5,
            disable_ssl_peer_verification: true
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
    # @param    [Hash]      opts    Typhoeus::Request options
    # @param    [Block]     block   to be passed the {Response}
    #
    def get( url, opts = {}, &block )
        request( :get, url, opts, &block )
    end

    def shutdown
        @hydra_thread.kill
    end

    private
    def request( method, url, opts = {}, &block )
        increase_pending
        opts[:headers] ||= {}
        opts[:headers].merge!( @default_headers )

        @hydra ||= Typhoeus::Hydra.new( @connection_options )
        req = Typhoeus::Request.new( url, @request_options.merge( opts.merge( method: method ) ) )
        req.on_complete {
            |res|
            block.call( Response.new(
                code: res.code,
                url: res.effective_url,
                headers: res.headers_hash,
                body: res.body
            ))
            decrease_pending
        }
        @hydra.queue( req )

        @hydra_thread ||= Thread.new { @hydra.run while sleep( 0.1 ) }
        true
    end

    def decrease_pending
        @pending_requests -= 1
        call_on_complete if @pending_requests == 0
    end

    def increase_pending
        @pending_requests += 1
    end

    def call_on_complete
        @on_complete.call if @on_complete
    end

end
