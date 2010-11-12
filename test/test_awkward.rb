require "test/unit"
require "awkward"

class TestAwkward < Test::Unit::TestCase
  def setup
    @tree = {
      :foo => { 'bar' => %w{ a b c } }
    }
  end

  def test_nodes
    awkward = Awkward::Visitor.new
    awkward.accept @tree
    assert_equal 8, awkward.nodes.length
  end

  def test_edges
    awkward = Awkward::Visitor.new
    awkward.accept @tree
    assert_equal 7, awkward.edges.length
  end
end
