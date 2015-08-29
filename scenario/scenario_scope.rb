#! ruby -E utf-8

#ボタンコントロール
button id: :button1

_SEND_ :button1 do
_WHILE_ [:true] do
  move start: [0,0], last: [300,0], total_frame: 60
  wait_command :move
  _WHILE_ [:true] do
    move start: [0,0], last: [300,0], total_frame: 60
    wait_command :move
    _BREAK_
  end
#  _BREAK_
    move start: [300,0], last: [300,300], total_frame: 60
  wait_command :move
#  _BREAK_
  move start: [300,300], last: [0,300], total_frame: 60
  wait_command :move
  _BREAK_
  move start: [0,300], last: [0,0], total_frame: 60
  wait_command :move
  _BREAK_
end

end