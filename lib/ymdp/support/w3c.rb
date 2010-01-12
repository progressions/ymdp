def post_file_to_w3c_validator(file_path, doc_type)
  query = MultipartPost.build_form_data(
        :uploaded_file  => File.new(file_path, 'r'),
        :charset        => '(detect automatically)',
        :doctype        => doc_type,   
        :group          => '1'
        )

  Net::HTTP.start('validator.w3.org') do |http|
    http.post2("/check", query, MultipartPost::REQ_HEADER)
  end
end

def valid_response?(w3c_response)
  html = w3c_response.read_body
  html.include? "[Valid]"
end

def w3c_valid?(file_path)
  resp = post_file_to_w3c_validator(file_path, 'HTML 4.01 Strict')
  valid_response?(resp)
end
