# coding:utf-8

class Bolic
    class Parser
        class ParseError < StandardError;end

        NUMBERS = %w( ⓿ ❶ ❷ ❸ ❹ ❺ ❻ ❼ ❽ ❾ ❿ )

        def self.parse(src)
            new(src).parse
        end

        def initialize(src)
            @tokens = src.chars.to_a
            @cur = 0
        end

        def parse
            parse_additive
        end

        private
        def parse_number
            c = @tokens[@cur]
            @cur += 1
            n = NUMBERS.index(c)
            raise ParseError,"数字でないものが来ました(#{c})" unless n
            n
        end

        def parse_additive
            left = parse_multiple
            if @tokens[@cur] == "＋"
                @cur += 1
                [:+ ,left,parse_additive]
            elsif @tokens[@cur] == "−"
                @cur += 1
                [:- ,left,parse_additive]
            else
                left
            end
        end
        
        def parse_multiple
            left = parse_number
            if @tokens[@cur] == "×"
                @cur+=1
                [:*,left,parse_multiple]
            elsif @tokens[@cur] == "÷"
                @cur += 1
                [:/,left,parse_multiple]
            else
                left
            end
        end
    end
end

p Bolic::Parser.parse(ARGF.read)