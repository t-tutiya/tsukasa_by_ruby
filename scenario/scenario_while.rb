#! ruby -E utf-8

#ボタンコントロール
_CREATE_ :LayoutControl, 
        :x_pos => 150, 
        :y_pos => 150, 
        :width => 256,
        :height => 256,
        :id=>:button1 do
  image :file_path=>"./sozai/button_normal.png", 
        :id=>:normal
  image :file_path=>"./sozai/button_over.png", 
        :id=>:over, :visible => false
  image :file_path=>"./sozai/button_key_down.png", 
        :id=>:key_down, :visible => false
  on_mouse_over do
    set :normal, visible: false
    set :over,   visible: true
    set :key_down, visible: false
  end
  on_mouse_out do
    set :over,   visible: false
    set :normal, visible: true
    set :key_down, visible: false
  end
  on_key_down do
    set :over,   visible: false
    set :normal, visible: false
    set :key_down, visible: true
  end
  on_key_up do
    set :key_down, visible: false
    set :normal, visible: false
    set :over,   visible: true
  end
end


_SEND_ :button1 do
  _WHILE_ [:true] do
    move_line start: [0,0], end: [300,0], total_frame: 60
    wait_command :move_line
    move_line start: [300,0], end: [300,300], total_frame: 60
    wait_command :move_line
    move_line start: [300,300], end: [0,300], total_frame: 60
    wait_command :move_line
    move_line start: [0,300], end: [0,0], total_frame: 60
    wait_command :move_line
  end
end

image :file_path=>"./sozai/button_normal.png", 
      :id=>:img1

_SEND_ :img1 do
  _WHILE_ [:true] do
    move_spline total_frame: 300, path: [
  [ 10.0 * 4,  30.0 * 4],
  [ 77.0 * 4,  49.0 * 4],
  [ 21.0 * 4, 165.0 * 4],
  [171.0 * 4,  43.0 * 4],
  [153.0 * 4, 164.0 * 4],
]
    wait_command :move_spline
  end
end

