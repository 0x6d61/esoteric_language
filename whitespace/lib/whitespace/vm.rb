# coding:utf-8

module Whitespace
  class VM
    class ProgramError < StandardError; end

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
        insn, arg = *@insns[pc]
        case insn
        when :push
          push(arg)
        when :dup
          push(@stack[-1])
        when :copy
          push(@stack[-(arg + 1)])
        when :swap
          x, y = pop, pop
          push(x)
          push(y)
        when :discard
          pop
        when :slide
          x = pop
          arg.times do
            pop
          end
          push(x)
        when :add
          y, x = pop, pop
          push(x + y)
        when :sub
          y, x = pop, pop
          push(x - y)
        when :mul
          y, x = pop, pop
          push(x * y)
        when :div
          y, x = pop, pop
          push(x / y)
        when :mod
          y, x = pop, pop
          push(x % y)
        when :heap_write
          value, address = pop, pop
          @heap[address] = value
        when :heap_read
          address = pop
          value = @heap[address]
          if value.nil?
            raise ProgramError, "ヒープの未初期化の位置を読み出そうとしました。(address = #{address})"
          end
          push(value)
        when :label
        when :jump
          pc = jump_to(arg)
        when :jump_zero
          if pop == 0
            pc = jump_to(arg)
          end
        when :jump_negative
          if pop < 0
            pc = jump_to(arg)
          end
        when :call
            return_to.push(pc)
            pc = jump_to(arg)
        when :return
            pc = return_to.pop
            raise ProgramError,"サブルーチンの外からreturnしようとしました。" if pc.nil?
        when :char_out
            print pop.chr
        when :num_out
            print pop
        when :char_in
            address = pop
            s = gets.chmop
            raise ProgramError,"空文字は入力できません。" if s.size == 0
            raise ProgramError,"複数文字の入力はできません。" if s.size > 1
            @heap[address] = s.ord
        when :num_in
            address = pop
            @heap[address] = gets.to_i
        when :exit
          return
        end
        pc += 1
      end
      raise ProgramError, "プログラムの最後はexit命令を実行してください。"
    end

    private

    def jump_to(name)
      pc = @labels[name]
      raise ProgramError, "ジャンプ先(#{name.inspect})が見つかりません。" if pc.nil?
      pc
    end

    def find_labels(insns)
      labels = {}
      insns.each_with_index do |item, i|
        insn, arg = *item
        if insn == :label
          labels[arg] ||= i
        end
      end
      labels
    end

    def push(item)
      unless item.is_a?(Integer)
        raise ProgramError, "整数以外(#{item})をプッシュしようとしました。"
      end
      @stack.push(item)
    end

    def pop
      item = @stack.pop
      raise ProgramError, "空のスタックをポップしようとしました。" if item.nil?
      item
    end
  end
end


if $0 == __FILE__
    Whitespace::VM.run([[:push,1],[:num_out],[:exit]])
end