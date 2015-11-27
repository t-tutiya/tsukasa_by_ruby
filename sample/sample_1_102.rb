  _CREATE_ :LayoutControl, id: :test102_a do
    _CREATE_ :LayoutControl, id: :test102_b do
      _DEFINE_ :func_d do
        _EVAL_ "pp 'func_d'"
        _YIELD_
      end
    end
#    _DEFINE_ :func_b do
#      _EVAL_ "pp 'func_b'"
#    end
    _DEFINE_ :func_c do
      _SEND_ :test102_b do
        func_d
      end
#      test102_b{
#        func_d
#      }
    end
#    _YIELD_
  end
  
  test102_a{
#    func_b
    func_c
  }