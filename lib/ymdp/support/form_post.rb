# from http://devlicio.us/blogs/sergio_pereira/archive/2008/04/02/xhtml-validation-script-using-ruby.aspx

require 'rubygems'
require 'mime/types'
require 'net/http'
# require 'CGI'
 
class FormField
  attr_accessor :name, :value
  def initialize( name, value )
    @name = name
    @value = value
  end
 
  def to_form_data
    field = CGI::escape(@name)
    "Content-Disposition: form-data; name=\"#{field}\"" + 
      "\r\n\r\n#{@value}\r\n"
  end
end
 
class FileField
  attr_accessor :name, :path, :content
  def initialize( name, path, content )
    @name = name
    @path = "#{path}.html"
    @content = content
  end
 
  def to_form_data
    "Content-Disposition: form-data; " + 
    "name=\"#{CGI::escape(@name)}\"; " + 
    "filename=\"#{@path}\"\r\n" +
    "Content-Transfer-Encoding: binary\r\n" +
    "Content-Type: #{MIME::Types.type_for(@path)}" + 
    "\r\n\r\n#{@content}\r\n"
  end
end

class MultipartPost
  SEPARATOR = 'willvalidate-aaaaaabbbb0000'
  REQ_HEADER = {
      "Content-type" => "multipart/form-data, boundary=#{SEPARATOR} "
   }
 
  def self.build_form_data ( form_fields )
    fields = []
    form_fields.each do |key, value|
      if value.instance_of?(File)
        fields << FileField.new(key.to_s, value.path, value.read)
      else
        fields << FormField.new(key.to_s, value)
      end
    end
    fields.collect {|f| "--#{SEPARATOR}\r\n#{f.to_form_data}" }.join("") + 
         "--#{SEPARATOR}--"
  end
end