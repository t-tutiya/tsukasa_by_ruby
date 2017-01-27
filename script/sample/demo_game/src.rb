#! ruby -E utf-8

#テキストウィンドウを再作成する
_SEND_(:text0) do
  _SET_ x: 32,
  y: 32,
  width: 1024,
  height: 1024,
  z: 1000000
  _SET_  font_name: "ＭＳ ゴシック"
  _DEFINE_ :_CHAR_RENDERER_ do |argument, options,control|
    _GET_ [:x, :y] do |x:, y:|
      #フェードイン（スペースキーか右CTRLが押されたらスキップ）
      _MOVE_ [30, :out_quart], 
        x:[ 800,x], 
        y:[-600,y] do
          _CHECK_INPUT_ key_down: K_RCONTROL, 
                        key_push: K_SPACE,
                        mouse: :push do
          _SET_ x: x, y:y
          _BREAK_
        end
      end
    end
    #待機フラグが下がるまで待機
    _WAIT_ [:_ROOT_, :_TEMP_], not_equal: {flag: nil}
    #文字列をカスケードアウトさせる
    _GET_ [:x, :y] do |x:, y:|
      _MOVE_ [x/32*3 + 30, :in_back], y:[y, 600]
    end
  end
  _DEFINE_ :_CHAR_WAIT_ do
    _WAIT_  count: 2 do
      _CHECK_INPUT_ key_down: K_RCONTROL, 
                    key_push: K_SPACE,
                    mouse: :push do
        _BREAK_
      end
    end
  end
  _DEFINE_ :_LINE_WAIT_ do
    _WAIT_  count: 2 do
      _CHECK_INPUT_ key_down: K_RCONTROL, 
                    key_push: K_SPACE,
                    mouse: :push do
        _BREAK_
      end
    end
  end
end

#テキストボタン定義
_DEFINE_ :TextSelect do |options|
  _CREATE_ :ClickableLayout,
    float_x: :left,
    shape: [0, 0, 196, 32],
    x: options[:x] || 0, 
    y: options[:y] || 0, 
    width: 196, 
    height: 32 do
    #テキストを描画するDrawableLayout
    _CREATE_ :DrawableLayout,
      float_x: :left,
      width: 196, 
      height: 32, 
      id: :text_area, 
      bgcolor: [255,255,0] do
      _CREATE_ :Char, 
        size: 32, 
        color:[255,255,0], 
        font_name: "ＭＳ ゴシック", 
        char: options[:text]
    end
    _GET_ :x do |x:|
      _MOVE_ [30, :out_quart], 
        x:[800,x] do
        _CHECK_INPUT_ key_down: K_RCONTROL, 
                      key_push: K_SPACE,
                      mouse: :push do
          _SET_ x: 0
         _BREAK_
        end
      end
    end
    _DEFINE_ :inner_loop do
      #マウスが領域内に入ったら色を変え、文字をスクロールインさせる
      _CHECK_ collision: :cursor_over do
        _SEND_(:text_area){
          _SET_ bgcolor: [255,0,255]
        }
      end
      #マウスが領域外に出たら色を戻し、文字をスクロールインさせる
      _CHECK_ collision: :cursor_out do
        _SEND_(:text_area){
          _SET_ bgcolor: [0,255,255]
        }
      end
      #マウスがクリックされたらフラグを立てる
      _CHECK_ collision: :key_push do
        _SET_ [:_ROOT_, :_TEMP_], flag: options[:id]
        _EVAL_ "puts '[" + options[:text].to_s + "]が押されました'"
      end
      #フラグが立っていればボタンをアウトさせてループを終了する
      _CHECK_ [:_ROOT_, :_TEMP_],  not_equal: {flag: nil} do
        _MOVE_ [60, :in_back], y:[0,600]
        _DELETE_
        _RETURN_
      end
      _END_FRAME_
      _RETURN_ do
        inner_loop
      end
    end
    inner_loop
  end
end

#文字列中にボタンを埋め込む
_DEFINE_ :func_select do |options|
  _SEND_ :text0 do
    _CHAR_COMMAND_ width: 196, height: 32 do |x:, y:|
      TextSelect id: options[:id], text: options[:_ARGUMENT_], x: x, y:y
      _WAIT_  count: 3 do
        _CHECK_INPUT_ key_down: K_RCONTROL, 
                      key_push: K_SPACE,
                      mouse: :push do
          _BREAK_
        end
      end
    end
  end
end
