module Awkward
  class Visitor
    Node = Struct.new :object
    Edge = Struct.new :name, :left, :right

    attr_reader :nodes
    attr_reader :edges

    def initialize
      @nodes     = []
      @edges     = []
      @callstack = []
      @seen      = {}
    end

    def accept o
      return cycle(o) if @seen[o.object_id]

      node = Node.new o

      @seen[o.object_id] = node

      @nodes.push node

      cycle o

      send "visit_#{o.class.name.gsub('::', '_')}", o
    end

    def to_dot
    end

    private

    def visit_Hash o
      o.each do |k,v|
        edge(:key) { accept k }
        edge(:value) { accept v }
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

    def escape string
      string.gsub '"', '\"'
    end

    def cycle o
      if last = @nodes.last && @callstack.last
        @edges << Edge.new(@callstack.last, last.object_id, o.object_id)
      end
    end
  end
end
