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
# Extracts paths (to be crawled) from HTML code.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
#
class Roundabout::PathExtractor

    def run( doc )
        URI.extract( doc.to_s, 'http' ) |
        doc.search( "//link[@href]" ).map { |a| a['href'] } |
        doc.search( "//a[@href]" ).map { |a| a['href'] } |
        doc.search( "//form[@action]" ).map { |a| a['action'] } |
        doc.css( 'frame', 'iframe' ).map { |a| a.attributes['src'].content rescue next } |
        doc.search( "//meta[@http-equiv='refresh']" ).
            map { |url| url['content'].split( ';' )[1].split( '=' )[1] }
    end

end
