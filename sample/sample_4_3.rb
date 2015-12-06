  _INCLUDE_ "./sample/sample4_2.rb"
  _CREATE_ :ImageControl, file_path: "./sozai/button_normal.png",x:256, y:256
  _CREATE_ :LayoutControl, x: 128, y:128, width: 256, height:256 do
    _CREATE_ :LayoutControl, x: 128, y:128, width: 256, height:256, id: :sample02 do
#      TextSelect id: :sample01, text: "test"
    end
    _LOOP_ do
      _CHECK_ mouse: [:cursor_over] do
      #マウスが領域内に入ったら色を変え、文字をスクロールインさせる
        _EVAL_ "pp'over'"
      end
      #マウスが領域外に出たら色を戻し、文字をスクロールインさせる
      _CHECK_ mouse: [:cursor_out] do
        _EVAL_ "pp'out'"
      end
      #マウスがクリックされたら文字列を出力する
      _CHECK_ mouse: [:key_down] do
        _EVAL_ "pp '[" + options[:text] + "]が押されました'"
        _RETURN_
      end
    end
  end

  _CREATE_ :LayoutControl, x: 128, y:128, width: 512, height:512 do
    _CREATE_ :LayoutControl, x: 128, y:128, width: 512, height:512, id: :sample02 do
      _CREATE_ :ImageControl, file_path: "./sozai/button_over.png",x:128, y:128
    end
  end
