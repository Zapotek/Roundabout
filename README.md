# Roundabout - A high-performance, distributed crawler

The Roundabout crawler is an experiment on high-performance distributing techniques and their feasibility
when it comes to website crawling.

The name comes from the overall philosophy of the system which is to bypass
decision making points and instead focus on an intuitive prioritization and distribution algorithm.

## Usage

### Single mode

In single mode the roundabout algorithm is in essence no different that any other basic algorithm.

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

_Comming soon..._

## License
Roundabout is licensed under the Apache License Version 2.0.<br/>
See the [LICENSE](file.LICENSE.html) file for more information.


## Author
Copyright 2012 Tasos Laskos <tasos.laskos@gmail.com>
