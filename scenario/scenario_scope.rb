#! ruby -E utf-8

#ボタンコントロール
button id: :button1

_SEND_ :button1 do
_WHILE_ [:true] do
  move type:{x: [0,300]}, total_frame: 60
  wait_command :move
  _WHILE_ [:true] do
    move type:{x: [0,300]}, total_frame: 60
    wait_command :move
    _BREAK_
  end
#  _BREAK_
    move type:{y: 300}, total_frame: 60
  wait_command :move
#  _BREAK_
  move type:{x: 0}, total_frame: 60
  wait_command :move
  _BREAK_
  move type:{y: 0}, total_frame: 60
  wait_command :move
  _BREAK_
end

end