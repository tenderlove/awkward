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

  def test_edges_have_nodes
    awkward = Awkward::Visitor.new
    awkward.accept @tree
    nodes = awkward.edges.map { |e| [e.left, e.right] }.flatten.uniq
    expected = awkward.nodes
    assert_equal expected.sort_by(&:object_id), nodes.sort_by(&:object_id)
  end

  def test_to_dot
    awkward = Awkward::Visitor.new
    awkward.accept @tree
    awkward.to_dot
  end

  def test_cyclic
    foo = {}
    foo[:a] = { :b => { :c => foo } }

    awkward = Awkward::Visitor.new
    awkward.accept foo
    awkward.to_dot
  end
end
