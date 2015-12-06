#! ruby -E utf-8

TextWindow id: :text0, text_page_id: :default_text_page_control0,
  x: 32,
  y: 32,
  width: 1024,
  height: 1024,
  z: 1000000 do #描画順序
              _SET_FONT_  font_name: "ＭＳ ゴシック"
  end

_DEFINE_ :func_select do |options|
  _SEND_ default: :TextLayer do
    _SEND_ 1 do
      _SEND_ :last do
        TextSelect id: options[:id], text: options[:_ARGUMENT_]
        _WAIT_ count: 3, key_down: K_RCONTROL, key_push: K_SPACE
      end
    end
  end
end

#テキストボタン定義
_DEFINE_ :TextSelect do |options|
  _CREATE_ :LayoutControl,
      float_mode: :left,
    x: 0, y: 0, width: 196, height: 32, id: options[:id] do
    #テキストを描画するRenderTarget
    _CREATE_ :RenderTargetControl,
      float_mode: :left,
      width: 196, height: 32, id: :text_area, bgcolor: [255,255,0] do
      _CREATE_ :CharControl, size: 32, color:[255,255,0], font_name: "ＭＳ ゴシック", charactor: options[:text]
      _MOVE_   30, alpha:[0,255],
            option: {check: {key_down: K_RCONTROL, key_push: K_SPACE}} do
              _SET_ alpha: 255
            end
    end

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
        _EVAL_ "pp '[" + options[:text] + "]が押されました'"
        _RETURN_
      end
    end
  end
end
