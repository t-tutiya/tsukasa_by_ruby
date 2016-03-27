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
    #フェードイン（スペースキーか右CTRLが押されたらスキップ）
    _MOVE_   30, 
      x:[800,0], 
      y:[-600,0],
      _OPTION_: { easing: :out_quart, 
                check: {key_down: K_RCONTROL, 
                        key_push: K_SPACE,
                        system: :key_down}
              }
    _SET_ x: 0, y:0
    #待機フラグが下がるまで待機
    _WAIT_ :_TEMP_, not_equal: {flag: nil}
    #文字列をカスケードアウトさせる
    _GET_ :child_index do |arg, options|
      _MOVE_ 30 + options[:child_index] * 3, y:[0,600], _OPTION_:{easing: :in_back}
    end
  end
  _DEFINE_ :_CHAR_WAIT_ do
    _WAIT_  count: 2,
            key_down: K_RCONTROL,
            key_push: K_SPACE,
            system: :key_down
  end
  _DEFINE_ :_LINE_WAIT_ do
    _WAIT_  count: 2,
            key_down: K_RCONTROL,
            key_push: K_SPACE,
            system: :key_down
  end
end

#テキストボタン定義
_DEFINE_ :TextSelect do |argument, options|
  _CREATE_ :ClickableLayoutControl,
    float_x: :left,
    x: options[:x] || 0, 
    y: options[:y] || 0, 
    width: 196, 
    height: 32, 
    id: :Anonymous_CharControl do
    #テキストを描画するRenderTarget
    _CREATE_ :RenderTargetControl,
      float_x: :left,
      width: 196, 
      height: 32, 
      id: :text_area, 
      bgcolor: [255,255,0] do
      _CREATE_ :CharControl, 
        size: 32, 
        color:[255,255,0], 
        font_name: "ＭＳ ゴシック", 
        charactor: options[:text]
      _MOVE_ 30, 
        alpha:[0,255],
        _OPTION_: {check:{key_down: K_RCONTROL, 
                        key_push: K_SPACE,
                        system: :key_down}}
      _SET_ alpha: 255
    end
    _MOVE_ 30, 
      x:[800,0],
      _OPTION_: { easing: :out_quart,
                check:{ key_down: K_RCONTROL, 
                        key_push: K_SPACE,
                        system: :key_down}}
    _SET_ x: 0
    _STACK_LOOP_ do
      #マウスが領域内に入ったら色を変え、文字をスクロールインさせる
      _CHECK_ mouse: [:cursor_over] do
        _SEND_(:text_area){
          _SET_ bgcolor: [255,0,255]
        }
      end
      #マウスが領域外に出たら色を戻し、文字をスクロールインさせる
      _CHECK_ mouse: [:cursor_out] do
        _SEND_(:text_area){
          _SET_ bgcolor: [0,255,255]
        }
      end
      #マウスがクリックされたらフラグを立てる
      _CHECK_ mouse: [:key_down] do
        pp options
        _SET_ :_TEMP_, flag: options[:id]
        _EVAL_ "pp '[" + options[:text].to_s + "]が押されました'"
      end
      #フラグが立っていればボタンをアウトさせてループを終了する
      _CHECK_ :_TEMP_,  not_equal: {flag: nil} do
        _MOVE_ 60, y:[0,600], _OPTION_:{easing: :in_back}
        _RETURN_
      end
      _END_FRAME_
    end
  end
end

#文字列中にボタンを埋め込む
_DEFINE_ :func_select do |argument, options, control|
  _SEND_ :text0 do
    _SEND_TO_ACTIVE_LINE_ do
      TextSelect id: options[:id], text: argument
      _WAIT_  count: 3, 
              key_down: K_RCONTROL, 
              key_push: K_SPACE,
              system: :key_down
    end
  end
end
