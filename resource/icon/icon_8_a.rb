_DEFINE_ :_ICON_8_ do
  _DEFINE_ :inner_loop do
    _MAP_STATUS_ 0, x:0, y:0
    _WAIT_ count: 5
    _MAP_STATUS_ 1, x:0, y:0
    _WAIT_ count: 5
    _MAP_STATUS_ 2, x:0, y:0
    _WAIT_ count: 5
    _MAP_STATUS_ 3, x:0, y:0
    _WAIT_ count: 5
    _MAP_STATUS_ 4, x:0, y:0
    _WAIT_ count: 5
    _MAP_STATUS_ 5, x:0, y:0
    _WAIT_ count: 5
    _MAP_STATUS_ 6, x:0, y:0
    _WAIT_ count: 5
    _MAP_STATUS_ 7, x:0, y:0
    _WAIT_ count: 30
    _RETURN_ :inner_loop
  end
  inner_loop
end