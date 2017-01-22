_CREATE_ :ClickableLayout, 
  width:256, 
  height:256,
  shape: [0,0,256,256],
  id: :test01 do
  _CREATE_ :TileMap, id: :icon, 
    width: 256,
    height: 256 do
    _SET_ map_array: [[0]]
    _SET_TILE_ 0, path: "./resource/button_normal.png"
    _SET_TILE_ 1, path: "./resource/button_over.png"
    _SET_TILE_ 2, path: "./resource/button_key_down.png"
  end

  _DEFINE_ :drug_control do
    #カーソルが画像の上に来るまで待機
    _WAIT_ do
      _CHECK_ collision:  :cursor_on do
        _BREAK_
      end
    end

    #画像を「OVER」に差し替える
    _SEND_ :icon do
      _MAP_STATUS_ 1
    end

    #キーがクリックされるまで待機
    _WAIT_ do
      _CHECK_ collision: :key_push do
        _GET_ [:cursor_x, :cursor_y] do |cursor_x:, cursor_y:|
          _SET_ offset_x: - cursor_x, offset_y: - cursor_y
        end
        _BREAK_
      end
      _CHECK_ collision: :cursor_out do
        _BREAK_
      end
    end

    #カーソルが画像の外に移動した場合
    _CHECK_ collision:  :cursor_out do
      #画像を「NORMAL」に差し替える
      _SEND_ :icon do
        _MAP_STATUS_ 0
      end
      #ループの最初に戻る
      _RETURN_ do
        drug_control
      end
    end

    #画像を「DOWN」に差し替える
    _SEND_ :icon do
      _MAP_STATUS_ 2
    end

    #キーが離されるまで待機し、その間ブロックを実行する
    _WAIT_ do
      _CHECK_ collision:  :key_up do
        _GET_ [[:mouse_x, [:_ROOT_]], 
               [:mouse_y, [:_ROOT_]], 
                :offset_x, 
                :offset_y] do |
                mouse_x:, 
                mouse_y:, 
                offset_x:, 
                offset_y:|
          _SET_ x: mouse_x + offset_x, 
                y: mouse_y + offset_y
        end
        _SET_ offset_x: 0, 
              offset_y: 0
        _BREAK_
      end

      _GET_ [:mouse_x, :mouse_y], control: [:_ROOT_] do |mouse_x:, mouse_y:|
        #コントロールのＸＹ座標にカーソルの移動オフセット値を加算
        _SET_ x: mouse_x, y: mouse_y
      end
    end
    _RETURN_ do
      drug_control
    end
  end
  
  drug_control
end

_WAIT_ input:{mouse: :right_push}

_SEND_ :test01, interrupt: true do
  _DELETE_
end

