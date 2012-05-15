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

require 'arachni/rpc/em'

#
# Exports the API of a remote {Crawler} instance over an RPC protocol (in this case, Arachni-RPC).
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
#
class Roundabout::RPC::Client

    class Mapper < ::Arachni::RPC::RemoteObjectMapper
        def peer_url
            @server.opts[:host] + ':' + @server.opts[:port].to_s
        end

        def respond_to?( sym )
            sym == peer_url || super( sym )
        end
    end

    #
    # @param    [String]    url     to connect to
    # @param    [Hash]      opts
    #
    # @return   [Arachni::RPC::RemoteObjectMapper]    {Crawler} API over RPC
    #
    def self.connect( url, opts = {} )
        host, port = url.split( ':' )
        client = ::Arachni::RPC::EM::Client.new(  host: host, port: port )
        Mapper.new( client, 'crawler' )
    end

    def self.connect_to_node( url, opts = {} )
        host, port = url.split( ':' )
        client = ::Arachni::RPC::EM::Client.new(  host: host, port: port )
        Mapper.new( client, 'node' )
    end
end
