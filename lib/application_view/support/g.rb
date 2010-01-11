def growl(s)
  if CONFIG["growl"]
    g(s, :title => "YMDP")
  end
rescue StandardError => e
  if e.message =~ /Connection refused/
    puts s
  else
    raise e
  end
end