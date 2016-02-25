#ボタンコントロール
_CREATE_ :ClickableLayoutControl, 
  width: 256,
  height: 256,
  id: :button1,
  collision_shape: [128,128,128] do
  _CREATE_ :ImageControl, entity: Image.new(256,256).circle_fill(128,128,128,C_BLUE).draw_font(80, 120, "NORMAL", Font.default),
        id: :normal
  _CREATE_ :ImageControl, entity: Image.new(256,256).circle_fill(128,128,128,C_YELLOW).draw_font(80, 120, "OVER", Font.default, C_BLACK),
        id: :over, visible: false
  _CREATE_ :ImageControl, entity: Image.new(256,256).circle_fill(128,128,128,C_GREEN).draw_font(80, 120, "DOWN", Font.default),
    id: :key_down, visible: false
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
