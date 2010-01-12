require 'generator/view'

module YMDP
  module Generator
    class Base
      def self.generate(args)
        @command = args.shift
        
        if @command == "view"
          YMDP::Generator::View.new(args).generate
        end
      end
    end
  end
end
