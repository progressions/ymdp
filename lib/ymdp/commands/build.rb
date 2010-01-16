YMDP_ENV = "build"

require 'compiler/options'
require 'compiler/domains'

@options = YMDP::Compiler::Options.parse
YMDP::Compiler::Domains.new(@options).compile

