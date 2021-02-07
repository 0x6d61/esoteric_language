# coding:utf-8

class Bolic
  class Parser
    class ParseError < StandardError; end

    NUMBERS = %w( ⓿ ❶ ❷ ❸ ❹ ❺ ❻ ❼ ❽ ❾ ❿ )
    VARIABLES = %w( ✪ ☆ ✴ ✲ )
    def self.parse(src)
      new(src).parse
    end

    def initialize(src)
      @tokens = trim_spaces(src).chars.to_a
      @cur = 0
    end

    def parse
      parse_stmts
    end

    private

    def parse_number
      c = @tokens[@cur]
      @cur += 1
      n = NUMBERS.index(c)
      raise ParseError, "数字でないものが来ました(#{c})" unless n
      n
    end

    def parse_additive
      left = parse_multiple
      if match?("＋")
        [:+, left, parse_expr]
      elsif match?("−")
        [:-, left, parse_expr]
      else
        left
      end
    end

    def parse_multiple
      left = parse_variable
      if match?("×")
        [:*, left, parse_multiple]
      elsif match?("÷")
        [:/, left, parse_multiple]
      else
        left
      end
    end

    def parse_output
      if match?("♪")
        [:char_out, parse_expr]
      elsif match?("✍")
        [:num_out, parse_expr]
      else
        parse_expr
      end
    end

    def parse_stmts(*terminators)
      exprs = []
      if not terminators.empty?
        until terminators.include?(@tokens[@cur])
          exprs << parse_stmt
        end
      else
        while @cur < @tokens.size
          exprs << parse_stmt
        end
      end
      exprs
    end

    def parse_stmt
      parse_output
    end

    def parse_expr
      parse_if
    end

    def parse_variable
      c = @tokens[@cur]
      if VARIABLES.include?(c)
        @cur += 1
        if match?("👈")
          [:assign, c, parse_expr]
        else
          [:var, c]
        end
      else
        parse_number
      end
    end

    def parse_if
      if match?("✈")
        cond = parse_expr
        raise ParseError, "☺がありません。" unless match?("☺")
        thenc = parse_stmts("☹", "☻")
        if match?("☹")
          elsec = parse_stmts("☻")
          @cur += 1
        elsif match?("☻")
          elsec = nil
        end
        [:if, cond, thenc, elsec]
      else
        parse_additive
      end
    end

    def match?(c)
      if @tokens[@cur] == c
        @cur += 1
        true
      else
        false
      end
    end

    def trim_spaces(str)
      str.gsub(/\s/, "")
    end
  end
end

class Bolic
  class ProgramError < StandardError; end

  def self.run(src)
    new(src).run
  end

  def initialize(src)
    @stmts = Parser.parse(src)
    @vars = {}
  end

  def run
    @stmts.each do |stmt|
      eval(stmt)
    end
  end

  def eval(tree)
    if tree.is_a?(Integer)
      tree
    else
      case tree[0]
      when :+
        eval(tree[1]) + eval(tree[2])
      when :-
        eval(tree[1]) - eval(tree[2])
      when :*
        eval(tree[1]) * eval(tree[2])
      when :/
        eval(tree[1]) / eval(tree[2])
      when :char_out
        print eval(tree[1]).chr
      when :num_out
        print eval(tree[1])
      when :assign
        val = eval(tree[2])
        @vars[tree[1]] = val
        val
      when :var
        val = @vars[tree[1]]
        raise ProgramError, "初期化されてない変数を参照しました。(#{tree[1]})" unless val
        val
      else
        raise "[BUG] 命令の種類がわかりません。(#{tree[0].inspect})"
      end
    end
  end
end

#p Bolic::Parser.parse(ARGF.read)
Bolic.run(ARGF.read)
