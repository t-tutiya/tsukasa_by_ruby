#! ruby -E utf-8

#ボタンコントロール
button  id: :button1, 
        x: 150,
        y: 150 do
  #内部関数の定義
  _DEFINE_ :func do |val|
    _MOVE_ type: {y: val[:y]}, time: 60, easing: :out_elastic
    wait_command :_MOVE_
  end
end

_SEND_  :button1 do
  _MOVE_ type: {x: 0, y: 300}, time: 60, easing: :in_quint
  wait_command :_MOVE_
  _MOVE_ type: {x: 300, y: 300}, time: 60, easing: :in_quint
  wait_command :_MOVE_
  _MOVE_ type: {x: 300, y: 0}, time: 60, easing: :in_quint
  wait_command :_MOVE_
  _MOVE_ type: {x: 0, y: 0}, time: 60, easing: :in_quint
  wait_command :_MOVE_
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
  _MOVE_ type: {x: [0, 600], y: [0, 300]}, time: 60, easing: :out_bounce
end


