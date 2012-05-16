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
    s.homepage    = "https://github.com/Zapotek/Roundabout"
    s.summary     = %q{High-performance, distributed crawler.}
    s.description = %q{The Roundabout crawler is an experiment on high-performance
    distributing techniques and their feasibility when it comes to website crawling.

    The name comes from the overall philosophy of the system which is to bypass
decision making points and instead focus on an intuitive prioritization and distribution algorithm.}
    s.files       = Dir.glob("lib/**/**")

    s.test_files    = %w(spec)
    s.executables   = Dir.glob("bin/*").map { |p| p.gsub( 'bin/', '' ) }
    s.require_paths = %w(lib)

    s.add_development_dependency 'rspec'
    s.add_development_dependency 'yard'
    s.add_development_dependency 'redcarpet'
    s.add_development_dependency 'awesome_print'

    s.add_runtime_dependency 'nokogiri'
    s.add_runtime_dependency 'typhoeus'
    s.add_runtime_dependency 'arachni-rpc-em'
end
