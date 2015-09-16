#! ruby -E utf-8

_DEFINE_ :func1 do
  _EVAL_ "pp 'EVAL func1'"
  #pp "pp func1"
  _YIELD_
end

_DEFINE_ :func2 do
  _EVAL_ "pp 'EVAL func2'"
  #pp "pp func2"
  func1 do
    _EVAL_ "pp 'EVAL func1 YIELD in func2'"
    #pp "pp  func1 YIELD in func2"
    _YIELD_
  end
  _YIELD_
  _YIELD_
end

=begin
_EVAL_ "pp 'TEST1'"

func1 do
  _EVAL_ "pp 'EVAL func1 YIELD'"
  #pp "pp  func1 YIELD"
  _YIELD_
end
=end
_EVAL_ "pp 'TEST2'"

#functionを実行後、ブロック内のコマンドを実行する
#TODO：aboutではなく、func2の引数で送信先を指定できないものか
func2 do
  _EVAL_ "pp 'EVAL func2 YIELD'"
  #pp "pp func2 YIELD"
end
=begin

_DEFINE_ :func3 do
    _EVAL_ "pp 'EVAL func3'"
    #pp "pp func3"
    func2 do
      _EVAL_ "pp 'EVAL func2 YIELD in func3'"
      #pp "pp  func2 YIELD in func3"
      _YIELD_
   
  end
end

_EVAL_ "pp 'TEST3'"

func3 do
  _EVAL_ "pp 'EVAL func3 YIELD'"
  pp "pp func3 YIELD"
end

_DEFINE_ :func4 do

  _WAIT_ [:true] do
    _YIELD_
  end

end

func4 do
  _EVAL_ "pp 'func4 loop'"
end

=end