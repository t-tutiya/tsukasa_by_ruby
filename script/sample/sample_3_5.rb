_RESIZE_ width:640, height:480

_CREATE_ :CharControl, 
  id: :comment_area,
  size: 32, 
  y: 256+196,
  color:[255,255,0], 
  font_name: "ＭＳ ゴシック",
  charactor: " "

_CREATE_ :LayoutControl, x: 640-256, y: 480-256, width:256, height: 256 do
  _CREATE_ :ImageControl, file_path: "./resource/button_normal.png"
  _STACK_LOOP_ do |a,b,c|
    _CHECK_ mouse: [:cursor_over] do 
      _SET_ :_SYSTEM_ , data0: true
    end
    _END_FRAME_
  end
end

_CREATE_ :LayoutControl , id: :cursor do
  _CREATE_ :TileMapControl, 
    map_array: [[0]], size_x: 1, size_y: 1 do
    _SET_IMAGE_MAPPING_ file_path: "./resource/icon/icon_4_a.png",
      x_count: 4, y_count: 1
    _STACK_LOOP_ do
      _SET_TILE_ x:0, y:0, id:0
      _WAIT_ count: 5
      _SET_TILE_ x:0, y:0, id:1
      _WAIT_ count: 5
      _SET_TILE_ x:0, y:0, id:2
      _WAIT_ count: 5
      _SET_TILE_ x:0, y:0, id:3
      _WAIT_ count: 5
    end
  end
end

_CURSOR_VISIBLE_ false

_LOOP_ do |a,b,c|
  _SEND_ :comment_area do
    _SET_ charactor: c.cursor_x.to_s + ":" + c.cursor_y.to_s
  end
  #pp c.cursor_x.to_s + ":" + c.cursor_y.to_s
  _SEND_ :cursor do
    _SET_ x: c.cursor_x, y: c.cursor_y
  end
  _CHECK_ :_SYSTEM_, equal: {data0: true},key_down: [K_Z] do
    _SEND_ :cursor do 
      _MOVE_ 30, x:0, y:0, option:{easing: :out_quart}
    end
    _MOVE_ 30, cursor_x:0, cursor_y:0
    _WAIT_ count: 30 do |a,b,c2|
      _SEND_ :comment_area do
        _SET_ charactor: c2.cursor_x.to_s + ":" + c2.cursor_y.to_s
      end
    end
    _SET_ cursor_x:0, cursor_y:0
    _SET_ :_SYSTEM_ , data0: false
  end
  _END_FRAME_
end

end_pause
#カーソル可視設定
_CURSOR_VISIBLE_ true

