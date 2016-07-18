#ボタンコントロール
_CREATE_ :ClickableLayoutControl, 
        width: 256,
        height: 256,
        id: :button1,
        colorkey_id: :normal,
        colorkey_border:200 do
  _CREATE_ :ImageControl, file_path: "./resource/star_button.png", 
    id: :normal
  _CREATE_ :ImageControl, file_path: "./resource/button_over.png", 
    id: :over, visible: false
  _CREATE_ :ImageControl, file_path: "./resource/button_key_down.png", 
    id: :key_down, visible: false
  _STACK_LOOP_ do
    _CHECK_ mouse: [:cursor_over] do
      _SEND_(:normal)  {_SET_ visible: false}
      _SEND_(:over)    {_SET_ visible: true}
      _SEND_(:key_down){_SET_ visible: false}
    end
    _CHECK_ mouse: [:cursor_out] do
      _SEND_(:normal)  {_SET_ visible: true}
      _SEND_(:over)    {_SET_ visible: false}
      _SEND_(:key_down){_SET_ visible: false}
    end
    _CHECK_ mouse: [:key_down] do
      _SEND_(:normal)  {_SET_ visible: false}
      _SEND_(:over)    {_SET_ visible: false}
      _SEND_(:key_down){_SET_ visible: true}
    end
    _CHECK_ mouse: [:key_up] do
      _SEND_(:normal)  {_SET_ visible: false}
      _SEND_(:over)    {_SET_ visible: true}
      _SEND_(:key_down){_SET_ visible: false}
    end
    _END_FRAME_
  end
end

_LOOP_ do
  _END_FRAME_
end
