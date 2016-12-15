require 'pry'
require 'set'

class DijkstraStrategy
  def initialize(possible_routes, beginning, destination)
    @possible_routes, @beginning, @destination =
      possible_routes, beginning, destination
  end

  # ** The ACTUAL API call **
  # @param possible_routes [Hash] e.g.: `{ 'A' => ['B', 2] }` (A to B distance 2)
  # @param beginning: [String] e.g.: `'A'`
  # @param destination: [String] e.g.: `'B'`
  # @return [Array] e.g.: `['A', 'B']`
  def self.shortest_path(possible_routes:, beginning:, destination:)
    new(possible_routes, beginning, destination).call
  end

  def call
    CurrentStep.new(possible_routes:      possible_routes,
                    current:              beginning,
                    destination:          destination,
                    unvisited:            Set.new(all_nodes - [beginning]),
                    distances_from_start: infinite_distances.merge(beginning => 0),
                    path:                 [beginning]).shortest_path
  end

  private

  attr_reader :possible_routes, :beginning, :destination

  def infinite_distances
    all_nodes.reduce({}) do |result, node|
      result.merge node => Float::INFINITY
    end
  end

  def all_nodes
    possible_routes.each.reduce [] do |result, (node, weights)|
      [*result, node, *weights.keys]
    end.uniq
  end
end

class DijkstraStrategy
  class CurrentStep
    def initialize(possible_routes:, current:, destination:, unvisited:, distances_from_start:, path:)
      @possible_routes, @current, @destination, @unvisited, @distances_from_start, @path =
        possible_routes, current, destination, unvisited, distances_from_start, path
    end


    def shortest_path
      update_distances_from_start_with_current_neighbours

      found? ? path : navigate_the_graph
    end

    private

    attr_reader :possible_routes, :current, :destination, :unvisited, :distances_from_start, :path

    def update_distances_from_start_with_current_neighbours
      neighbours.each do |node, distance|
        tentative_distance = distances_from_start[current] + distance
        if tentative_distance < distances_from_start[node]
          distances_from_start[node] = tentative_distance
        end
      end
    end

    # Allows to start from destination and find a loop
    def found?
      path.size > 1 &&
      !unvisited_without_current.include?(destination)
    end

    # Recursion happens here
    def navigate_the_graph
      self.class.new(possible_routes:      possible_routes,
                     current:              closest_node,
                     destination:          destination,
                     unvisited:            unvisited_with_current_at_the_end,
                     distances_from_start: distances_from_start,
                     path:                 path + [closest_node]).shortest_path
    end

    def neighbours
      possible_routes[current].select { |node, _| unvisited.include?(node) }
    end

    def closest_node
      distances_from_start.select { |node| neighbours.include?(node) }
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
end

##########################

RSpec.describe DijkstraStrategy do
  # The Kiwiland Railway exercise possible_routes
  let :possible_routes do
    { 'A' => { 'B' => 5, 'D' => 5, 'E' => 7},
      'B' => { 'C' => 4},
      'C' => { 'D' => 8, 'E' => 2},
      'D' => { 'C' => 8, 'E' => 6},
      'E' => { 'B' => 3} }
  end

  describe '#shortest_path' do
    context 'The shortest route (in terms of distance to travel) from A to C.' do
      it "finds the shortest path" do
        actual_path = DijkstraStrategy.shortest_path(possible_routes: possible_routes,
                                                     beginning:       'A',
                                                     destination:     'C')
        expect(actual_path).to eq %w(A B C)
      end
    end

    context 'The shortest route (in terms of distance to travel) from B to B.' do
      it "finds the shortest path" do
        actual_path = DijkstraStrategy.shortest_path(possible_routes: possible_routes,
                                                     beginning:       'B',
                                                     destination:     'B')
        expect(actual_path).to eq %w(B C E B)
      end
    end
  end
end
