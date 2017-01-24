_CREATE_ :Char, 
  id: :comment_area,
  size: 32, 
  y: 256+196 + 64,
  color:[255,255,0], 
  font_name: "ＭＳＰ ゴシック",
  char: " "


#テキストボタン定義
_DEFINE_ :TextSelect do |options|
  _CREATE_ :ClickableLayout,
    shape: [0, 0, options[:width] || 228, 32],
    x: options[:x] || 0, 
    y: options[:y] || 0, 
    width: options[:width] || 228, 
    height: 32 do
    #テキストを描画するDrawableLayout
    _CREATE_ :DrawableLayout,
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
    _DEFINE_ :inner_loop do
      _CHECK_ collision: :cursor_over do
      #マウスが領域内に入ったら色を変え、
        _SEND_ :text_area do
          _SET_ bgcolor: [255,0,255]
        end
        _SEND_ [:_ROOT_, :comment_area], interrupt: true do
          _SET_ char: options[:comment]
        end
      end
      #マウスが領域外に出たら色を戻す
      _CHECK_ collision: :cursor_out do
        _SEND_ :text_area do
          _SET_ bgcolor: [0,255,255]
        end
      end
      #マウスがクリックされたらフラグを立てる
      _CHECK_ collision: :key_push do
        _SET_ [:_ROOT_, :_TEMP_], path: options[:path]
        _EVAL_ "puts '[" + options[:text].to_s + "]が押されました'"
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

_DEFINE_ :system_menu do
  _CREATE_ :Layout, id: :top_menu1, x:0, y:0, height: 256 + 64 do
    path = "./script/sample/sample/"
    _CREATE_ :Layout, id: 0, x:0, y:0, width: 256 do
      TextSelect text: "sample_1_1.rb", path: path + "sample_1_1.rb", 
                 comment: "画像の表示", y: 32 * 0
      TextSelect text: "sample_1_2.rb", path: path + "sample_1_2.rb", 
                 comment: "画像の直線移動", y: 32 *1
      TextSelect text: "sample_1_3.rb", path: path + "sample_1_3.rb", 
                 comment: "画像のスプライン移動", y: 32 * 2
      TextSelect text: "sample_1_4.rb", path: path + "sample_1_4.rb", 
                 comment: "フェードイン・アウト", y:32 * 3
      TextSelect text: "sample_1_5.rb", path: path + "sample_1_5.rb", 
                 comment: "より自然なフェードイン・アウト", y:32 * 4
      TextSelect text: "sample_1_6.rb", path: path + "sample_1_6.rb", 
                 comment: "フェードトランジション", y:32 * 5
      TextSelect text: "sample_1_7.rb", path: path + "sample_1_7.rb", 
                 comment: "より自然なフェードトランジション", y:32 * 6
      TextSelect text: "sample_1_8.rb", path: path + "sample_1_8.rb", 
                 comment: "ルールトランジション", y:32 * 7
      TextSelect text: "sample_1_9.rb", path: path + "sample_1_9.rb", 
                 comment: "ユーザー定義コマンドを使う", y:32 * 8
    end
    _CREATE_ :Layout, id: 1, x:256, y:0, width: 256 do
      TextSelect text: "sample_1_10.rb", path: path + "sample_1_10.rb", 
                 comment: "データストアとインラインデータ記法", y: 32 * 0
      TextSelect text: "sample_1_11.rb", path: path + "sample_1_11.rb", 
                 comment: "条件判定", y: 32 * 1
      TextSelect text: "sample_1_12.rb", path: path + "sample_1_12.rb", 
                 comment: "繰り返し構文", y: 32 * 2
      TextSelect text: "sample_1_13.rb", path: path + "sample_1_13.rb", 
                 comment: "ボタンの表示", y: 32 * 3
      TextSelect text: "sample_1_14.rb", path: path + "sample_1_14.rb", 
                 comment: "サウンド", y: 32 * 4
      TextSelect text: "sample_1_15.rb", path: path + "sample_1_15.rb", 
                 comment: "セーブ／ロード", y: 32 * 5
      TextSelect text: "sample_1_16.tks", path: path + "sample_1_16.tks", 
                 comment: "【tks】文字列の表示", y: 32 * 6
      TextSelect text: "sample_1_17.tks", path: path + "sample_1_17.tks", 
                 comment: "【tks】文字列の表示：応用", y: 32 * 7
    end
    _CREATE_ :Layout, id: 2, x:256*2, y:0, width: 256 do
      TextSelect text: "sample_2_1_1.rb", path: path + "sample_2_1_1.rb", 
                 comment: "ボタンサンプル１：通常", y: 32 * 0
      TextSelect text: "sample_2_1_2.rb", path: path + "sample_2_1_2.rb", 
                 comment: "ボタンサンプル２：多角形コリジョン", y: 32 * 1
      TextSelect text: "sample_2_1_3.rb", path: path + "sample_2_1_3.rb", 
                 comment: "ボタンサンプル３：抜き色", y: 32 * 2
      TextSelect text: "sample_2_2.rb",   path: path + "sample_2_2.rb", 
                 comment: "アニメーションサンプル", y: 32 * 3
      TextSelect text: "sample_2_3.rb",   path: path + "sample_2_3.rb", 
                 comment: "コマンドメニュー/右クリックサンプル", y: 32 * 4
      TextSelect text: "sample_2_4.rb",   path: path + "sample_2_4.rb", 
                 comment: "ドラッグ操作サンプル", y: 32 * 5
      TextSelect text: "sample_2_5.rb",   path: path + "sample_2_5.rb", 
                 comment: "_TO_IMAGE_とルールトランジションの組み合わせ", y: 32 * 6
      TextSelect text: "sample_2_6.rb",   path: path + "sample_2_6.rb", 
                 comment: "カスタムシェーダーサンプル", y: 32 * 7
    end
    _CREATE_ :Layout, id: 3, x:256*3, y:0, width: 256 do
      TextSelect text: "sample_3_1.tks", path: path + "sample_3_1.tks", 
                 comment: "既読フラグサンプル", y: 32 * 0
      TextSelect text: "sample_3_2_1.rb", path: path + "sample_3_2_1.rb", 
                 comment: "シリアライズサンプル：セーブ", y: 32 * 1
      TextSelect text: "sample_3_2_2.rb", path: path + "sample_3_2_2.rb", 
                 comment: "シリアライズサンプル：ロード", y: 32 * 2
      TextSelect text: "sample_3_3.rb", path: path + "sample_3_3.rb", 
                 comment: "システムステータスの取得", y: 32 * 3
      TextSelect text: "sample_3_4.rb", path: path + "sample_3_4.rb", 
                 comment: "フルスクリーン化", y: 32 * 4
      TextSelect text: "sample_3_5.rb", path: path + "sample_3_5.rb", 
                 comment: "マウス画像のカスタマイズ", y: 32 * 5
      TextSelect text: "sample_3_6.rb", path: path + "sample_3_6.rb", 
                 comment: "疑似if文（コンソールに結果を出力）", y: 32 * 6
      TextSelect text: "sample_3_7.tks", path: path + "sample_3_7.tks", 
                 comment: "シーン管理サンプル", y: 32 * 7
    end
  end

  _CREATE_ :Layout, id: :top_menu_b, width: 512, height: 256 + 64, x: 0, y: 256 + 64 do
    _CREATE_ :Layout, id: :top_menu2, x:0, height: 64, y: 64 * 0 do
      TextSelect  text: "デモゲーム：ノベル脱出ゲーム", 
                  path: "./script/sample/demo_game/1_0.tks", 
                  width: 512, 
                  comment: "ノベルゲーム形式のサンプルデモです。"
    end

    _CREATE_ :Layout, id: :top_menu3, x:0, height: 64, y: 64 * 1 do
      TextSelect  text: "デモゲーム：野メイド", 
                  path: "./script/sample/nomaid/src.rb", 
                  width: 512, 
                  comment: "育成ＳＬＧ形式のサンプルデモです。"
    end

    _CREATE_ :Layout, id: :top_menu4, x:0, height: 64, y: 64 * 2 do
      TextSelect  text: "デモゲーム：ジャンプアクションデモ", 
                  path: "./script/sample/jump_action/game.rb", 
                  width: 512, 
                  comment: "２Ｄのスクロール式ジャンプアクションゲームのデモです。"
    end
  end

  _CREATE_ :Layout, id: :top_menu_b2, width: 512, height: 256 + 64, x:512, y: 256 + 64  do
    _CREATE_ :Layout, id: :top_menu5, x:0, height: 64, y: 64 * 0 do
      TextSelect  text: "デモゲーム：ブロック崩し", 
                  path: "./script/sample/block/block.rb", 
                  width: 512, 
                  comment: "アクションゲームのサンプルです"
    end
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

_DEFINE_ :inner_loop do

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

  _SET_ [:_ROOT_, :_TEMP_], path: nil

  system_menu

  _WAIT_ [:_ROOT_, :_TEMP_],  not_equal: {path: nil}
  _GET_ :path, control: [:_ROOT_, :_TEMP_] do |options|
    _PUTS_ options[:path]
  end
  _SEND_ :top_menu1 do
    _DELETE_
  end
  _SEND_ :top_menu_b do
    _DELETE_
  end
  _SEND_ :top_menu_b2 do
    _DELETE_
  end
  _SEND_ :comment_area do
    _SET_ char: ""
  end

  _END_FRAME_

  _GET_ :path, control: [:_ROOT_, :_TEMP_] do |path:|
    _INCLUDE_ path, force: true
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

  _RETURN_ do
    inner_loop
  end
end

inner_loop
