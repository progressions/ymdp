require "#{APPLICATION_PATH}/tag_helper"

module ApplicationView
  include ActionView::Helpers::TagHelper
    
  ProtocolRegexp = %r{^[-a-z]+://}.freeze
  
  module LinkTagHelper
    def link_to_unless_current(text, url_or_view, options={});
      if Application.current_view.downcase == url_or_view.downcase
        text
      else
        link_to(text, url_or_view, options)
      end
    end
    
    def link_to(text, url_or_view, options={})
      if url_or_view =~ ProtocolRegexp
        options[:href] = url_or_view
        options[:target] ||= "_blank"
      else
        # this will create an in-YMDP link
        options[:onclick] = "YAHOO.launcher.l('#{url_or_view}'); return false;"
        options[:href] = "#"
      end
      content_tag("a", text, options)
    end
    
    def link_to_function(text, function, options={})
      options[:onclick] = function
      options[:href] = "#"
      content_tag("a", text, options)
    end
  end
  
  module FormTagHelper
    def text_field(name, options={})
      options[:id] ||= name
      options[:name] ||= name
      options[:type] ||= "text"
      
      tag("input", options)
    end
    
    def password_field(name, options={})
      options[:type] = "password"
      text_field(name, options)
    end
    
    def label(name, content_or_options = nil, options = {})
      if content_or_options.is_a?(Hash)
        options = content_or_options
        text = name
      else
        text = content_or_options || name
      end
      options[:id] ||= "#{name.downcase}_label"
      options[:for] ||= name.downcase
      content_tag("label", text, options)
    end
  end
  
  module AssetTagHelper

    def image_tag(source, options = {})
      # options.symbolize_keys!

      options[:src] = path_to_image(source)
      options[:alt] ||= File.basename(options[:src], '.*').split('.').first.to_s.capitalize

      if size = options.delete(:size)
        options[:width], options[:height] = size.split("x") if size =~ %r{^\d+x\d+$}
      end

      if mouseover = options.delete(:mouseover)
        options[:onmouseover] = "this.src='#{path_to_image(mouseover)}'"
        options[:onmouseout]  = "this.src='#{path_to_image(options[:src])}'"
      end

      tag("img", options)
    end

    private
    
    # "funk"                  #=>  "/om/assets/#{SERVERS[@domain]['assets_id']}/images/funk.png"
    # "funk.jpg"              #=>  "/om/assets/#{SERVERS[@domain]['assets_id']}/images/funk.jpg"
    # "/funky/chicken"        #=>  "/om/assets/#{SERVERS[@domain]['assets_id']}/funky/chicken.png"
    # "funky/chicken"         #=>  "/om/assets/#{SERVERS[@domain]['assets_id']}/images/funky/chicken.png"
    # "http://funk.com/chicken.jpg" #=> "http://funk.com/chicken.jpg"
    #
    def path_to_image(source)
      unless source =~ /(\.jpg|\.png|\.gif)$/
        source = "#{source}.png"
      end
      unless source =~ ProtocolRegexp
        if source =~ /^\//
          source = "#{@assets_directory}#{source}"
        else
          source = "#{@assets_directory}/images/#{source}"
        end
      end
      source
    end
    
  end
end