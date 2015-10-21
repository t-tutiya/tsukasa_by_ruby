#! ruby -E utf-8

#ボタンコントロール
button id: :button1

_SEND_ :button1 do
_WHILE_ [:true] do
  _MOVE_ type:{x: [0,300]}, time: 60
  wait_command :_MOVE_
  _WHILE_ [:true] do
    _MOVE_ type:{x: [0,300]}, time: 60
    wait_command :_MOVE_
    _BREAK_
  end
#  _BREAK_
    _MOVE_ type:{y: 300}, time: 60
  wait_command :_MOVE_
#  _BREAK_
  _MOVE_ type:{x: 0}, time: 60
  wait_command :_MOVE_
  _BREAK_
  _MOVE_ type:{y: 0}, time: 60
  wait_command :_MOVE_
  _BREAK_
end

end