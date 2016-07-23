#ボタンコントロール
_DEFINE_ :button3 do |argument, options|
  _CREATE_ :ClickableLayout, 
    x: options[:x] || 0,
    y: options[:y] || 0,
    width: 256,
    height: 256,
    id: options[:id] do

    _CREATE_ :TileMap, 
      width: 256, height: 256 do
      _SET_ map_array: [[0]]
      _SET_TILE_ 0, path: options[:normal]||"./resource/button_normal.png"
      _SET_TILE_ 1, path: options[:over]||"./resource/button_over.png"
      _SET_TILE_ 2, path: options[:down]||"./resource/button_key_down.png"
    end

    _STACK_LOOP_ do
      _CHECK_ mouse: [:cursor_over] do
        _SEND_(0){ _MAP_STATUS_ 1}
      end
      _CHECK_ mouse: [:cursor_out] do
        _SEND_(0){ _MAP_STATUS_ 0}
      end
      _CHECK_ mouse: [:key_down] do
        _SEND_(0){ _MAP_STATUS_ 2}
      end
      _CHECK_ mouse: [:key_up] do
        _SEND_(0){ _MAP_STATUS_ 1}
      end
      _END_FRAME_
    end
  end
end
button3 id: :test01, x: 100, y: 100

_LOOP_ do
  _END_FRAME_
end
