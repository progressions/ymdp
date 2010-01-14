class StringMasker
  attr_accessor :string, :params, :output_string
  
  def initialize(string, params)
    output_string = string.dup
    
    params.each do |key, value|
      output_string.gsub!(value, "[#{key}]")
    end
    
    @output_string = output_string
  end
  
  def to_s
    output_string
  end
end
