require 'pry'
require 'set'

class Dijkstras
  def initialize(routes)
    @routes = routes
  end

  def call(starts:, ends:, unvisited:, distances:, path:)
    unvisited_neighbours = routes[starts].select { |n, _| unvisited.include? n }

    unvisited_neighbours.each do |node, distance|
      tentative_distance = distances[starts] + distance
      distances[node] = tentative_distance if tentative_distance < distances[node]
    end

    unvisited = unvisited - [starts]
    return path if path.size > 1 && !(unvisited - [starts]).include?(ends)
    unvisited += [starts]

    min_node = distances.select do |n|
      unvisited_neighbours.include?(n)
    end.min_by(&:last).first # ["B", 5].last

    call starts:    min_node,
         ends:      ends,
         unvisited: unvisited,
         distances: distances,
         path:      path + [min_node]
  end

  attr_reader :routes
end

class Wrapper
  attr_reader :routes

  def initialize
    @routes = {"A"=>{"B"=>5, "D"=>5, "E"=>7}, "B"=>{"C"=>4}, "C"=>{"D"=>8, "E"=>2}, "D"=>{"C"=>8, "E"=>6}, "E"=>{"B"=>3}}
  end

  def distance(stations)
    consecutive_stations = stations.each_cons(2)

    if !consecutive_stations.all? { |x| routes[x[0]].has_key?(x[1]) }
      'NO SUCH ROUTE'
    else
      consecutive_stations.reduce(0) { |sum, x| sum + routes[x[0]][x[1]] }
    end
  end

  def shortest_distance(starts:, ends:)
    distances = infinite_distances
    distances[starts] = 0

    unvisited = Set.new(routes.keys - [starts])

    path = Dijkstras.new(routes).(starts:    starts,
                     ends:      ends,
                     unvisited: unvisited,
                     distances: distances,
                     path:      [starts])

    distance(path)
  end

  private

  def all_nodes
    routes.each.reduce [] do |result, (node, weights)|
      result + [node] + weights.keys
    end.uniq
  end

  def infinite_distances
    all_nodes.reduce({}) do |result, node|
      result.merge node => Float::INFINITY
    end
  end
end

##########################

RSpec.describe Wrapper do
  describe 'The length of the shortest route (in terms of distance to travel) from A to C.' do
    it { expect(subject.shortest_distance(starts: 'A', ends: 'C')).to eq 9 }
  end

  describe 'The length of the shortest route (in terms of distance to travel) from B to B.' do
    it { expect(subject.shortest_distance(starts: 'B', ends: 'B')).to eq 9 }
  end
end
