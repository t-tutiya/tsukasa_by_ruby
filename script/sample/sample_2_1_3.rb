#ボタンコントロール
_CREATE_ :ClickableLayout, 
        width: 256,
        height: 256,
        id: :button1,
        colorkey_id: :normal,
        colorkey_border:200 do
  _CREATE_ :Image, path: "./resource/star_button.png", 
    id: :normal
  _CREATE_ :Image, path: "./resource/button_over.png", 
    id: :over, visible: false
  _CREATE_ :Image, path: "./resource/button_key_down.png", 
    id: :key_down, visible: false

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
    _RETURN_ do
      inner_loop
    end
  end
  inner_loop
end

_LOOP_ do
  _END_FRAME_
end
