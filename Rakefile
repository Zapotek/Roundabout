require 'bundler/gem_tasks'

task :docs do

    outdir = "../roundabout-doc"
    sh "mkdir #{outdir}" if !File.directory?( outdir )

    sh "yardoc --verbose --title \
       \"Roundabout v#{Roundabout::VERSION} - A high-performance, distributed crawler\" \
       lib/* \
       - LICENSE.md\
       -o #{outdir}"

    sh "rm -rf .yard*"
end
