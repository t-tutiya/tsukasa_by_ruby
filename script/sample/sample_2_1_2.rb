#ボタンコントロール
_CREATE_ :ClickableLayout, 
  width: 256,
  height: 256,
  id: :button1,
  collision_shape: [128,128,128] do
  _CREATE_ :Image, id: :normal, width:256, height:256 do
    _CIRCLE_ x: 128,  y: 128, r: 128, color: C_BLUE, fill: true
    _TEXT_ x:80, y:120, text: "NORMAL", color: [0,255,0]
  end
  _CREATE_ :Image, id: :over, visible: false, width:256, height:256 do
    _CIRCLE_ x: 128,  y: 128, r: 128, color: C_YELLOW, fill: true
    _TEXT_ x:80, y:120, text: "OVER", option: {color: [0,0,0]}
  end
  _CREATE_ :Image, id: :key_down, visible: false, width:256, height:256 do
    _CIRCLE_ x: 128,  y: 128, r: 128, color: C_GREEN, fill: true
    _TEXT_ x:80, y:120, text: "DOWN", option: {color: [0,0,0]}
  end
  _DEFINE_ :inner_loop do
    _CHECK_MOUSE_:cursor_over do
      _SEND_(:normal)  {_SET_ visible: false}
      _SEND_(:over)    {_SET_ visible: true}
      _SEND_(:key_down){_SET_ visible: false}
    end
    _CHECK_MOUSE_:cursor_out do
      _SEND_(:normal)  {_SET_ visible: true}
      _SEND_(:over)    {_SET_ visible: false}
      _SEND_(:key_down){_SET_ visible: false}
    end
    _CHECK_MOUSE_:key_down do
      _SEND_(:normal)  {_SET_ visible: false}
      _SEND_(:over)    {_SET_ visible: false}
      _SEND_(:key_down){_SET_ visible: true}
    end
    _CHECK_MOUSE_:key_up do
      _SEND_(:normal)  {_SET_ visible: false}
      _SEND_(:over)    {_SET_ visible: true}
      _SEND_(:key_down){_SET_ visible: false}
    end
    _END_FRAME_
    _RETURN_ :inner_loop
  end
  inner_loop
end

_LOOP_ do
  _END_FRAME_
end
