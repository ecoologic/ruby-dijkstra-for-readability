require 'pry'
require 'set'

class Dijkstras
  class CurrentStep
    def initialize(routes, current, ends, unvisited, distances, path)
      @routes, @current, @ends, @unvisited, @distances, @path =
        routes, current, ends, unvisited, distances, path
    end

    # Where the recursion happen
    def call
      update_distances_with_neighbours

      if path.size > 1 && !unvisited_without_current.include?(ends)
        path
      else
        self.class.new(routes,
                       closest_node,
                       ends,
                       unvisited_with_current_at_the_end,
                       distances,
                       path + [closest_node]
        ).call
      end
    end

    private
    attr_reader :routes, :current, :ends, :unvisited, :distances, :path

    # This is a tricky step
    def update_distances_with_neighbours
      neighbours.each do |node, distance|
        tentative_distance = distances[current] + distance
        distances[node] = tentative_distance if tentative_distance < distances[node]
      end
    end

    def neighbours
      routes[current].select { |n, _| unvisited.include? n }
    end

    def closest_node
      distances.select { |n| neighbours.include?(n) }
        .min_by(&:last) # eg: ["B", 5].last - ie: the distance
        .first          # ie: the node
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

  # The API call
  def self.shortest_path(routes, starts:, ends:)
    new(routes, starts, ends).call
  end

  def call(current: starts, unvisited: start_unvisited, distances: start_distances, path: [starts])
    CurrentStep.new(routes, current, ends, unvisited, distances, path).call
  end

  private
  attr_reader :routes, :starts, :ends

  def start_unvisited
    Set.new(all_nodes - [starts])
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

##########################

RSpec.describe Dijkstras do
  let(:routes) { {"A"=>{"B"=>5, "D"=>5, "E"=>7}, "B"=>{"C"=>4}, "C"=>{"D"=>8, "E"=>2}, "D"=>{"C"=>8, "E"=>6}, "E"=>{"B"=>3}} }

  describe '#shortest_path' do
    context 'The length of the shortest route (in terms of distance to travel) from A to C.' do
      it "finds the shortest path" do
        expect(Dijkstras.shortest_path(routes, starts: 'A', ends: 'C')).to eq %w(A B C)
      end
    end

    context 'The length of the shortest route (in terms of distance to travel) from B to B.' do
      it "finds the shortest path" do
        expect(Dijkstras.shortest_path(routes, starts: 'B', ends: 'B')).to eq %w(B C E B)
      end
    end
  end
end
