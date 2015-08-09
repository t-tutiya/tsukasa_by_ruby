#! ruby -E utf-8

#ボタンコントロール
create :ButtonControl, 
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
    set target: :normal, visible: false
    set target: :over,   visible: true
    set target: :key_down, visible: false
  end
  on_mouse_out do
    set target: :over,   visible: false
    set target: :normal, visible: true
    set target: :key_down, visible: false
  end
  on_key_down do
    set target: :over,   visible: false
    set target: :normal, visible: false
    set target: :key_down, visible: true
  end
  on_key_up do
    set target: :key_down, visible: false
    set target: :normal, visible: false
    set target: :over,   visible: true
  end
  #内部関数の定義
  _DEFINE_ :func do |val|
    move_line x: 0, y: val[:y],   count:0, frame: 60, start_x: 0,   start_y: 0
    wait_command :move_line
  end
end

_ALIAS_ :move_line2 , command_name: :move_line

about target: :button1 do
  move_line2 x: 0, y: 300,   count:0, frame: 60, start_x: 0,   start_y: 0
  wait_command :move_line
  move_line2 x: 300, y: 300, count:0, frame: 60, start_x: 0, start_y: 300
  wait_command :move_line
  move_line2 x: 300,   y: 0, count:0, frame: 60, start_x: 300, start_y: 300
  wait_command :move_line
  move_line2 x: 0,   y: 0,   count:0, frame: 60, start_x: 300,   start_y: 0
  wait_command :move_line
  #渡せるのは名前付きオプションのみ(targetは自動で渡される)
  func y: 150
end

_DEFINE_ :func2 do
  image :file_path=>"./sozai/button_normal.png", 
       :id=>:normal2 do
   
    _YIELD_
   
  end
end

#functionを実行後、ブロック内のコマンドを実行する
#TODO：aboutではなく、func2の引数で送信先を指定できないものか
func2 do
  _EVAL_ "pp 'test'"
  pp "func2"
  move_line x: 600, y: 300,   count:0, frame: 60, start_x: 0,   start_y: 0
end


