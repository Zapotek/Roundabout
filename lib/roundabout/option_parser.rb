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

require 'socket'
require 'uri'
require 'optparse'

class Roundabout::OptionParser

    BANNER = <<-BANNER
Roundabout v#{Roundabout::VERSION} - A high-performance, distributed crawler

Author:        Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Website:       <n/a>
Documentation: <n/a>

    BANNER

    #
    # Return a structure describing the options.
    #
    def self.parse( args )
        options = { host: 'localhost', port: 3733, peers: [] }

        OptionParser.new do |opts|
            opts.banner = BANNER + 'Usage: roundabout url [options]'

            opts.separator ""
            opts.separator "Specific options:"

            opts.on( "--host A", "Bind to host address A",
                     "(defaults to #{options[:host]})" ) do |a|
                options[:host] = a
            end

            opts.on( "--port N", Integer, "Listen on port N",
                     "(defaults to #{options[:port]})" ) do |n|
                options[:port] = n
            end

            opts.on( "--peer P", "Peer URL",
                     "(in the form of host:port)" ) do |p|
                options[:peers] << p
            end

            opts.separator ""
            opts.separator "Common options:"

            opts.on_tail( "-h", "--help", "Show this message" ) do
                puts opts
                exit
            end

            # Another typical switch to print the version.
            opts.on_tail( "--version", "Show version" ) do
                puts Roundabout::VERSION
                exit
            end
        end.parse!( args )

        puts Roundabout::OptionParser::BANNER
        url = args.pop

        invalid = false
        begin
            url = 'http://' + url if !URI( url ).host
        rescue
            invalid = true
        end

        if !invalid && valid_url?( url )
            options[:url] = url
        else
            puts 'Invalid URL or host unreachable.'
            exit
        end

        options
    end

    def self.valid_url?( url )
        if url && !url.to_s.empty?
            begin
                ::IPSocket.getaddress( URI( url ).host )
                true
            rescue
                false
            end
        end
    end

end
