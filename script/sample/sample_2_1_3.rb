#ボタンコントロール
_CREATE_ :ClickableLayoutControl, 
        width: 256,
        height: 256,
        id: :button1 do
  _CREATE_ :ImageControl, file_path: "./resource/star_button.png", 
    id: :normal
  _CREATE_ :ImageControl, file_path: "./resource/button_over.png", 
    id: :over, visible: false
  _CREATE_ :ImageControl, file_path: "./resource/button_key_down.png", 
    id: :key_down, visible: false
  _CREATE_ :ColorkeyControl, file_path: "./resource/star_button.png", 
      id: :colorkey, border: 200
  _SET_ colorkey: :colorkey
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
