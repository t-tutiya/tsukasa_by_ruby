_RESIZE_ width:640, height:480

_CREATE_ :Layout , id: :layout01 do

_CREATE_ :Char, 
  id: :comment_area,
  size: 32, 
  y: 256+196,
  color:[255,255,0], 
  font_name: "ＭＳ ゴシック",
  char: " "

_CREATE_ :ClickableLayout, x: 640-256, y: 480-256, shape:[0,0,256,256], width:256, height: 256 do
  _CREATE_ :Image, path: "./resource/button_normal.png"
  _DEFINE_ :inner_loop do
    _CHECK_ collision: :cursor_over do 
      _SET_ [:_ROOT_ ,:_SYSTEM_] , data0: true
    end
    _HALT_
    _RETURN_ do
      inner_loop
    end
  end
  inner_loop
end

_CREATE_ :Layout , id: :cursor do
  _CREATE_ :TileMap, 
    map_array: [[0]], size_x: 1, size_y: 1, width:32, height:32 do
    _SET_TILE_GROUP_ path: "./resource/icon/icon_4_a.png",
      x_count: 4, y_count: 1
    _DEFINE_ :inner_loop do
      _MAP_STATUS_ 0
      _WAIT_ count: 5
      _MAP_STATUS_ 1
      _WAIT_ count: 5
      _MAP_STATUS_ 2
      _WAIT_ count: 5
      _MAP_STATUS_ 3
      _WAIT_ count: 5
      _RETURN_ do
        inner_loop
      end
    end
    inner_loop
  end
end

end
_SET_ mouse_enable: false

_HALT_

_LOOP_ do
  _GET_ [:mouse_x, :mouse_y], control: [:_ROOT_] do |mouse_x:, mouse_y:|
    _SEND_ [:layout01, :comment_area] do
      _SET_ char: mouse_x.to_s + ":" + mouse_y.to_s
    end
    _SEND_ [:layout01, :cursor] do
      _SET_ x: mouse_x, y: mouse_y
    end
  end
  _CHECK_ [:_ROOT_, :_SYSTEM_], equal: {data0: true},key_down: [K_Z] do
    _GET_ [:mouse_x, :mouse_y], control: [:_ROOT_] do |mouse_x:, mouse_y:|
      _SEND_ [:layout01, :cursor] do 
        _MOVE_ [30, :out_quart], 
          x: [mouse_x, 0], 
          y: [mouse_y, 0]
      end
      _MOVE_ 30,  mouse_x: [mouse_x, 0], 
                  mouse_y: [mouse_y, 0] do
        _GET_ [:mouse_x, :mouse_y], control: [:_ROOT_] do |mouse_x:, mouse_y:|
          _SEND_ [:layout01, :comment_area] do
            _SET_ char: mouse_x.to_s + ":" + mouse_y.to_s
          end
        end
      end
    end
    _SET_ mouse_x:0, mouse_y:0
    _SET_ [:_ROOT_ , :_SYSTEM_] , data0: false
  end
  _CHECK_INPUT_ mouse: :right_push do
    _SEND_ :layout01, interrupt: true do
      _DELETE_
    end
    _RESIZE_ width:1024, height:600
    _BREAK_
  end
  _HALT_
end

#カーソル可視設定
_SET_ mouse_enable: true

