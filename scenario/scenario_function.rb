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
  #内部関数の定義
  _DEFINE_ :func do |val|
    move start: [0,0], end: [0,val[:y]], total_frame: 60
    wait_command :move
  end
end

_SEND_  :button1 do
  move start: [0,0], end: [0,300], total_frame: 60
  wait_command :move
  move start: [0,300], end: [300,300], total_frame: 60
  wait_command :move
  move start: [300,300], end: [300,0], total_frame: 60
  wait_command :move
  move start: [300,0], end: [0,0], total_frame: 60
  wait_command :move
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
  move start: [0,0], end: [600,300], total_frame: 60
end


