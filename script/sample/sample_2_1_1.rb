#ボタンコントロール
_CREATE_ :ClickableLayout, x: 100, y: 100, shape:[0,0,256,256],width: 256, height: 256, id: :test01 do
  _CREATE_ :TileMap, 
    width: 256, height: 256 do
    _SET_ map_array: [[0]]
    _SET_TILE_ 0, path: "./resource/button_normal.png"
    _SET_TILE_ 1, path: "./resource/button_over.png"
    _SET_TILE_ 2, path: "./resource/button_key_down.png"
  end

  _DEFINE_ :inner_loop do
    _CHECK_MOUSE_ :cursor_over do
      _SEND_(0){ _MAP_STATUS_ 1}
    end
    _CHECK_MOUSE_:cursor_out do
      _SEND_(0){ _MAP_STATUS_ 0}
    end
    _CHECK_MOUSE_:key_down do
      _SEND_(0){ _MAP_STATUS_ 2}
    end
    _CHECK_MOUSE_:key_up do
      _SEND_(0){ _MAP_STATUS_ 1}
    end
    _END_FRAME_
    _RETURN_ do
      inner_loop
    end
  end
  inner_loop
end

_WAIT_ input:{mouse: :right_push}

_SEND_ :test01, interrupt: true do
  _DELETE_
end
