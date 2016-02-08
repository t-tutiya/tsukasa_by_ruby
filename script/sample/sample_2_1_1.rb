#ボタンコントロール
_DEFINE_ :button3 do |argument, options|
  _CREATE_ :LayoutControl, 
          x: options[:x] || 0,
          y: options[:y] || 0,
          width: 256,
          height: 256,
          id: options[:id] do
    _CREATE_ :ImageControl, 
      file_path: "./resource/button_normal.png", 
      id: :normal
    _CREATE_ :ImageControl, 
      file_path: "./resource/button_over.png", 
      id: :over, visible: false
    _CREATE_ :ImageControl, 
      file_path: "./resource/button_key_down.png", 
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
end
button3 id: :test01, x: 100, y: 100

_LOOP_ do
  _END_FRAME_
end
