_CREATE_ :Char, 
  id: :comment_area,
  size: 32, 
  y: 256+196,
  color:[255,255,0], 
  font_name: "ＭＳＰ ゴシック",
  char: " "


#テキストボタン定義
_DEFINE_ :TextSelect do |argument, options|
  _CREATE_ :ClickableLayout,
    float_y: :bottom,
    x: options[:x] || 0, 
    y: options[:y] || 0, 
    width: options[:width] || 228, 
    height: 32 do
    #テキストを描画するRenderTarget
    _CREATE_ :RenderTarget,
      float_x: :left,
      width: options[:width] || 228, 
      height: 32, 
      id: :text_area, 
      bgcolor: [0,255,255] do
      _CREATE_ :Char, 
        size: 28, 
        color:[255,255,0], 
        font_name: "ＭＳ ゴシック", 
        char: options[:text]
    end
    _STACK_LOOP_ do
      _CHECK_ mouse: [:cursor_over] do
      #マウスが領域内に入ったら色を変え、
        _SEND_ :text_area do
          _SET_ bgcolor: [255,0,255]
        end
        _SEND_ [:_ROOT_, :comment_area], interrupt: true do
          _SET_ char: options[:comment]
        end
      end
      #マウスが領域外に出たら色を戻す
      _CHECK_ mouse: [:cursor_out] do
        _SEND_ :text_area do
          _SET_ bgcolor: [0,255,255]
        end
      end
      #マウスがクリックされたらフラグを立てる
      _CHECK_ mouse: [:key_push] do
        _SET_ :_TEMP_, path: options[:path]
        _EVAL_ "pp '[" + options[:text].to_s + "]が押されました'"
        _RETURN_
      end
      _END_FRAME_
    end
  end
end

_DEFINE_ :system_menu do
  _CREATE_ :Layout, id: :top_menu1, x:0, y:0 do
    path = "./script/sample/"
    _CREATE_ :Layout, id: 0, x:0, y:0, width: 256, float_x: :left  do
      TextSelect text: "sample_1_1.tks", path: path + "sample_1_1.tks", 
                 comment: "文字列の表示"
      TextSelect text: "sample_1_2.tks", path: path + "sample_1_2.tks", 
                 comment: "文字列の表示：応用"
      TextSelect text: "sample_1_3.rb", path: path + "sample_1_3.rb", 
                 comment: "画像の表示"
      TextSelect text: "sample_1_4.rb", path: path + "sample_1_4.rb", 
                 comment: "画像の直線移動"
      TextSelect text: "sample_1_5.rb", path: path + "sample_1_5.rb", 
                 comment: "画像のスプライン移動"
      TextSelect text: "sample_1_6.rb", path: path + "sample_1_6.rb", 
                 comment: "フェードイン・アウト"
      TextSelect text: "sample_1_7.rb", path: path + "sample_1_7.rb", 
                 comment: "より自然なフェードイン・アウト"
      TextSelect text: "sample_1_8.rb", path: path + "sample_1_8.rb", 
                 comment: "フェードトランジション"
      TextSelect text: "sample_1_9.rb", path: path + "sample_1_9.rb", 
                 comment: "より自然なフェードトランジション"
    end
    _CREATE_ :Layout, id: 1, x:0, y:0, width: 256, float_x: :left   do
      TextSelect text: "sample_1_10.rb", path: path + "sample_1_10.rb", 
                 comment: "ルールトランジション"
      TextSelect text: "sample_1_11.rb", path: path + "sample_1_11.rb", 
                 comment: "ユーザー定義コマンドを使う"
      TextSelect text: "sample_1_12.tks", path: path + "sample_1_12.tks", 
                 comment: "データストアとインラインデータ記法"
      TextSelect text: "sample_1_13.tks", path: path + "sample_1_13.tks", 
                 comment: "条件判定"
      TextSelect text: "sample_1_14.rb", path: path + "sample_1_14.rb", 
                 comment: "繰り返し構文"
      TextSelect text: "sample_1_15.rb", path: path + "sample_1_15.rb", 
                 comment: "ボタンの表示"
      TextSelect text: "sample_1_16.tks", path: path + "sample_1_16.tks", 
                 comment: "サウンド"
      TextSelect text: "sample_1_17.tks", path: path + "sample_1_17.tks", 
                 comment: "セーブ／ロード"
    end
    _CREATE_ :Layout, id: 2, x:0, y:0, width: 256, float_x: :left    do
      TextSelect text: "sample_2_1_1.rb", path: path + "sample_2_1_1.rb", 
                 comment: "ボタンサンプル１：通常"
      TextSelect text: "sample_2_1_2.rb", path: path + "sample_2_1_2.rb", 
                 comment: "ボタンサンプル２：多角形コリジョン"
      TextSelect text: "sample_2_1_3.rb", path: path + "sample_2_1_3.rb", 
                 comment: "ボタンサンプル３：抜き色"
      TextSelect text: "sample_2_2.rb",   path: path + "sample_2_2.rb", 
                 comment: "アニメーションサンプル"
      TextSelect text: "sample_2_3.rb",   path: path + "sample_2_3.rb", 
                 comment: "コマンドメニュー/右クリックサンプル"
      TextSelect text: "sample_2_4.rb",   path: path + "sample_2_4.rb", 
                 comment: "ドラッグ操作サンプル"
      TextSelect text: "sample_2_5.rb",   path: path + "sample_2_5.rb", 
                 comment: "_TO_IMAGE_とルールトランジションの組み合わせ"
      TextSelect text: "sample_2_6.rb",   path: path + "sample_2_6.rb", 
                 comment: "センタリングとＸ方向連結のサンプル"
    end
    _CREATE_ :Layout, id: 3, x:0, y:0, width: 256, float_x: :left    do
      TextSelect text: "sample_3_1.rb", path: path + "sample_3_1.tks", 
                 comment: "既読フラグサンプル"
      TextSelect text: "sample_3_2_1.rb", path: path + "sample_3_2_1.rb", 
                 comment: "シリアライズサンプル：セーブ"
      TextSelect text: "sample_3_2_2.rb", path: path + "sample_3_2_2.rb", 
                 comment: "シリアライズサンプル：ロード"
      TextSelect text: "sample_3_3.rb", path: path + "sample_3_3.rb", 
                 comment: "システムステータスの取得"
      TextSelect text: "sample_3_4.rb", path: path + "sample_3_4.rb", 
                 comment: "フルスクリーン化"
      TextSelect text: "sample_3_5.rb", path: path + "sample_3_5.rb", 
                 comment: "マウス画像のカスタマイズ"
      TextSelect text: "sample_3_6.rb", path: path + "sample_3_6.rb", 
                 comment: "疑似if文（コンソールに結果を出力）"
    end
  end

  _CREATE_ :Layout, id: :top_menu2, x:0, y:256 + 64 do
    TextSelect  text: "デモゲーム：ノベル脱出ゲーム", 
                path: "./script/demo_game/1_0.tks", 
                width: 512, 
                comment: "ノベルゲーム形式のサンプルデモです。"
  end

  _CREATE_ :Layout, id: :top_menu3, x:0, y:256 + 128  do
    TextSelect  text: "デモゲーム：野メイド", 
                path: "./script/nomaid/src.rb", 
                width: 512, 
                comment: "育成ＳＬＧ形式のサンプルデモです。"
  end
end

_SEND_ :base do
  _DELETE_
end
_SEND_ :img0 do
  _DELETE_
end
_SEND_ :img1 do
  _DELETE_
end

_STACK_LOOP_ do |a,b,c|

 _CREATE_ :Image,
   z: 0,
   id: :base do
 end
 _CREATE_ :Image,
   z: 1000,
   id: :img0 do
 end
 _CREATE_ :Image,
   z: 2000,
   id: :img1 do
 end

  _SET_ :_TEMP_, path: nil

  system_menu

  _WAIT_ :_TEMP_,  not_equal: {path: nil}
  _GET_ :path, datastore: :_TEMP_ do |arg, options|
    _PUTS_ options[:path]
  end
  _SEND_ :top_menu1 do
    _DELETE_
  end
  _SEND_ :top_menu2 do
    _DELETE_
  end
  _SEND_ :top_menu3 do
    _DELETE_
  end
  _SEND_ :comment_area do
    _SET_ char: ""
  end

  _END_FRAME_

  _INCLUDE_ :path, force: true

	_SEND_ :base do
	  _DELETE_
	end
	_SEND_ :img0 do
	  _DELETE_
	end
	_SEND_ :img1 do
	  _DELETE_
	end

end