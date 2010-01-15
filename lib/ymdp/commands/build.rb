YMDP_ENV = "build"

require 'compiler/options'
require 'compiler/domains'

YMDP::Compiler::Template::Base.base_path = BASE_PATH
YMDP::Compiler::Template::Base.servers = SERVERS

YMDP::Compiler::Domains.base_path = BASE_PATH
YMDP::Compiler::Domains.servers = SERVERS

@options = YMDP::Compiler::Options.parse
YMDP::Compiler::Domains.new(@options).compile

