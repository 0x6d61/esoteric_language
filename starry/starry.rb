class Starry

    class ProgamError < StandardError; end

    class << self
        def run(src)
            new(src).run
        end
    end

    def initialize(src)
        @insns = parse(src)
        @stack = Array.new
        @labels = find_labels(@insns)
    end

    private
    OP_CALC = [:+,:-,:*,:/,:%]
    OP_OUTPUT = [:num_out,:char_out]
    OP_INPUT = [:num_in,:char_in]
    def parse(src)
        insns = Array.new
        spaces = 0
        src.each_char do |c|
            case c
            when " "
                spaces+=1
            when "*"
                insns << select(OP_CALC,spaces)
                spaces = 0
            when "."
                insns << select(OP_OUTPUT,spaces)
                spaces = 0
            when ","
                insns << select(OP_INPUT,spaces)
                spaces = 0
            end
        end
        insns
    end

    def find_labels(src)
    end

    def select(ops,n)
        op = ops[n % ops.size]
        [op]
    end
end

Starry.run(ARGF.read)