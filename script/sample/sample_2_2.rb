_CREATE_ :TileMapControl, 
  map_array: [[0]], size_x: 1, size_y: 1 do
  _ADD_TILE_GROUP_ file_path: "./resource/icon/icon_4_a.png",
    x_count: 4, y_count: 1
  _STACK_LOOP_ do
    _MAP_STATUS_ x:0, y:0, id:0
    _WAIT_ count: 5
    _MAP_STATUS_ x:0, y:0, id:1
    _WAIT_ count: 5
    _MAP_STATUS_ x:0, y:0, id:2
    _WAIT_ count: 5
    _MAP_STATUS_ x:0, y:0, id:3
    _WAIT_ count: 5
  end
end

_LOOP_ do
  _END_FRAME_
end