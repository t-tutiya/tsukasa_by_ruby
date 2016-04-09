_CREATE_ :TileMapControl, 
  map_array: [[0]], size_x: 1, size_y: 1, width:32, height:32 do
  _SET_TILE_GROUP_ file_path: "./resource/icon/icon_4_a.png",
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

_LOOP_ do
  _END_FRAME_
end