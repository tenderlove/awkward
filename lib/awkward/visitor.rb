module Awkward
  class Visitor
    class Node < Struct.new :object # :nodoc:
      def name
        object.class.name
      end

      private
      def escape string
        string.gsub '"', '\"'
      end
    end

    Edge = Struct.new :name, :left, :right

    attr_reader :edges

    def initialize
      @nodes     = []
      @stack     = []
      @edges     = []
      @callstack = []
      @seen      = {}
    end

    def nodes
      @seen.values
    end

    def accept o
      return connect(@stack.last, @seen[o.object_id]) if @seen.key? o.object_id

      node = Node.new o

      @seen[o.object_id] = node

      connect(@stack.last, node) unless @callstack.empty?

      @stack.push node

      send "visit_#{o.class.name.gsub('::', '_')}", o

      @stack.pop
    end

    def to_dot
      dot = <<-eodot
digraph "Graph" {
node [width=0.375,height=0.25,shape=box];
      eodot

      nodes.each do |node|
        dot.concat <<-eonode
        #{node.object_id} [label="#{node.name}"];
        eonode
      end

      edges.each do |edge|
        dot.concat <<-eoedge
        #{edge.left.object_id} -> #{edge.right.object_id} [label="#{edge.name}"];
        eoedge
      end
      dot + "}"
    end

    private

    def visit_Hash o
      o.each_with_index do |(k,v),i|
        edge("key: #{i}") { accept k }
        edge("value: #{i}") { accept v }
      end
    end

    def visit_Array o
      o.each_with_index do |v, i|
        edge(i) { accept v }
      end
    end

    def leaf o; end
    alias :visit_Symbol :leaf
    alias :visit_String :leaf

    def edge sym
      @callstack.push sym
      yield
      @callstack.pop
    end

    def connect from, to
      @edges << Edge.new(@callstack.last, from, to)
    end
  end
end
