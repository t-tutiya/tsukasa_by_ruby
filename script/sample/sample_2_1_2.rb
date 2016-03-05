#ボタンコントロール
_CREATE_ :ClickableLayoutControl, 
  width: 256,
  height: 256,
  id: :button1,
  collision_shape: [128,128,128] do
  _CREATE_ :ImageControl, id: :normal, width:256, height:256 do
    _CIRCLE_ x: 128,  y: 128, r: 128, color: C_BLUE, fill: true
    _TEXT_ x:80, y:120, text: "NORMAL", option: {color: [0,0,0]}
  end
  _CREATE_ :ImageControl, id: :over, visible: false, width:256, height:256 do
    _CIRCLE_ x: 128,  y: 128, r: 128, color: C_YELLOW, fill: true
    _TEXT_ x:80, y:120, text: "OVER", option: {color: [0,0,0]}
  end
  _CREATE_ :ImageControl, id: :key_down, visible: false, width:256, height:256 do
    _CIRCLE_ x: 128,  y: 128, r: 128, color: C_GREEN, fill: true
    _TEXT_ x:80, y:120, text: "DOWN", option: {color: [0,0,0]}
  end
  _STACK_LOOP_ do
    _CHECK_ mouse: [:cursor_over] do
      normal  {_SET_ visible: false}
      over    {_SET_ visible: true}
      key_down{_SET_ visible: false}
    end
    _CHECK_ mouse: [:cursor_out] do
      normal  {_SET_ visible: true}
      over    {_SET_ visible: false}
      key_down{_SET_ visible: false}
    end
    _CHECK_ mouse: [:key_down] do
      normal  {_SET_ visible: false}
      over    {_SET_ visible: false}
      key_down{_SET_ visible: true}
    end
    _CHECK_ mouse: [:key_up] do
      normal  {_SET_ visible: false}
      over    {_SET_ visible: true}
      key_down{_SET_ visible: false}
    end
    _END_FRAME_
  end
end

_LOOP_ do
  _END_FRAME_
end
