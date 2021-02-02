# coding:utf-8

module Whitespace
    class VM
        class ProgramError< StandardError; end

        class << self
            def run(insns)
                new(insns).run
            end
        end

        def initialize(insns)
            @insns = insns
            @stack = []
            @heap = {}
            @labels = find_labels(@insns)
        end

        def run
            return_to = []
            pc = 0
            while pc < @insns.size
                insn,arg = *@insns[pc]
                case insn
                when :push
                    push(arg)
                when :dup
                    push(@stack[-1])
                when :copy
                    push(@stack[-(arg+1)])
                when :swap
                    x,y = pop,pop
                    push(x)
                    push(y)
                when :discard
                    pop
                when :exit
                    return
                end 
                pc += 1
            end
            raise ProgramError, "プログラムの最後はexit命令を実行してください。"
        end

        private
        def find_labels(insns)
            labels = {}
            insns.each_with_index do |item,i|
                insn,arg = *item
                if insn == :label
                    labels[arg] ||= i
                end
            end
            labels
        end

        def push(item)
            unless item.is_a?(Integer)
                raise ProgramError,"整数以外(#{item})をプッシュしようとしました。"
            end
            @stack.push(item)
        end

        def pop
            item = @stack.pop
            raise ProgramError,"空のスタックをポップしようとしました。" if item.nil?
            item
        end
    end
end
