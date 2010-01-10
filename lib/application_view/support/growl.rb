require 'rubygems'
require 'ruby-growl'
require 'pp'

$g_host ||= "localhost"
$g_priority ||= 0
$g_sticky ||= true

module Kernel
  def growl(*args)
    options = {}
    if args.last.class == Hash
      options = args.pop
    end
    
    title = options[:title] || 'g'
    g = Growl.new $g_host, title, [$0]

    messages =
      if args.empty?
        ['g!']
      else
        args.map { |i| i.pretty_inspect }
      end

    messages.each { |i| g.notify $0, title, i, $g_priority, $g_sticky }

    if args.empty?
      nil
    elsif args.size == 1
      args.first
    else
      args
    end
  end
end
