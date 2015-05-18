#! ruby -E utf-8

#ボタンコントロール
create :ButtonControl, 
        :x_pos => 0, 
        :y_pos => 0, 
        :id=>:button1 do
  create :ImageControl, 
         :file_path=>"./sozai/button_normal.png", 
         :id=>:normal
  create :ImageControl, 
        :file_path=>"./sozai/button_over.png", 
        :id=>:over,
        :visible => false
  create :ImageControl, 
        :file_path=>"./sozai/button_key_down.png", 
        :id=>:key_down,
        :visible => false
  create :ImageControl, 
        :file_path=>"./sozai/button_key_up.png", 
        :id=>:key_up,
        :visible => false
  create :ImageControl, 
        :file_path=>"./sozai/button_out.png", 
        :id=>:out,
        :visible => false
  normal
  
  define :func do |val|
    about :button1 do
      move_line x: 0, y: val[:y],   count:0, frame: 60, start_x: 0,   start_y: 0
      wait_command :move_line
    end
  end
end

about :button1 do
  move_line x: 0, y: 300,   count:0, frame: 60, start_x: 0,   start_y: 0
  wait_command :move_line
  move_line x: 300, y: 300, count:0, frame: 60, start_x: 0, start_y: 300
  wait_command :move_line
  move_line x: 300,   y: 0, count:0, frame: 60, start_x: 300, start_y: 300
  wait_command :move_line
  move_line x: 0,   y: 0,   count:0, frame: 60, start_x: 300,   start_y: 0
  
  wait_command :move_line
  #渡せるのは名前付きオプションのみ(targetは自動で渡される)
  func y: 150
end

define :func2 do
  create :ImageControl, 
         :file_path=>"./sozai/button_normal.png", 
         :id=>:normal2
end

#functionを実行後、ブロック内のコマンドを実行する
#TODO：aboutではなく、func2の引数で送信先を指定できないものか
func2 do
  about :normal2 do
    move_line x: 600, y: 300,   count:0, frame: 60, start_x: 0,   start_y: 0
  end
end