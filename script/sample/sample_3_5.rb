_RESIZE_ width:640, height:480

_CREATE_ :Char, 
  id: :comment_area,
  size: 32, 
  y: 256+196,
  color:[255,255,0], 
  font_name: "ＭＳ ゴシック",
  char: " "

_CREATE_ :ClickableLayout, x: 640-256, y: 480-256, width:256, height: 256 do
  _CREATE_ :Image, path: "./resource/button_normal.png"
  _STACK_LOOP_ do |a,b,c|
    _CHECK_ mouse: [:cursor_over] do 
      _SET_ :_SYSTEM_ , data0: true
    end
    _END_FRAME_
  end
end

_CREATE_ :Layout , id: :cursor do
  _CREATE_ :TileMap, 
    map_array: [[0]], size_x: 1, size_y: 1, width:32, height:32 do
    _SET_TILE_GROUP_ path: "./resource/icon/icon_4_a.png",
      x_count: 4, y_count: 1
    _STACK_LOOP_ do
      _MAP_STATUS_ 0
      _WAIT_ count: 5
      _MAP_STATUS_ 1
      _WAIT_ count: 5
      _MAP_STATUS_ 2
      _WAIT_ count: 5
      _MAP_STATUS_ 3
      _WAIT_ count: 5
    end
  end
end

_MOUSE_ENABLE_ false

_LOOP_ do
  _GET_ [:mouse_x, :mouse_y] do |options|
    _SEND_ :comment_area do
      _SET_ char: options[:mouse_x].to_s + ":" + options[:mouse_y].to_s
    end
    _SEND_ :cursor do
      _SET_ x: options[:mouse_x], y: options[:mouse_y]
    end
  end
  _CHECK_ :_SYSTEM_, equal: {data0: true},key_down: [K_Z] do
    _SEND_ :cursor do 
      _MOVE_ 30, x:0, y:0, _OPTION_:{easing: :out_quart}
    end
    _MOVE_ 30, mouse_x:0, mouse_y:0 do
      _GET_ [:mouse_x, :mouse_y] do |options|
        _SEND_ :comment_area do
          _SET_ char: options[:mouse_x].to_s + ":" + options[:mouse_y].to_s
        end
      end
    end
    _SET_ mouse_x:0, mouse_y:0
    _SET_ :_SYSTEM_ , data0: false
  end
  _END_FRAME_
end

_END_PAUSE_
#カーソル可視設定
_MOUSE_ENABLE_ true

