require "whitespace/compiler"
require "whitespace/vm"

module Whitespace
    
    def run(src)
        insns = Whitespace::Compiler.compile(src)
        Whitespace::VM.run(insns)
    end
    module_function :run
end