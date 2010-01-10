def g(s)
  if CONFIG["growl"]
    growl(s, :title => "YMDP")
  end
rescue StandardError => e
  if e.message =~ /Connection refused/
    puts s
  else
    raise e
  end
end