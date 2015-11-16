#テキストボタン定義
_DEFINE_ :TextSelect do |options|
  _CREATE_ :LayoutControl,
    x: options[:x], y: options[:y], width: 350, height: 32, id: options[:id] do
    #テキストを描画するRenderTarget
    _CREATE_ :RenderTargetControl,
      width: 350, height: 32, id: :text_area, bgcolor: [255,255,255] do
      _CREATE_ :CharControl, size: 32, font_name: "ＭＳＰ ゴシック", charactor: options[:text]
    end

    _DEFINE_ :func_test do

      #マウスが領域内に入ったら色を変え、文字をスクロールインさせる
      on_mouse_over do
        _EVAL_ "pp 'over'"
        text_area{
          _SET_ bgcolor: [0,255,255]
          last{
            _MOVE_ 30, x:[350,0], option:{easing: :out_cubic}
            _SET_ color:  [255,0,0], edge_color: [255,255,255]
          }
        }
      end
      #マウスが領域外に出たら色を戻し、文字をスクロールインさせる
      on_mouse_out do
        _EVAL_ "pp 'out'"
        text_area{
          _SET_ bgcolor: [255,255,255]
          last{
            _MOVE_ 30, x:[350,0], option:{easing: :out_cubic}
            _SET_ color:  [255,255,255], edge_color: [0,0,0]
          }
        }
      end
      #マウスがクリックされたら文字列を出力する
      on_key_down do
        _EVAL_ "pp '[" + options[:text] + "]が押されました'"
        _RETURN_
      end
      _YIELD_
      
      _END_FRAME_
      _SEND_ do
        func_test
      end
    end
     func_test
  end
end

#メインシーン
_CREATE_ :LayoutControl, width: 800, height: 600, id: :main_scene do
  _DEFINE_ :func_test3 do
    on_right_key_down do
      _SEND_ROOT_ do
        def_menu_scene
      end
        _EVAL_ "pp 'end MAIN scene'"
      _SLEEP_
    end
    _END_FRAME_
    func_test3
  end
  
  func_test3
end

#メニューシーン
_DEFINE_ :def_menu_scene do
  _CREATE_ :LayoutControl, width: 800, height: 600, id: :menu_scene do
    #ボタンを生成する
    TextSelect id: :select1, x:800, y: 64, text: "SAVE"
    TextSelect id: :select2, x:800, y:128, text: "LOAD"
    TextSelect id: :select3, x:800, y:192, text: "STATUS"
    TextSelect id: :select4, x:800, y:256, text: "CONFIG"
    TextSelect id: :select5, x:800, y:256+64, text: "???"

    _DEFINE_ :func_test do
      on_right_key_down do
        _EVAL_ "pp 'end menu scene'"
        _RETURN_
      end
      _END_FRAME_
      func_test
    end

    #ボタンを順番にスクロールインさせる
    select1{ _MOVE_ 10, x: 600, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select2(interrupt: true){ _MOVE_ 10, x: 600, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select3(interrupt: true){ _MOVE_ 10, x: 600, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select4(interrupt: true){ _MOVE_ 10, x: 600, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select5(interrupt: true){ _MOVE_ 10, x: 600, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select6(interrupt: true){ _MOVE_ 10, x: 600, option:{easing: :out_cubic}}
    _WAIT_ count:10

    func_test

    select1{ _MOVE_ 5, x: 800, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select2(interrupt: true){ _MOVE_ 5, x: 800, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select3(interrupt: true){ _MOVE_ 5, x: 800, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select4(interrupt: true){ _MOVE_ 5, x: 800, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select5(interrupt: true){ _MOVE_ 5, x: 800, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select6(interrupt: true){ _MOVE_ 5, x: 800, option:{easing: :out_cubic}}
    _WAIT_ count:5
    _WAKE_ :main_scene
    _DELETE_
  end
end
