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
# Implements a distribution policy for extracted paths.
#
# Put simply, decides which crawler peer should be assigned which paths.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
#
class Roundabout::Distributor

    #
    # Do not manipulate!
    #
    # @return    [Array<Crawler>]   {Crawler}s or RPC clients to them
    #
    attr_reader :peers

    #
    # @param    [Array<Crawler>]   peers   {Crawler}s or RPC clients to them
    #                                           -- need to have {Crawler#push}
    #                                           and {Crawler#peer_url} methods
    #
    def initialize( peers = [] )
        @peers = []
        add_peers( peers )
    end

    # @return [Array<String>]   URLS of all peers
    def peer_urls
        @peers.map { |p| p.peer_url }
    end

    # @param    [Array<Crawler>]   peers   {Crawler}s or RPC clients to them
    def add_peers( peers )
        @peers = merge_peers( [peers].flatten )
    end

    #
    # Distributes the paths to the peers
    #
    # @param    [Array<String]  urls    to distribute
    #
    def distribute( urls )
        tries = 5

        routed = {}
        urls.each { |url| (routed[route( url )] ||= []) << url }
        routed.each do |peer, r_urls|
            begin
                peer.push( r_urls ){}
            rescue Exception
                tries -= 1
                retry if tries > 0
            end
        end
        true
    end

    private
    def route( url )
        return if !url || url.empty?
        return @peers.first if @peers.size == 1
        @peers[url.bytes.inject( :+ ).modulo( @peers.size )]
    end

    #
    # Merges given peers with existing ones returns a sorted array.
    #
    # Sorting is important as the array needs to be in the same order across all nodes.
    #
    # @param    [Array<Crawler>]   peers   {Crawler}s or RPC clients to them
    #
    # @return   [Array<Crawler>]   {Crawler}s or RPC clients to them
    #
    def merge_peers( peers )
        crawlers = {}
        (@peers | peers).each { |p| crawlers[p.peer_url] = p }
        Hash[crawlers.sort].values
    end

end
