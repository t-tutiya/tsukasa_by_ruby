#! ruby -E utf-8

#ボタンコントロール
_CREATE_ :LayoutControl, 
        :x_pos => 0, 
        :y_pos => 0, 
        :width => 256,
        :height => 256,
        :id=>:button1 do
  image :file_path=>"./sozai/button_normal.png", 
        :id=>:normal
  #内部関数の定義
  _DEFINE_ :func do
    move_line start: [0,0], end: [500,0], total_frame: 60
    wait_command :move_line
  end
end

#ボタンコントロール
_CREATE_ :LayoutControl, 
        :x_pos => 0, 
        :y_pos => 0, 
        :width => 256,
        :height => 256,
        :id=>:button2 do
  image :file_path=>"./sozai/button_normal.png", 
        :id=>:normal
  #内部関数の定義
  _DEFINE_ :func do
    move_line start: [0,0], end: [150,500], total_frame: 60
    wait_command :move_line
  end
end

#ボタンコントロール
_CREATE_ :LayoutControl, 
        :x_pos => 0, 
        :y_pos => 0, 
        :width => 100,
        :height => 100,
        :id=>:button3 do
  image :entity=>Image.new(100,100,C_WHITE).draw_font(10, 10, "押す", Font.default, C_BLACK),
        :id=>:normal

  # 「押す」を押すと2つのボタンのfunc関数を呼ぶが、それぞれ違う実装になっているので別々に動く
  on_key_down do
    _SEND_ :button1, root:true do
      func
    end
    _SEND_ :button2, root:true do
      func
    end
  end
end

