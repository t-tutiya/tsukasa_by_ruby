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
    _NEXT_LOOP_ do
      _CHECK_ mouse: [:cursor_over] do
      #マウスが領域内に入ったら色を変え、
        text_area{
          _SET_ bgcolor: [255,0,255]
        }
      end
      #マウスが領域外に出たら色を戻す
      _CHECK_ mouse: [:cursor_out] do
        text_area{
          _SET_ bgcolor: [0,255,255]
        }
      end
      #マウスがクリックされたらフラグを立てる
      _CHECK_ mouse: [:key_down] do
        _SET_ :_TEMP_, file_path: options[:path]
        #_EVAL_ "pp '[" + options[:text].to_s + "]が押されました'"
        _RETURN_
      end
    end
  end
end

_DEFINE_ :system_menu do
  _CREATE_ :LayoutControl, id: :top_menu, x:0, y:0 do
    _CREATE_ :LayoutControl, id: 0, x:0, y:0, width: 256, float_x: :left  do
      TextSelect text: "sample_1_1", path: "./script/sample/sample_1_1.tks"
      TextSelect text: "sample_1_2", path: "./script/sample/sample_1_2.tks"
      TextSelect text: "sample_1_3", path: "./script/sample/sample_1_3.tks"
      TextSelect text: "sample_1_4", path: "./script/sample/sample_1_4.tks"
      TextSelect text: "sample_1_5", path: "./script/sample/sample_1_5.tks"
      TextSelect text: "sample_1_6", path: "./script/sample/sample_1_6.tks"
      TextSelect text: "sample_1_7", path: "./script/sample/sample_1_7.tks"
      TextSelect text: "sample_1_8", path: "./script/sample/sample_1_8.tks"
      TextSelect text: "sample_1_9", path: "./script/sample/sample_1_9.tks"
    end
    _CREATE_ :LayoutControl, id: 1, x:0, y:0, width: 256, float_x: :left   do
      TextSelect text: "sample_1_10", path: "./script/sample/sample_1_10.tks"
      TextSelect text: "sample_1_11", path: "./script/sample/sample_1_11.tks"
      TextSelect text: "sample_1_12", path: "./script/sample/sample_1_12.tks"
      TextSelect text: "sample_1_13", path: "./script/sample/sample_1_13.tks"
      TextSelect text: "sample_1_14", path: "./script/sample/sample_1_14.tks"
      TextSelect text: "sample_1_15", path: "./script/sample/sample_1_15.tks"
      TextSelect text: "sample_1_16", path: "./script/sample/sample_1_16.tks"
      TextSelect text: "sample_1_17", path: "./script/sample/sample_1_17.tks"
    end
    _CREATE_ :LayoutControl, id: 2 do
      TextSelect text: "sample_2_1_1", path: "./script/sample/sample_2_1_1.rb"
      TextSelect text: "sample_2_1_2", path: "./script/sample/sample_2_1_2.rb"
      TextSelect text: "sample_2_1_3", path: "./script/sample/sample_2_1_3.rb"
      TextSelect text: "sample_2_2",   path: "./script/sample/sample_2_2.tks"
      TextSelect text: "sample_2_3_1", path: "./script/sample/sample_2_3_1.rb"
      TextSelect text: "sample_2_3_2", path: "./script/sample/sample_2_3_2.rb"
    end
  end

  _CREATE_ :LayoutControl, id: :top_menu, x:0, y:256 + 64 do
    TextSelect  text: "デモゲーム：ノベルゲーム", 
                path: "./script/demo_game/1_0.tks", 
                width: 512
  end

  _CREATE_ :LayoutControl, id: :top_menu, x:0, y:256 + 128  do
    TextSelect  text: "デモゲーム：野メイド", 
                path: "./script/nomaid/src.rb", 
                width: 512
  end
end

_NEXT_LOOP_ do

 _CREATE_ :ImageControl,
   z: 0,
   id: :base do
 end
 _CREATE_ :ImageControl,
   z: 100,
   id: :img0 do
 end
 _CREATE_ :ImageControl,
   z: 2000,
   id: :img1 do
 end

  _SET_ :_TEMP_, file_path: nil

  system_menu

  _WAIT_ :_TEMP_,  not_equal: {file_path: nil}
  _SEND_ :top_menu do
    _DELETE_
  end

  _END_FRAME_

  _INCLUDE_ :file_path

	base{_DELETE_}
	img0{_DELETE_}
	img1{_DELETE_}

end