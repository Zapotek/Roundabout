# Roundabout - A high-performance, distributed crawler

The Roundabout crawler is an experiment on high-performance distributing techniques and their feasibility
when it comes to website crawling.

The name comes from the overall philosophy of the system which is to bypass
decision making points and instead focus on an intuitive prioritization and distribution algorithm.

## Install dependencies

    git clone git://github.com/Zapotek/Roundabout.git
    cd Roundabout
    bundle install

## Usage

### Single mode

In single mode the roundabout algorithm is in essence no different that any other basic crawling algorithm.

    ./bin/roundabout testfire.net

This will crawl the website and return the sitemap.

### Distributed mode

This is where things get tricky...
In distributed mode the goal is to spread the workload across multiple nodes
so as to take advantage of their resources and enjoy a significant performance increase.

To setup multiple nodes on the same machine open up 2 terminal windows and on each run:

    ./bin/roundabout --port=1111 testfire.net

and

    ./bin/roundabout --peer localhost:1111 testfire.net

The first command will start a solitary node and the second one will start a second
node with the first one as its peer.
The 2 nodes will then reach convergence (i.e. negotiate to get to a level of shared knowledge).

To add one more node to the grid:

    ./bin/roundabout --port=2222 testfire.net --peer localhost:1111

The 3 nodes will then start exchanging information about each other and reach convergence once again.

Each node will output something like:

    Roundabout v0.0.1 - A high-performance, distributed crawler

    Author:        Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
    Website:       <n/a>
    Documentation: <n/a>


    Wait for more peers to join or hit "enter" to start the crawl.
    --- [JOIN] localhost:3733
    --- [JOIN] localhost:2222

The node that receives the coveted "enter" hit then becomes the master and starts
the crawl. Once the target URL is accessed and some preliminary paths are extracted
they are then spread across all available nodes and this will continue until
there are no more paths to be followed.

It is important to note that there is no centralized point of decision making and
that all peers are equals when it comes to workload distribution.
In fact, the algorithm is such that all peers have knowledge of the distribution
policy and when they spot a path that is out of their scope, they forward it to
the appropriate peer and then forget about it.
The receiving peer then decides whether to include that path on its workload
based on its own policies (if, for example, the path has already been followed, it will be ignored).

## Architecture

The system is naturally centered around the crawler, however the crawler by itself is
quite unimpressive and despite using asynchronous requests for some extra schnell
it doesn't do much else.

The crawler uses a few external agents to perform tasks like path extraction from
HTTP responses and workload distribution, with the latter being the focus of this project.

### Path extraction

Path extraction is handled by the PathExtractor class which basically parses the
HTTP response body and looks for full-fledged URLs and extracts paths from common
HTML attributes.

It is nothing fancy at all and it is completely interchangeable.

### HTTP interface

The system uses [EventMachine::HttpRequest](https://github.com/igrigorik/em-http-request) which due to its asynchronous model provides
respectable network IO performance for each node.

### Workload distribution

Distribution of workload is handled by the Distributor class.
The main responsibilities of the class is to implement an algorithm for somewhat
efficient (and predictable) distribution of paths across multiple nodes.

The currently implemented algorithm is very simple and basically computes the
ordinal sum of a path's characters modulo the amount of nodes.
The resulting integer is used as an index, identifying to which node to forward
the given path.

### Crawler

The Crawler class:

1. Performs HTTP requests for each path using the HTTP interface
2. Uses the PathExtractor to identify more paths
3. Sanitizes the new paths
4. Forwards them to the Distributor which feeds them back to the crawlers
5. Go to 1 until there are no more new paths

### Intra-grid communication

The nodes communicate with each other using the [Arachni-RPC EM](https://github.com/Arachni/arachni-rpc-em) protocol.

## License
Roundabout is licensed under the Apache License Version 2.0.<br/>
See the [LICENSE](file.LICENSE.html) file for more information.


## Author
Copyright 2012 Tasos Laskos <tasos.laskos@gmail.com>
