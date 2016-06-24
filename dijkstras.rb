require 'pry'
require 'set'

class Dijkstras
  class CurrentStep
    def initialize(routes, current, ends, unvisited, distances, path)
      @routes, @current, @ends, @unvisited, @distances, @path =
        routes, current, ends, unvisited, distances, path
    end

    def call
      update_distances_with_neighbours

      if path.size > 1 && !unvisited_without_current.include?(ends)
        path
      else
        self.class.new(routes,
                       min_node,
                       ends,
                       unvisited_with_current_at_the_end,
                       distances,
                       path + [min_node]
        ).call
      end
    end

    private
    attr_reader :routes, :current, :ends, :unvisited, :distances, :path

    def update_distances_with_neighbours
      neighbours.each do |node, distance|
        tentative_distance = distances[current] + distance
        distances[node] = tentative_distance if tentative_distance < distances[node]
      end
    end

    def neighbours
      routes[current].select { |n, _| unvisited.include? n }
    end

    def min_node
      distances.select do |n|
        neighbours.include?(n)
      end.min_by(&:last).first # ["B", 5].last
    end

    def unvisited_without_current
      unvisited - [current]
    end

    def unvisited_with_current_at_the_end
      unvisited_without_current + [current]
    end
  end

  def initialize(routes, starts, ends)
    @routes, @starts, @ends = routes, starts, ends
  end

  def self.call(routes, starts:, ends:)
    new(routes, starts, ends).call
  end

  def call(current: starts, unvisited: start_unvisited, distances: start_distances, path: [starts])
    CurrentStep.new(routes, current, ends, unvisited, distances, path).call
  end

  private
  attr_reader :routes, :starts, :ends

  def start_unvisited
    Set.new(routes.keys - [starts])
  end
  private

  def start_distances
    infinite_distances.merge starts => 0
  end

  def infinite_distances
    all_nodes.reduce({}) do |result, node|
      result.merge node => Float::INFINITY
    end
  end

  def all_nodes
    routes.each.reduce [] do |result, (node, weights)|
      result + [node] + weights.keys
    end.uniq
  end
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
    path = Dijkstras.call(routes, starts: starts, ends: ends)

    distance(path)
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
