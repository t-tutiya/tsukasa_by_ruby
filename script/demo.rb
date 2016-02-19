_CREATE_ :CharControl, 
  id: :comment_area,
  size: 32, 
  y: 256+196,
  color:[255,255,0], 
  font_name: "ＭＳ ゴシック",
  charactor: " "


#テキストボタン定義
_DEFINE_ :TextSelect do |argument, options|
  _CREATE_ :LayoutControl,
    float_y: :bottom,
    x: options[:x] || 0, 
    y: options[:y] || 0, 
    width: options[:width] || 228, 
    height: 32, 
    id: :Anonymous_CharControl do
    #テキストを描画するRenderTarget
    _CREATE_ :RenderTargetControl,
      float_x: :left,
      width: options[:width] || 228, 
      height: 32, 
      id: :text_area, 
      bgcolor: [0,255,255] do
      _CREATE_ :CharControl, 
        size: 32, 
        color:[255,255,0], 
        font_name: "ＭＳ ゴシック", 
        charactor: options[:text]
    end
    _STACK_LOOP_ do
      _CHECK_ mouse: [:cursor_over] do
      #マウスが領域内に入ったら色を変え、
        _SEND_ :text_area do
          _SET_ bgcolor: [255,0,255]
        end
        _SEND_ROOT_ do
          _SEND_ :comment_area do
            _SET_ charactor: options[:comment]
          end
        end
      end
      #マウスが領域外に出たら色を戻す
      _CHECK_ mouse: [:cursor_out] do
        _SEND_ :text_area do
          _SET_ bgcolor: [0,255,255]
        end
      end
      #マウスがクリックされたらフラグを立てる
      _CHECK_ mouse: [:key_down] do
        _SET_ :_TEMP_, file_path: options[:path]
        _EVAL_ "pp '[" + options[:text].to_s + "]が押されました'"
        _RETURN_
      end
      _END_FRAME_
    end
  end
end

_DEFINE_ :system_menu do
  _CREATE_ :LayoutControl, id: :top_menu1, x:0, y:0 do
    path = "./script/sample/"
    _CREATE_ :LayoutControl, id: 0, x:0, y:0, width: 256, float_x: :left  do
      TextSelect text: "sample_1_1", path: path + "sample_1_1.tks", 
                 comment: "文字列の表示"
      TextSelect text: "sample_1_2", path: path + "sample_1_2.tks", 
                 comment: "文字列の表示：応用"
      TextSelect text: "sample_1_3", path: path + "sample_1_3.tks", 
                 comment: "画像の表示"
      TextSelect text: "sample_1_4", path: path + "sample_1_4.tks", 
                 comment: "画像の直線移動"
      TextSelect text: "sample_1_5", path: path + "sample_1_5.tks", 
                 comment: "画像のスプライン移動"
      TextSelect text: "sample_1_6", path: path + "sample_1_6.tks", 
                 comment: "フェードイン・アウト"
      TextSelect text: "sample_1_7", path: path + "sample_1_7.tks", 
                 comment: "より自然なフェードイン・アウト"
      TextSelect text: "sample_1_8", path: path + "sample_1_8.tks", 
                 comment: "フェードトランジション"
      TextSelect text: "sample_1_9", path: path + "sample_1_9.tks", 
                 comment: "より自然なフェードトランジション"
    end
    _CREATE_ :LayoutControl, id: 1, x:0, y:0, width: 256, float_x: :left   do
      TextSelect text: "sample_1_10", path: path + "sample_1_10.tks", 
                 comment: "ルールトランジション"
      TextSelect text: "sample_1_11", path: path + "sample_1_11.tks", 
                 comment: "ユーザー定義コマンドを使う"
      TextSelect text: "sample_1_12", path: path + "sample_1_12.tks", 
                 comment: "データストアとインラインデータ記法"
      TextSelect text: "sample_1_13", path: path + "sample_1_13.tks", 
                 comment: "条件判定"
      TextSelect text: "sample_1_14", path: path + "sample_1_14.tks", 
                 comment: "繰り返し構文"
      TextSelect text: "sample_1_15", path: path + "sample_1_15.tks", 
                 comment: "ボタンの表示"
      TextSelect text: "sample_1_16", path: path + "sample_1_16.tks", 
                 comment: "サウンド"
      TextSelect text: "sample_1_17", path: path + "sample_1_17.tks", 
                 comment: "セーブ／ロード"
    end
    _CREATE_ :LayoutControl, id: 2 do
      TextSelect text: "sample_2_1_1", path: path + "sample_2_1_1.rb", 
                 comment: "ボタンサンプル１：通常"
      TextSelect text: "sample_2_1_2", path: path + "sample_2_1_2.rb", 
                 comment: "ボタンサンプル２：多角形コリジョン"
      TextSelect text: "sample_2_1_3", path: path + "sample_2_1_3.rb", 
                 comment: "ボタンサンプル３：抜き色"
      TextSelect text: "sample_2_2",   path: path + "sample_2_2.rb", 
                 comment: "アニメーションサンプル"
      TextSelect text: "sample_3_1", path: path + "sample_3_1.tks", 
                 comment: "既読フラグサンプル"
      TextSelect text: "sample_3_2_1", path: path + "sample_3_2_1.rb", 
                 comment: "シリアライズサンプル：セーブ"
      TextSelect text: "sample_3_2_2", path: path + "sample_3_2_2.rb", 
                 comment: "シリアライズサンプル：ロード"
    end
  end

  _CREATE_ :LayoutControl, id: :top_menu2, x:0, y:256 + 64 do
    TextSelect  text: "デモゲーム：ノベル脱出ゲーム", 
                path: "./script/demo_game/1_0.tks", 
                width: 512, 
                comment: "ノベルゲーム形式のサンプルデモです。"
  end

  _CREATE_ :LayoutControl, id: :top_menu3, x:0, y:256 + 128  do
    TextSelect  text: "デモゲーム：野メイド", 
                path: "./script/nomaid/src.rb", 
                width: 512, 
                comment: "育成ＳＬＧ形式のサンプルデモです。"
  end
end

_STACK_LOOP_ do |a,b,c|

 _CREATE_ :ImageControl,
   z: 0,
   id: :base do
 end
 _CREATE_ :ImageControl,
   z: 1000,
   id: :img0 do
 end
 _CREATE_ :ImageControl,
   z: 2000,
   id: :img1 do
 end

  _SET_ :_TEMP_, file_path: nil

  system_menu

  _WAIT_ :_TEMP_,  not_equal: {file_path: nil}
  _EVAL_ "pp _TEMP_[:file_path]"
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
    _SET_ charactor: ""
  end

  _END_FRAME_

  _INCLUDE_ :file_path

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