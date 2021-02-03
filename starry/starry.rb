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


    def run
        pc = 0
        while pc < @insns.size
            insn,arg = *@insns[pc]
            case insn
            else
                raise "[BUG]しらない命令です(#{insn})"
            end
            pc += 1
        end
    end


    private
    OP_CALC = [:+,:-,:*,:/,:%]
    OP_OUTPUT = [:num_out,:char_out]
    OP_INPUT = [:num_in,:char_in]
    OP_STACK = [:__dummy__,:dup,:swap,:rotate,:pop]
    
    def push(item)
        unless item.is_a?(Integer)
            raise ProgamError,"整数以外(#{item})をプッシュしようとしました。"
        end
        @stack.push(item)
    end

    def pop
        item = stack.pop
        raise ProgamError,"空のスタックをポップしようとしました。" if item.nil?
        item
    end
    
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
            when "+"
                raise ProgamError, "0個の空白のあとに+が続きました。" if spaces == 0
                if spaces < OP_STACK.size
                    insns << select(OP_STACK,spaces)
                else
                    insns << [:push spaces - OP_STACK.size]
                end
                spaces = 0
            when "`"
                insns << [:label,spaces]
                spaces = 0
            when "'"
                insns << [:jump,spaces]
                spaces = 0
            end
        end
        insns
    end

    def find_labels(insns)
        labels = {}
        insns.each_with_index do |(isn,arg),i|
            raise ProgamError, "ラベル#{arg}が重複しています。" if labels[arg]
            if insn = :label
                labels[arg] = i
            end
        end
        labels
    end

    def select(ops,n)
        op = ops[n % ops.size]
        [op]
    end
end

Starry.run(ARGF.read)