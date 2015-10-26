#! ruby -E utf-8

#ボタンコントロール
button id: :button1

_SEND_ :button1 do
_WHILE_ [:true] do
  _MOVE_ 60, x: [0,300]
  wait_command :_MOVE_
  _WHILE_ [:true] do
    _MOVE_ 60, x: [0,300]
    wait_command :_MOVE_
    _BREAK_
  end
#  _BREAK_
    _MOVE_ 60, y: 300
  wait_command :_MOVE_
#  _BREAK_
  _MOVE_ 60, x: 0
  wait_command :_MOVE_
  _BREAK_
  _MOVE_ 60, y: 0
  wait_command :_MOVE_
  _BREAK_
end

end