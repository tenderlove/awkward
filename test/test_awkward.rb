require "test/unit"
require "awkward"

class Generic
  def initialize
    @foo, @bar, @baz = 1, 2 ,3
  end
end

GenericStruct = Struct.new :foo, :bar, :baz

class TestAwkward < Test::Unit::TestCase
  def setup
    @tree = {
      :foo => { 'bar' => %w{ a b c } }
    }
    @awkward = Awkward::Visitor.new
  end

  def test_leaves
    [
      /foo/,
      1,
      470948572349857203498572049358729345872345123435465,
      "adsfadsfadsf",
      1.2,
      :foo,
      nil,
    ].each do |value|
      @awkward.accept value
    end
  end

  def test_nodes
    @awkward.accept @tree
    assert_equal 8, @awkward.nodes.length
  end

  def test_edges
    @awkward.accept @tree
    assert_equal 7, @awkward.edges.length
  end

  def test_edges_for_object
    @awkward.accept Generic.new
    assert_equal 3, @awkward.edges.length
  end

  def test_nodes_for_object
    @awkward.accept Generic.new
    assert_equal 4, @awkward.nodes.length
  end

  def test_edges_for_struct
    @awkward.accept GenericStruct.new 1, 2, 3
    assert_equal 3, @awkward.edges.length
  end

  def test_nodes_for_struct
    @awkward.accept GenericStruct.new 1, 2, 3
    assert_equal 4, @awkward.nodes.length
  end

  def test_edges_have_nodes
    @awkward.accept @tree
    nodes = @awkward.edges.map { |e| [e.left, e.right] }.flatten.uniq
    expected = @awkward.nodes
    assert_equal expected.sort_by(&:object_id), nodes.sort_by(&:object_id)
  end

  def test_to_dot
    @awkward.accept @tree
    @awkward.to_dot
  end

  def test_cyclic
    foo = {}
    foo[:a] = { :b => { :c => foo } }

    @awkward.accept foo
    @awkward.to_dot
  end
end
