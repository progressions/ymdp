require 'generator/view'

module ApplicationView
  module Generator
    class Base
      def self.generate(args)
        @command = args.shift
        
        if @command == "view"
          ApplicationView::Generator::View.new(args).generate
        end
      end
    end
  end
end
