#! ruby -E utf-8

_SEND_ :text0 do
  _DELETE_
end

_DEFINE_ :TextWindow2 do |argument, options|
  _CREATE_ :RenderTargetControl,
    x: options[:x],
    y: options[:y],
    width: options[:width],
    height: options[:height],
    id: options[:id] do
      #デフォルトの背景画像
      _CREATE_ :ImageControl, id: :bg
      ##このコントロールにload_imageを実行すると背景画像をセットできる。
      ##ex.
      ##  _SEND_ :message0 do
      ##    _SEND_ :bg do
      ##      _SET_ file_path: "./sozai/bg_test.jpg" 
      ##    end
      ##  end

      #メッセージウィンドウ
      _CREATE_ :TextPageControl, 
        x: 0,
        y: 0,
        width: options[:width],
        size: 32, 
        font_name: "ＭＳＰ ゴシック",
        wait_frame: 3 do
          _CHAR_RENDERER_ do
            #フェードイン（スペースキーか右CTRLが押されたらスキップ）
            _MOVE_   30, x:[800,0], y:[-600,0],
                  option: {easing: :out_quart, check: {key_down: K_RCONTROL, key_push: K_SPACE}} do
                    _SET_ x: 0, y:0
                  end
            #トランジションが終了するまで待機
            _WAIT_  command: :_MOVE_ 
            #待機フラグを立てる
            _SET_ :_TEMP_, sleep: true
            #待機フラグが下がるまで待機
            _WAIT_ :_TEMP_, equal: {sleep: false}, not_equal: {flag: nil}
            #キー入力伝搬を防ぐ為に１フレ送る
            _END_FRAME_
=begin
            #ハーフフェードアウト（スペースキーか右CTRLが押されたらスキップ）
            _MOVE_  60,  alpha:128,
                  option: {
                  check: {:key_down => K_RCONTROL, :key_push => K_SPACE}} do
                    #スキップされた場合
                    _CHECK_ key_down: K_RCONTROL do
                      #CTRLスキップ中であれば透明度255
                      _SET_ alpha: 255
                    end
                    _CHECK_ key_push: K_SPACE do
                      #CTRLスキップ中でなければ透明度128
                      _SET_ alpha: 128
                    end
            end
            #トランジションが終了するまで待機
            _WAIT_ command: :_MOVE_ 
=end
          end
          _SET_ size: 32
      end
    #文字列出力
    _DEFINE_ :_TEXT_ do |argument, options|
      _SEND_ 1 do
        _TEXT_ argument
      end
    end
    #改行
    _DEFINE_ :_LINE_FEED_ do
      _SEND_ 1  do
        _LINE_FEED_
      end
    end
    #_rubi_デフォルト送信
    _DEFINE_ :_RUBI_ do |argument, options|
      _SEND_ 1 do
        _RUBI_ argument, text: options[:text]
      end
    end
    #_flush_デフォルト送信
    _DEFINE_ :_FLUSH_ do
      _SEND_ 1  do
        _FLUSH_
      end
    end
    #_flush_デフォルト送信
    _DEFINE_ :_SET_FONT_ do |argument, options|
      _SEND_ 1  do
        _SET_ options
      end
    end

    #キー入力待ち処理
    _DEFINE_ :pause do |argument, options|
      _SEND_ 1 do
        _WAIT_ count:17
        if options[:icon] == :line_icon_func
          _SEND_ -1 do
            line_icon_func align_y: :bottom, float_x: :left
          end
        else
          _SEND_ -3 do
            page_icon_func align_y: :bottom, float_x: :left
          end
        end

        #スペースキーあるいはCTRLキーの押下待機
        _WAIT_  key_down: K_RCONTROL,
                key_push: K_SPACE

        #ウェイクに移行
        _SET_ :_TEMP_, sleep: false
      end
    end

    #クリック待ちアイコン表示処理
    _DEFINE_ :put_icon do |argument, options|
      #絶対座標表示
      if options[:absolute]
        _CALL_ argument, x:100, y:100, align_y: :none, float_x: :none
      end
    end
    _YIELD_
  end
end

TextWindow2 id: :text0, text_page_id: :default_text_page_control0,
  x: 32,
  y: 32,
  width: 1024,
  height: 1024,
  z: 1000000 do #描画順序
              _SET_FONT_  font_name: "ＭＳ ゴシック"
  end

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

#テキストボタン定義
_DEFINE_ :TextSelect do |argument, options|
  _CREATE_ :LayoutControl,
      float_x: :left,
    x: options[:x] || 0, y: options[:y] || 0, width: 196, height: 32, id: :Anonymous_CharControl do
    #テキストを描画するRenderTarget
    _CREATE_ :RenderTargetControl,
      float_x: :left,
      width: 196, height: 32, id: :text_area, bgcolor: [255,255,0] do
      _CREATE_ :CharControl, size: 32, color:[255,255,0], font_name: "ＭＳ ゴシック", charactor: options[:text]
      _MOVE_   30, alpha:[0,255],
            option: {check: {key_down: K_RCONTROL, key_push: K_SPACE}} do
              _SET_ alpha: 255
            end
    end
    _MOVE_   30, x:[800,0],
          option: {check: {easing: :out_quart,key_down: K_RCONTROL, key_push: K_SPACE}} do
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
      #マウスがクリックされたら文字列を出力する
      _CHECK_ mouse: [:key_down] do
        pp options
        _SET_ :_TEMP_, flag: options[:id]
        _EVAL_ "pp '[" + options[:text].to_s + "]が押されました'"
        _RETURN_
      end
      _MOUSE_POS_ do |options|
        #pp options
      end
    end
  end
end
