#! ruby -E utf-8

#ボタンコントロール
_CREATE_ :RenderTargetControl, 
        :x => 0, 
        :y => 0, 
        :width => 256,
        :height => 256,
        :id=>:button1 do
  _CREATE_ :ImageControl, :file_path=>"./sozai/button_normal.png", 
        :id=>:normal
  #内部関数の定義
  _DEFINE_ :func do
    _MOVE_ 60, x: 500
    wait_command :_MOVE_
  end
end

#ボタンコントロール
_CREATE_ :RenderTargetControl, 
        :x => 0, 
        :y => 0, 
        :width => 256,
        :height => 256,
        :id=>:button2 do
  _CREATE_ :ImageControl, :file_path=>"./sozai/button_normal.png", 
        :id=>:normal
  #内部関数の定義
  _DEFINE_ :func do
    _MOVE_ 60, x: 150, y: 500
    wait_command :_MOVE_
  end
end

#ボタンコントロール
_CREATE_ :LayoutControl, 
        :x => 0, 
        :y => 0, 
        :width => 100,
        :height => 100,
        :id=>:button3 do
  _CREATE_ :ImageControl, :entity=>Image.new(100,100,C_WHITE).draw_font(10, 10, "押す", Font.default, C_BLACK),
        :id=>:normal

  # 「押す」を押すと2つのボタンのfunc関数を呼ぶが、それぞれ違う実装になっているので別々に動く
  _DEFINE_ :func do
    _CHECK_ mouse: [:on_key_down] do
      _SEND_ROOT_ do
        button1{func}
      end
      _SEND_ROOT_ do
        button2{func}
      end
    end
    _END_FRAME_
    func
  end
  func
end

