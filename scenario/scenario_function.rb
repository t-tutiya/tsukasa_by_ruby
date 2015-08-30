#! ruby -E utf-8

#ボタンコントロール
button  id: :button1, 
        x_pos: 150,
        y_pos: 150 do
  #内部関数の定義
  _DEFINE_ :func do |val|
    move start: [0,0], last: [0,val[:y]], total_frame: 60
    wait_command :move
  end
end

_SEND_  :button1 do
  move start: [0,0], last: [0,300], total_frame: 60
  wait_command :move
  move start: [0,300], last: [300,300], total_frame: 60
  wait_command :move
  move start: [300,300], last: [300,0], total_frame: 60
  wait_command :move
  move start: [300,0], last: [0,0], total_frame: 60
  wait_command :move
  #渡せるのは名前付きオプションのみ(targetは自動で渡される)
  func y: 150
end

_DEFINE_ :func2 do
  _CREATE_ :ImageControl, :file_path=>"./sozai/button_normal.png", 
       :id=>:normal2 do
   
    _YIELD_
   
  end
end

#functionを実行後、ブロック内のコマンドを実行する
#TODO：aboutではなく、func2の引数で送信先を指定できないものか
func2 do
  _EVAL_ "pp 'test'"
  pp "func2"
  move start: [0,0], last: [600,300], total_frame: 60
end


