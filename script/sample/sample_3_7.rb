_CREATE_ :ClickableLayoutControl, 
  width:256, 
  height:256,
  id: :drag_unit do
  _CREATE_ :TileMapControl, 
    width: 256,
    height: 256 do
    _SET_ map_array: [[0]]
    _SET_IMAGE_ 0, file_path: "./resource/button_normal.png"
    _SET_IMAGE_ 1, file_path: "./resource/button_over.png"
    _SET_IMAGE_ 2, file_path: "./resource/button_key_down.png"
  end
  _STACK_LOOP_ do
    _END_FRAME_
    _CHECK_ mouse: [:cursor_over] do
      _SEND_(0){ _SET_TILE_ x:0, y:0, id: 1}
    end
    _CHECK_ mouse: [:cursor_out] do
      _SEND_(0){ _SET_TILE_ x:0, y:0, id: 0}
    end
    _CHECK_ mouse: [:key_down] do
      _SEND_(0){ _SET_TILE_ x:0, y:0, id: 2}
      _WAIT_ mouse: [:key_up] do |arg,options,control|
        _MOVE_ 1, x: control.cursor_offset_x, y: control.cursor_offset_y, option:{offset: true}
      end
    end
    _CHECK_ mouse: [:key_up] do
      _SEND_(0){ _SET_TILE_ x:0, y:0, id: 1}
    end
  end
end

_LOOP_ do
  _END_FRAME_
end