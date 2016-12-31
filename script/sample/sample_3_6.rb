=begin
  #擬似コード
  flag0 = true
  if flag0
    puts "A true"
  else
    puts "A false"
  end
=end

_SET_ [:_ROOT_, :_TEMP_], flag0: false

_LOOP_ do
  _CHECK_ [:_ROOT_, :_TEMP_], equal: {flag0: true} do |a,b,c|
    _PUTS_ "A true"
    _BREAK_  
  end
  _PUTS_ "A false"
  _BREAK_  
end

=begin
  #擬似コード
  flag1 = 1
  if flag1 == 0
    puts "A 0"
  elsif flag1 == 1
    puts "A 1"
  else
    puts "A 2"
  end
  end
=end


_SET_ [:_ROOT_, :_TEMP_], flag1: 1

_LOOP_ do
  _CHECK_ [:_ROOT_, :_TEMP_], equal: {flag1: 0} do
    _PUTS_ "A 0"
    _BREAK_  
  end
  _CHECK_ [:_ROOT_, :_TEMP_], equal: {flag1: 1} do
    _PUTS_ "A 1"
    _BREAK_  
  end
  _PUTS_ "A else"
  _BREAK_  
end
