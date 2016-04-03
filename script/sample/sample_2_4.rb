_CREATE_ :ClickableLayoutControl, 
  width:256, 
  height:256 do
  _CREATE_ :TileMapControl, id: :icon, 
    width: 256,
    height: 256 do
    _SET_ map_array: [[0]]
    _ADD_TILE_ 0, file_path: "./resource/button_normal.png"
    _ADD_TILE_ 1, file_path: "./resource/button_over.png"
    _ADD_TILE_ 2, file_path: "./resource/button_key_down.png"
  end
  #ループ
  _LOOP_ do
    #カーソルが画像の上に来るまで待機
    _WAIT_ mouse: [:cursor_on]

    #画像を「OVER」に差し替える
    icon{ _MAP_STATUS_ 1}

    #キーがクリックされるまで待機
    _WAIT_ mouse: [:key_down, :cursor_out]

    #カーソルが画像の外に移動した場合
    _CHECK_ mouse: [:cursor_out] do
      #画像を「NORMAL」に差し替える
      icon{ _MAP_STATUS_ 0}
      #ループの最初に戻る
      _NEXT_
    end

    #画像を「DOWN」に差し替える
    icon{ _MAP_STATUS_ 2}

    #キーが離されるまで待機し、その間ブロックを実行する
    _WAIT_ mouse: [:key_up] do
      #コントロールプロパティを取得
      _GET_ [:cursor_offset_x, :cursor_offset_y] do 
             |cursor_offset_x:, cursor_offset_y:|
        #コントロールのＸＹ座標にカーソルの移動オフセット値を加算
        _SET_OFFSET_ x: cursor_offset_x, y: cursor_offset_y
      end
    end
  end
end

_LOOP_ do
  _END_FRAME_
end