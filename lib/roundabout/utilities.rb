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

require 'uri'
require 'webrick'

#
# General utilities
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
#
module Roundabout::Utilities
    def uri_parser
        @@uri_parser ||= ::URI::Parser.new
    end

    def uri_parse( url )
        begin
            uri_parser.parse( url )
        rescue ::URI::InvalidURIError
            uri_parser.parse( ::WEBrick::HTTPUtils.escape( url ) )
        end
    end

    def uri_encode( *args )
        uri_parser.escape( *args )
    end

    def uri_decode( *args )
        uri_parser.unescape( *args )
    end
end
