#! ruby -E utf-8

#テキストウィンドウを再作成する
text0 do
  _SET_ x: 32,
  y: 32,
  width: 1024,
  height: 1024,
  z: 1000000
  _SET_FONT_  font_name: "ＭＳ ゴシック"
  _SEND_ 1  do
    _CHAR_RENDERER_ do |argument, options,control|
      #フェードイン（スペースキーか右CTRLが押されたらスキップ）
      _MOVE_   30, 
        x:[800,0], 
        y:[-600,0],
        option: {easing: :out_quart, 
        check: {key_down: K_RCONTROL, key_push: K_SPACE}} do
        _SET_ x: 0, y:0
      end
      #トランジションが終了するまで待機
      _WAIT_  command: :_MOVE_ 
      #待機フラグが下がるまで待機
      _WAIT_ :_TEMP_, not_equal: {flag: nil}
      #文字列をカスケードアウトさせる
      _MOVE_ 30 + control.id * 3, y:[0,600], option:{easing: :in_back}
    end
  end
end

#テキストボタン定義
_DEFINE_ :TextSelect do |argument, options|
  _CREATE_ :LayoutControl,
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
        option: {check: {key_down: K_RCONTROL, key_push: K_SPACE}} do
          _SET_ alpha: 255
      end
    end
    _MOVE_ 30, 
      x:[800,0],
      option: { check: {easing: :out_quart, 
                key_down: K_RCONTROL, 
                key_push: K_SPACE}} do
      _SET_ x: 0
    end
    #トランジションが終了するまで待機
    _WAIT_  command: :_MOVE_ 
    _LOOP_ do
      _CHECK_ mouse: [:cursor_over] do
      #マウスが領域内に入ったら色を変え、文字をスクロールインさせる
        text_area{
          _SET_ bgcolor: [255,0,255]
        }
      end
      #マウスが領域外に出たら色を戻し、文字をスクロールインさせる
      _CHECK_ mouse: [:cursor_out] do
        text_area{
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
        _MOVE_ 60, y:[0,600], option:{easing: :in_back}
        _RETURN_
      end
    end
  end
end

#文字列中にボタンを埋め込む
_DEFINE_ :func_select do |argument, options, control|
  _SEND_ default: :TextLayer do
    _SEND_ 1 do
      _SEND_ -1 do
        TextSelect id: options[:id], text: argument
        _WAIT_ count: 3, key_down: K_RCONTROL, key_push: K_SPACE
      end
    end
  end
end
