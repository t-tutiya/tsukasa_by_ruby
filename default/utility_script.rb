#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver1.2(2016/3/1)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2016> <tsukasa TSUCHIYA>
#
#This software is provided 'as-is', without any express or implied
#warranty. In no event will the authors be held liable for any damages
#arising from the use of this software.
#
#Permission is granted to anyone to use this software for any purpose,
#including commercial applications, and to alter it and redistribute it
#freely, subject to the following restrictions:
#
#   1. The origin of this software must not be misrepresented; you must not
#   claim that you wrote the original software. If you use this software
#   in a product, an acknowledgment in the product documentation would be
#   appreciated but is not required.
#
#   2. Altered source versions must be plainly marked as such, and must not be
#   misrepresented as being the original software.
#
#   3. This notice may not be removed or altered from any source
#   distribution.
#
#[The zlib/libpng License http://opensource.org/licenses/Zlib]
###############################################################################


###############################################################################
#テキストレイヤ関連
###############################################################################

#標準ポーズコマンド
_DEFINE_ :pause do
  #スリープフラグを立てる
  _SET_ :_TEMP_, _SLEEP_: true
  #スリープフラグが下りるまで待機
  _WAIT_ :_TEMP_, 
          key_down: K_RCONTROL, 
          equal: {_SLEEP_: false}
end

_INCLUDE_ "./resource/icon/icon_8_a.rb"

#行クリック待ちポーズ
_DEFINE_ :line_pause do
  #テキストレイヤのクリック待ち
  _GET_ :_DEFAULT_TEXT_PAGE_, datastore: :_TEMP_ do |_DEFAULT_TEXT_PAGE_:|
    _SEND_ _DEFAULT_TEXT_PAGE_ do
      _PAUSE_ do
        _CREATE_ :RenderTargetControl, id: :icon, 
          width: 24, height: 24, align_y: :bottom, float_x: :left, z: 100000 do
          _CREATE_ :TileMapControl, 
            map_array: [[0]], size_x: 1, size_y: 1 do
              _ADD_TILE_GROUP_ file_path: "./resource/icon/icon_8_a.png",
                x_count: 4, y_count: 2
            _ICON_8_
          end
        end
      end
    end
  end

  #ルートのクリック待ち
  pause 

  #クリック待ちアイコンを削除
  _CHECK_ :_TEMP_, not_equal: {_SKIP_: true} do
    _GET_ :_DEFAULT_TEXT_PAGE_, datastore: :_TEMP_ do |_DEFAULT_TEXT_PAGE_:|
      _SEND_ _DEFAULT_TEXT_PAGE_ do
        _SEND_TO_ACTIVE_LINE_ do 
          _SEND_ :icon do
            _DELETE_
          end
        end
      end
    end
  end
end

#行クリック待ちポーズ(line_pauseの省略板)
_DEFINE_ :lp do
  line_pause
end

_DEFINE_ :end_pause do
  #テキストレイヤのクリック待ち
  _GET_ :_DEFAULT_TEXT_PAGE_, datastore: :_TEMP_ do |_DEFAULT_TEXT_PAGE_:|
    _SEND_ _DEFAULT_TEXT_PAGE_ do
      _PAUSE_ do
        _CREATE_ :RenderTargetControl, id: :icon, 
          width: 24, height: 24, align_y: :bottom, float_x: :left, z: 100000 do
          _CREATE_ :TileMapControl, 
            map_array: [[0]], size_x: 1, size_y: 1 do
            _ADD_TILE_GROUP_ file_path: "./resource/icon/icon_4_a.png",
              x_count: 4, y_count: 1
            _STACK_LOOP_ do
              _MAP_STATUS_ 0, x:0, y:0
              _WAIT_ count: 5
              _MAP_STATUS_ 1, x:0, y:0
              _WAIT_ count: 5
              _MAP_STATUS_ 2, x:0, y:0
              _WAIT_ count: 5
              _MAP_STATUS_ 3, x:0, y:0
              _WAIT_ count: 5
            end
          end
        end
      end
    end
  end
  #ルートのクリック待ち
  pause 

  #クリック待ちアイコンを削除
  _CHECK_ :_TEMP_, not_equal: {_SKIP_: true} do
    _GET_ :_DEFAULT_TEXT_PAGE_, datastore: :_TEMP_ do |_DEFAULT_TEXT_PAGE_:|
      _SEND_ _DEFAULT_TEXT_PAGE_ do
        _SEND_TO_ACTIVE_LINE_ do 
          _SEND_ :icon do
            _DELETE_
          end
        end
      end
    end
  end
end

_DEFINE_ :ep do
  end_pause
end

###############################################################################
#デフォルトのレイヤ群
###############################################################################

#標準テキストウィンドウ
_DEFINE_ :TextWindow do |argument, options|
  #メッセージウィンドウ
  _CREATE_ :TextPageControl, 
    x: options[:x] || 0,
    y: options[:y] || 0,
    width: options[:width],
    height: options[:height],
    size: 32, 
    id: argument,
    font_name: "ＭＳＰ ゴシック" do
      #文字間ウェイト
      _DEFINE_ :_CHAR_WAIT_ do
        _WAIT_  :_TEMP_, count: 2,
                key_down: K_RCONTROL,
                key_push: K_SPACE,
                system: [:key_down],
                equal: {_SKIP_: true}
      end
      #行間ウェイト
      _DEFINE_ :_LINE_WAIT_ do
        _WAIT_  :_TEMP_, count: 2,
                key_down: K_RCONTROL,
                key_push: K_SPACE,
                system: [:key_down],
                equal: {_SKIP_: true}
      end
      #文字レンダラ
      _DEFINE_ :_CHAR_RENDERER_ do
        #フェードイン（スペースキーか右CTRLが押されたらスキップ）
        _MOVE_   30, alpha:[0,255],
              _OPTION_: {check: { key_down: K_RCONTROL, 
                                key_push: K_SPACE,
                                system: [:key_down],
                                equal: {_SKIP_: true}},
                       datastore: :_TEMP_}
        _SET_ alpha: 255
        #待機フラグが下がるまで待機
        _WAIT_ :_TEMP_, equal: {_SLEEP_: false}
        #キー入力伝搬を防ぐ為に１フレ送る
        _END_FRAME_
        #ハーフフェードアウト（スペースキーか右CTRLが押されたらスキップ）
        _MOVE_  60,  alpha:128,
              _OPTION_: {
              check: {key_down: K_RCONTROL, 
                      key_push: K_SPACE,
                      system: [:key_down]
                      }}
        #スキップされた場合
        _CHECK_ :_TEMP_, key_down: K_RCONTROL,
                equal: {_SKIP_: true} do
          #CTRLスキップ中であれば透明度255
          _SET_ alpha: 255
        end
        _CHECK_ key_push: K_SPACE,
                system: [:key_down] do
          #CTRLスキップ中でなければ透明度128
          _SET_ alpha: 128
        end
      end

      #文字間ウェイトの更新
      _DEFINE_ :_WAIT_FRAME_ do |argument|
        _DEFINE_ :_CHAR_WAIT_ do
          _WAIT_  count: argument,
                  key_down: K_RCONTROL,
                  key_push: K_SPACE,
                  system: [:key_down]
        end
      end
      
      #アクティブ行への送信
      _DEFINE_ :_SEND_TO_ACTIVE_LINE_ do
        _SEND_ -1 do
          _YIELD_
        end
      end

      #キー入力待ち処理
      _DEFINE_ :_PAUSE_ do 
        _WAIT_  :_TEMP_, count:32,
                key_down: K_RCONTROL,
                key_push: K_SPACE,
                system: [:key_down],
                equal: {_SKIP_: true}

        _END_FRAME_

        #クリック待ちアイコンの表示
        _CHECK_ :_TEMP_, not_equal: {_SKIP_: true} do
          _CHECK_ system: [:block_given] do
            _SEND_TO_ACTIVE_LINE_ do
              _YIELD_
            end
          end
        end

        #スペースキーあるいはCTRLキーの押下待機
        _WAIT_  :_TEMP_, key_down: K_RCONTROL,
                          key_push: K_SPACE,
                          system: [:key_down],
                          equal: {_SKIP_: true}

        #ウェイクに移行
        _SET_ :_TEMP_, _SLEEP_: false
      end
  end
end

###############################################################################
#汎用ボタン
###############################################################################

#ボタンコントロール
_DEFINE_ :_IMAGE_BUTTON_ do |argument, options|
  _CREATE_ :ClickableLayoutControl, 
    x: options[:x] || 0,
    y: options[:y] || 0,
    width:256, 
    height:256,
    id: argument do
    _CREATE_ :TileMapControl, 
      width: 256,
      height: 256 do
      _SET_ map_array: [[0]]
      _ADD_TILE_ 0, file_path: "./resource/button_normal.png"
      _ADD_TILE_ 1, file_path: "./resource/button_over.png"
      _ADD_TILE_ 2, file_path: "./resource/button_key_down.png"
    end
    _STACK_LOOP_ do
      _END_FRAME_
      _CHECK_ mouse: [:cursor_over] do
        _SEND_(0){ _MAP_STATUS_ 1, x:0, y:0}
      end
      _CHECK_ mouse: [:cursor_out] do
        _SEND_(0){ _MAP_STATUS_ 0, x:0, y:0}
      end
      _CHECK_ mouse: [:key_down] do
        _SEND_(0){ _MAP_STATUS_ 2, x:0, y:0}
      end
      _CHECK_ mouse: [:key_up] do
        _SEND_(0){ _MAP_STATUS_ 1, x:0, y:0}
      end
      _CHECK_ system: [:block_given] do
        _YIELD_
      end
    end
  end
end

###############################################################################
#汎用テキストボタン
###############################################################################

#テキストボタン定義
_DEFINE_ :_TEXT_BUTTON_ do |argument, 
  id: :test, 
  x: 0, #Ｘ座標
  y: 0, #Ｙ座標
  width: 128, #ボタンＸ幅
  height: 32, #ボタンＹ幅
  text: "", #表示文字列
  size: 31, #文字サイズ
  font_name: "ＭＳ ゴシック", #フォント名
  char_color: [255,255,255], #文字色
  out_color: [0,0,0], #カーソルがボタン外にある時の背景色
  in_color: [255,255,0], #カーソルがボタン上にある時の背景色
  float_y: nil,
  **options|
  _CREATE_ :ClickableLayoutControl, id: id,
    x: x , y: y, width: width , height: height,
    float_y: float_y do
    #テキストを描画するRenderTarget
    _CREATE_ :RenderTargetControl, id: :text_area, 
      width: width, height: height, bgcolor: out_color do
      _CREATE_ :CharControl, 
        size: size, 
        color: char_color, 
        font_name: font_name, 
        charactor: text
    end
    _STACK_LOOP_ do
      #マウスが領域内に入ったら色を変える
      _WAIT_ mouse: [:cursor_over]
      text_area{_SET_ bgcolor: in_color}

      _WAIT_ mouse: [:cursor_out, :key_down]
      #マウスが領域外に出たら色を戻す
      _CHECK_ mouse: [:cursor_out] do
        text_area{_SET_ bgcolor: out_color}
      end
      #マウスがクリックされたら付与ブロックを実行する
      _CHECK_ mouse: [:key_down] do
        #_EVAL_ "pp '[" + text.to_s + "]が押されました'"
        _YIELD_ id, options
      end
    end
  end
end

###############################################################################
#ラベル
###############################################################################

#既読管理ラベル
_DEFINE_ :_LABEL_ do |arugment, options|

  #既読フラグハッシュが無ければ新設
  _CHECK_ :_SYSTEM_, equal: {_READ_CHAPTER_: nil} do
    _SET_ :_SYSTEM_, _READ_CHAPTER_: {}
  end

  ###################################################################
  #初期値更新
  ###################################################################

  #チャプターの更新
  #ラベルにチャプターが記述されている場合
  if  options[:chapter]
    #ラベルにＩＤが記述されている場合
    if options[:id]
      #アクティブIDを設定値で更新
      _SET_ :_TEMP_, _ACTIVE_CHAPTER_ID_: options[:id]
      #アクティブチャプターを設定値で更新
      _SET_ :_TEMP_, _ACTIVE_CHAPTER_NAME_: options[:chapter]
    #ラベルにＩＤが記述されていない場合
    else
      _GET_ :_ACTIVE_CHAPTER_NAME_, 
            datastore: :_TEMP_ do |_ACTIVE_CHAPTER_NAME_:|
        #直前のアクティブチャプターと設定値が同じ場合
        if _ACTIVE_CHAPTER_NAME_ == options[:chapter]
          #アクティブIDをインクリメント
          _GET_ :_ACTIVE_CHAPTER_ID_, 
                datastore: :_TEMP_ do |_ACTIVE_CHAPTER_ID_:|
            _SET_ :_TEMP_, _ACTIVE_CHAPTER_ID_: _ACTIVE_CHAPTER_ID_ + 1
          end
        #直前のアクティブチャプターと設定値が異なる場合
        else
          #アクティブIDをゼロで初期化
          _SET_ :_TEMP_, _ACTIVE_CHAPTER_ID_: 0
        end
      end
      #アクティブチャプターを設定値で更新
      _SET_ :_TEMP_, _ACTIVE_CHAPTER_NAME_: options[:chapter]
    end
  else
    #ラベルにＩＤが記述されている場合
    if options[:id]
      #アクティブチャプター名が設定されていない場合
      _CHECK_ :_TEMP_, null: :_ACTIVE_CHAPTER_NAME_ do
        raise
      end
      #idを設定
      _SET_ :_TEMP_, _ACTIVE_CHAPTER_ID_: options[:id]
    #ラベルにＩＤが記述されていない場合
    else
      #アクティブチャプター名が設定されていない場合
      _CHECK_ :_TEMP_, null: :_ACTIVE_CHAPTER_NAME_ do
        #例外発生
        raise
      end
      #アクティブIDが既に設定されている場合
      _CHECK_ :_TEMP_, not_null: :_ACTIVE_CHAPTER_ID_ do
        #アクティブIDをインクリメント
        _GET_ :_ACTIVE_CHAPTER_ID_, 
              datastore: :_TEMP_ do |_ACTIVE_CHAPTER_ID_:|
          _SET_ :_TEMP_, _ACTIVE_CHAPTER_ID_: _ACTIVE_CHAPTER_ID_ + 1
        end
      end
      #アクティブIDが既に設定されていない場合
      _CHECK_ :_TEMP_, null: :_ACTIVE_CHAPTER_ID_ do
        #アクティブIDをゼロで初期化
        _SET_ :_TEMP_, _ACTIVE_CHAPTER_ID_: 0
      end
    end
  end

  ###################################################################
  #頭出しモードの場合
  ###################################################################

  _GET_ [:_ACTIVE_CHAPTER_ID_], datastore: :_TEMP_ do |
             _ACTIVE_CHAPTER_ID_:|
    _CHECK_ :_TEMP_, equal: {_CHAPTER_START_MODE_: true} do
      #ページが指定したＩＤでない場合
      _CHECK_ :_LOCAL_, not_equal: {_START_: _ACTIVE_CHAPTER_ID_} do
        #ページを飛ばす
        _RETURN_
      end
      #ラベルモードをノーマルに変更する
      _SET_ :_TEMP_, _CHAPTER_START_MODE_: false
    end
  end

  ###################################################################
  #既読スキップモードの場合
  ###################################################################

  #スキップモードの場合
  _CHECK_ :_TEMP_, equal: {_CHAPTER_SKIP_MODE_: true} do
    _GET_ [:_ACTIVE_CHAPTER_ID_, :_ACTIVE_CHAPTER_NAME_],
          datastore: :_TEMP_ do |
             _ACTIVE_CHAPTER_ID_:, _ACTIVE_CHAPTER_NAME_:|

      _GET_ :_READ_CHAPTER_, 
            datastore: :_SYSTEM_ do |_READ_CHAPTER_:|

        #初出のチャプターであればハッシュに書庫を作成
        unless _READ_CHAPTER_[_ACTIVE_CHAPTER_NAME_]
          _READ_CHAPTER_[_ACTIVE_CHAPTER_NAME_] = []
        end

        #アクティブＩＤが既に書庫に格納されている場合
        if(_READ_CHAPTER_[_ACTIVE_CHAPTER_NAME_].index(_ACTIVE_CHAPTER_ID_))
          #スキップモードＯＮ
          _SET_ :_TEMP_, _SKIP_: true
        else
          #スキップモードＯＦＦ
          _SET_ :_TEMP_, _SKIP_: false
        end
      end
    end
  end

  ###################################################################
  #現在のチャプターを保存
  ###################################################################

  _GET_ :_READ_CHAPTER_,  datastore: :_SYSTEM_ do |_READ_CHAPTER_:|
    _GET_ [:_ACTIVE_CHAPTER_ID_, :_ACTIVE_CHAPTER_NAME_],
          datastore: :_TEMP_ do |
            _ACTIVE_CHAPTER_ID_:, _ACTIVE_CHAPTER_NAME_:|
      if _READ_CHAPTER_[_ACTIVE_CHAPTER_NAME_]
        _READ_CHAPTER_[_ACTIVE_CHAPTER_NAME_].push(_ACTIVE_CHAPTER_ID_).uniq!
      else
        _READ_CHAPTER_[_ACTIVE_CHAPTER_NAME_] = []
        _READ_CHAPTER_[_ACTIVE_CHAPTER_NAME_].push(_ACTIVE_CHAPTER_ID_)
      end
    end
  end

  ###################################################################
  #テキスト評価
  ###################################################################
  _YIELD_ 
end

