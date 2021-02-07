# coding:utf-8

class Bolic
    class Parser
        class ParseError < StandardError;end

        NUMBERS = %w( ⓿ ❶ ❷ ❸ ❹ ❺ ❻ ❼ ❽ ❾ ❿ )

        def self.parse(src)
            new(src).parse
        end

        def initialize(src)
            @src = src.chars.to_a
            @cur = 0
        end

        def parse
            parse_number
        end

        private
        def parse_number
            c = @tokens[@cur]
            @cur += 1
            n = NUMBERS.index(c)
            raise ParseError,"数字でないものが来ました(#{c})" unless n
            n
        end
    end
end