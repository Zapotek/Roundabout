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

require 'ap'
require 'nokogiri'

#
# Crawls the target webapp until there are no new paths left.
#
# Path extraction and distribution are handled by outside agents.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
#
class Roundabout::Crawler
    include Roundabout::Utilities

    # @return [Hash]    instance options
    attr_reader :opts

    # @return [Set]    live sitemap, constantly updated during the crawl
    attr_reader :sitemap

    # @return HTTP interface in use
    attr_reader :http
    # @return path extractor in use
    attr_reader :path_extractor
    # @return distributor in use
    attr_reader :distributor

    #
    # @param    [Hash]  opts    instance options
    #                               * url: url to crawl
    #
    # @param    [Hash]  interfaces  custom interfaces to use
    #                               * http: must implement {Roundabout::HTTP} (defaults to {Roundabout::HTTP})
    #                               * path_extractor: must implement {Roundabout::PathExtractor} (defaults to {Roundabout::PathExtractor})
    #                               * distributor: must implement {Roundabout::Distributor} (defaults to {Roundabout::Distributor})
    #                               if no Distributor is provided no other nodes will be utilised.
    #
    def initialize( opts, interfaces = {} )
        @opts = opts
        @url  = @opts[:url]

        @sitemap = Set.new
        @paths = [ @url ]

        @http           = interfaces[:http] || Roundabout::HTTP.new( @opts )
        @path_extractor = interfaces[:path_extractor] || Roundabout::PathExtractor.new
        @distributor    = interfaces[:distributor] || Roundabout::Distributor.new( [self] )

        @on_complete_block = nil
        @after_run_block   = nil

        @done = false
        http.on_complete {
            next if !@paths.empty?
            @on_complete_block.call if @on_complete_block
            @done = true
        }
    end

    def done?
        @done
    end

    def sitemap_as_array
        sitemap.to_a
    end

    def on_complete( &block )
        raise 'Required block missing!' if !block_given?
        @on_complete_block = block
    end

    def peer_url
        @opts[:host] + ':' + @opts[:port].to_s
    end

    def after_run( &block )
        raise 'Required block missing!' if !block_given?
        @after_run_block = block
    end

    #
    # Performs the crawl
    #
    def run
        while url = @paths.pop
            puts 'Crawling: ' + url
            visited( url )

            http.get( url ) do |response|
                new_paths = extract_paths( response.body )
                puts ' ----------- ' + response.url +
                    ' [' + new_paths.size.to_s + ' new paths]'
                distributor.distribute( new_paths )
            end
        end

        @after_run_block.call if @after_run_block
        true
    end

    #
    # Pushes more paths to be crawled and wakes up the crawler
    #
    # @param    [String, Array<String>]     paths
    #
    def push( paths )
        @paths |= dedup( [paths] )
        run # wake it up if it has stopped
    end

    #
    # Rejects filter
    #
    # @param    [Block]     block   rejects URLs based on its return value
    #
    def reject( &block )
        raise 'Required block missing!' if !block_given?
        @reject_block = block
    end

    #
    # Decides whether or not to skip the given URL based on 3 factors:
    # * has the URL already been {#visited?}
    # * is the URL in the same domain? ({#in_domain?})
    # * does the URL get past the given {#reject} block? ({#reject?})
    #
    # @param    [String]    url
    #
    # @return   [TrueClass, FalseClass]
    #
    # @see #reject?
    # @see #reject
    # @see #visited?
    # @see #in_domain?
    #
    def skip?( url )
        !in_domain?( url ) || visited?( url ) || reject?( url )
    end

    #
    # @return   [TrueClass, FalseClass] does the URL get past the given {#reject} block?
    #
    # @see #reject
    #
    def reject?( url )
        return false if !@reject_block
        @reject_block.call( url )
    end

    #
    # @return   [TrueClass, FalseClass] is the URL in the same domain?
    #
    def in_domain?( url )
        begin
            @host ||= uri_parse( @url ).host
            @host == uri_parse( url ).host
        rescue Exception
            false
        end
    end

    #
    # @return   [TrueClass, FalseClass] has the URL already been visited?
    #
    def visited?( url )
        sitemap.include?( url )
    end

    private

    def visited( url )
        sitemap << url
    end

    def to_absolute( relative_url )
        begin
            # remove anchor
            relative_url = uri_encode( relative_url.to_s.gsub( /#[a-zA-Z0-9_-]*$/,'' ) )

            return relative_url if uri_parser.parse( relative_url ).host
        rescue Exception => e
            #ap e
            #ap e.backtrace
            return nil
        end

        begin
            base_url = uri_parse( @url )
            relative = uri_parse( relative_url )
            absolute = base_url.merge( relative )

            absolute.path = '/' if absolute.path && absolute.path.empty?

            absolute.to_s
        rescue Exception => e
            #ap e
            #ap e.backtrace
            return nil
        end
    end

    def extract_paths( html )
        dedup( path_extractor.run( Nokogiri::HTML( html ) ) ) rescue []
    end

    def dedup( urls )
        urls.flatten.compact.uniq.map { |path| to_absolute( path ) }.
            reject { |p| skip?( p ) }
    end

end
