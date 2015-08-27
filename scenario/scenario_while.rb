#! ruby -E utf-8

#以下はいずれ全部画像処理系のスクリプトサンプルに持っていく
#TODO：サンプル実行に必要なリソースファイルをアップする

_CREATE_ :LayoutControl , 
          width: 1280, 
          height: 720 , 
          rule: "sozai/rule/circle_rule.png" do
  _CREATE_ :ImageControl, file_path: "./sozai/bg_sample.png", id: :test

  _WHILE_ [:true] do
    transition_rule :count=> 0, :total_frame => 120, :vague => 50
    _WAIT_ [:command], :command => :transition_rule
  end
end

button id: :button1
_SEND_ :button1 do
  _WHILE_ [:true] do
    move end: [300,0], total_frame: 60
    wait_command :move
    move end: [300,300,255], total_frame: 60
    wait_command :move
    move end: [0,300,0], total_frame: 60
    wait_command :move
    move end: [0,0,255], total_frame: 60
    wait_command :move
  end
end

button id: :button2
_SEND_ :button2 do
  _WHILE_ [:true] do
    move_path total_frame: 300, path: [
  [ 10.0 * 4,  30.0 * 4, 255],
  [ 77.0 * 4,  49.0 * 4, 0],
  [ 21.0 * 4, 165.0 * 4, 255],
  [171.0 * 4,  43.0 * 4,0],
  [153.0 * 4, 164.0 * 4, 255],
]
    wait_command :move_path
  end
end

button id: :button3
_SEND_ :button3 do
  _WHILE_ [:true] do
    move_path total_frame: 300, type: :spline, path: [
#  [ 10.0 * 4,  30.0 * 4, 0],
#  [ 77.0 * 4,  49.0 * 4, 255],
#  [ 21.0 * 4, 165.0 * 4, 0],
#  [171.0 * 4,  43.0 * 4,255],
#  [153.0 * 4, 164.0 * 4, 0],
  [ 10.0 * 4,  30.0 * 4],
  [ 77.0 * 4,  49.0 * 4],
  [ 21.0 * 4, 165.0 * 4],
  [171.0 * 4,  43.0 * 4],
  [153.0 * 4, 164.0 * 4],
]
    wait_command :move_path
  end
end
