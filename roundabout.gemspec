# -*- encoding: utf-8 -*-
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

$:.push File.expand_path( '../lib', __FILE__ )
require 'roundabout/version'

Gem::Specification.new do |s|
    s.name        = "roundabout"
    s.version     = Roundabout::VERSION
    s.authors     = ["Tasos 'Zapotek' Laskos"]
    s.email       = %w(tasos.laskos@gmail.com)
    s.homepage    = ""
    s.summary     = %q{TODO: Write a gem summary}
    s.description = %q{TODO: Write a gem description}
    s.files       = Dir.glob("lib/**/**")

    s.test_files    = %w(spec)
    s.executables   = Dir.glob("bin/*").map { |p| p.gsub( 'bin/', '' ) }
    s.require_paths = %w(lib)

    s.add_development_dependency 'rspec'
    s.add_development_dependency 'yard'
    s.add_development_dependency 'redcarpet'
    s.add_development_dependency 'awesome_print'

    s.add_runtime_dependency 'nokogiri'
    s.add_runtime_dependency 'arachni-rpc-em'
    s.add_runtime_dependency 'em-http-request'
end
