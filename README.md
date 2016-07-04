# Dijkstra's shortest path algorithm

A Ruby implementation to understand the Dijkstra algorithm.  The terminology is not super consistent.

Dijkstra is an algorithm for finding the shortest paths between nodes in a graph.

* Written in Ruby
* Written for Readability
* Written in an Object Oriented style
* Loosely Tested with RSpec

Tested using the Kiwiland Railway exercise (Kaitaia / Invercargill).  Can be used to solve:

> 8. The length of the shortest route (in terms of distance to travel) from A to C.
> 9. The length of the shortest route (in terms of distance to travel) from B to B.

See [my solution here](https://github.com/ecoologic/graphs_exercise/tree/all-done-plus-dijkstras) for the complete exercise.

### Requirements

* Ruby 2.3.1
* Bundler Gem

### Install

    bundle
    bundle exec rspec dijkstra.rb --color --format d
