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
_DEFINE_ :_PAUSE_ do
  #スキップ状態の場合
  _CHECK_ :_TEMP_, equal: {_SKIP_: true} do
    #ウェイクに移行
    _SET_ :_TEMP_, _SLEEP_: false
    _RETURN_ do
      #スキップモードの誤伝搬を防ぐ
      _END_FRAME_
    end
  end

  #テキストレイヤのクリック待ち
  _GET_ :_DEFAULT_TEXT_PAGE_, datastore: :_TEMP_ do |_DEFAULT_TEXT_PAGE_:|
    _SEND_ _DEFAULT_TEXT_PAGE_ do
      #クリック待ちアイコンの表示
      _CHECK_BLOCK_ do
        _CHAR_COMMAND_ do
          _WAIT_ count: 28 do
            _CHECK_INPUT_ key_down: K_RCONTROL,
                 key_push: K_SPACE,
                 mouse: :push do
              _BREAK_
            end
          end
                 
          _YIELD_
        end
      end

      #最後の文字のフェードイン待ち
      _WAIT_ count: 28 do
        #キーの押下を判定
        _CHECK_INPUT_ key_down: K_RCONTROL,
                      key_push: K_SPACE,
                      mouse: :push do
          #キー押下のクリアを待機
          _WAIT_  do
            _CHECK_INPUT_ key_down: K_RCONTROL,
                           key_up: K_SPACE,
                           mouse: :up do
              _BREAK_
            end
          end
          _BREAK_
        end
      end 

      #キー押下待機
      _WAIT_ do 
        _CHECK_INPUT_ key_down: K_RCONTROL,
                       key_push: K_SPACE,
                       mouse: :push do
          _BREAK_
        end
      end

      #ウェイクに移行
      _SET_ :_TEMP_, _SLEEP_: false
    end
  end

  #スリープフラグを立てる
  _SET_ :_TEMP_, _SLEEP_: true

  #スリープフラグが下りるまで待機
  _WAIT_ :_TEMP_, equal: {_SLEEP_: false} do
    _CHECK_INPUT_ key_down: K_RCONTROL do
      _BREAK_
    end
  end
end

_INCLUDE_ "./resource/icon/icon_8_a.rb"

#行クリック待ちポーズ
_DEFINE_ :_LINE_PAUSE_ do
  #ルートのクリック待ち
  _PAUSE_ do
    _CREATE_ :Layout, width: 24, height: 24,
      align_y: :bottom, float_x: :left do
      _CREATE_ :TileMap, 
        map_array: [[0]], size_x: 1, size_y: 1, 
        width: 24, height: 24, z: 1000000 do
        _SET_TILE_GROUP_ path: "./resource/icon/icon_8_a.png",
          x_count: 4, y_count: 2
        _ICON_8_
      end

      #待機フラグが下がるまで待機
      _WAIT_ :_TEMP_, equal: {_SLEEP_: false}

      _DELETE_
    end
  end
end

#行クリック待ちポーズ(_LINE_PAUSE_の省略板)
_DEFINE_ :lp do
  _LINE_PAUSE_
end

_DEFINE_ :_END_PAUSE_ do
  #ルートのクリック待ち
  _PAUSE_ do
    _CREATE_ :Layout, width: 24, height: 24,
      align_y: :bottom, float_x: :left do
      _CREATE_ :TileMap, 
        map_array: [[0]], size_x: 1, size_y: 1, 
        width: 24, height: 24, z: 1000000 do
        _SET_TILE_GROUP_ path: "./resource/icon/icon_4_a.png",
          x_count: 4, y_count: 1
        _DEFINE_ :inner_loop do
          _MAP_STATUS_ 0
          _WAIT_ count: 5
          _MAP_STATUS_ 1
          _WAIT_ count: 5
          _MAP_STATUS_ 2
          _WAIT_ count: 5
          _MAP_STATUS_ 3
          _WAIT_ count: 5
          _RETURN_ :inner_loop
        end
        inner_loop
      end

      #待機フラグが下がるまで待機
      _WAIT_ :_TEMP_, equal: {_SLEEP_: false}

      _DELETE_
    end
  end
end

#ページクリック待ちポーズ(_END_PAUSE_の省略板)
_DEFINE_ :ep do
  _END_PAUSE_
end

#デフォルトテキストウィンドウの_SET_ラッパー
_DEFINE_ :_CHAR_SET_ do |options|
  _GET_ :_DEFAULT_TEXT_PAGE_, datastore: :_TEMP_ do |_DEFAULT_TEXT_PAGE_:|
    _SEND_ _DEFAULT_TEXT_PAGE_ do
      _SET_ options
    end
  end
end

#デフォルトテキストウィンドウの_RUBI_ラッパー
_DEFINE_ :_CHAR_RUBI_ do |options|
  _GET_ :_DEFAULT_TEXT_PAGE_, datastore: :_TEMP_ do |_DEFAULT_TEXT_PAGE_:|
    _SEND_ _DEFAULT_TEXT_PAGE_ do
      _RUBI_ options
    end
  end
end

#デフォルトテキストウィンドウの_SET_ラッパー
_DEFINE_ :_CHAR_IMAGE_ do |path:|
  _GET_ :_DEFAULT_TEXT_PAGE_, datastore: :_TEMP_ do |_DEFAULT_TEXT_PAGE_:|
    _SEND_ _DEFAULT_TEXT_PAGE_ do
      _CHAR_ image_path: path
    end
  end
end

#文字間ウェイトの更新
_DEFINE_ :_WAIT_FRAME_ do |_ARGUMENT_:|
  _GET_ :_DEFAULT_TEXT_PAGE_, datastore: :_TEMP_ do |_DEFAULT_TEXT_PAGE_:|
    _SEND_ _DEFAULT_TEXT_PAGE_ do
      _DEFINE_ :_CHAR_WAIT_ do
        _WAIT_ count: _ARGUMENT_ do
          _CHECK_INPUT_ key_down: K_RCONTROL,
                         key_push: K_SPACE,
                         mouse: :push do
            _BREAK_
          end
        end
      end
    end
  end
end

###############################################################################
#デフォルトのレイヤ群
###############################################################################

#標準テキストウィンドウ
_DEFINE_ :_TEXT_WINDOW_ do |options|
  #メッセージウィンドウ
  _CREATE_ :TextPage, 
    id: options[:_ARGUMENT_], **options do
    #文字間ウェイト
    _DEFINE_ :_CHAR_WAIT_ do
      _WAIT_  :_TEMP_, 
        count: 4,
        equal: {_SKIP_: true} do
        _CHECK_INPUT_ key_down: K_RCONTROL,
                      key_push: K_SPACE,
                      mouse: :push do
          _BREAK_
        end
      end
    end

    #行間ウェイト
    _DEFINE_ :_LINE_WAIT_ do
      _WAIT_  :_TEMP_, 
        count: 2,
        equal: {_SKIP_: true} do
        _CHECK_INPUT_ key_down: K_RCONTROL,
                      key_push: K_SPACE,
                      mouse: :push do
          _BREAK_
        end
      end
    end

    #文字レンダラ
    _DEFINE_ :_CHAR_RENDERER_ do
      #フェードイン
      _MOVE_ 20, alpha: [0,255], _OPTION_:{easing: :in_quint} do
        #キー入力判定
        _CHECK_INPUT_  key_down: K_RCONTROL,
                       key_push: K_SPACE,
                       mouse: :push do
          #α値を初期化
          _SET_ alpha: 255
          _BREAK_
        end
        _CHECK_ :_TEMP_, equal: {_SKIP_: true} do
          #α値を初期化
          _SET_ alpha: 255
          _BREAK_
        end
      end

      #待機フラグが下がるまで待機
      _WAIT_ :_TEMP_, equal: {_SLEEP_: false}

      #キー伝搬を防ぐためにフレームを終了する
      _END_FRAME_

      #ハーフフェードアウト
      _MOVE_ 60, alpha: 128 do
        #キー入力判定
        _CHECK_INPUT_ key_down: K_RCONTROL, 
                      key_push: K_SPACE,
                      mouse: :push do
          #α値を初期化
          _SET_ alpha: 128
          #スキップモードの場合
          _CHECK_ :_TEMP_, equal: {_SKIP_: true} do
            #α値を再度初期化
            _SET_ alpha: 255
          end
          _CHECK_INPUT_ key_down: K_RCONTROL  do
            #α値を再度初期化
            _SET_ alpha: 255
          end
          _BREAK_
         end
      end
    end
  end
  _CHECK_BLOCK_ do
    _SEND_ options[:_ARGUMENT_] do
      _YIELD_
    end
  end
end

###############################################################################
#汎用ボタン
###############################################################################

#汎用ボタンロジック
_DEFINE_ :_BUTTON_BASE_ do |id:, width:, height:, **options|
  _CREATE_ :ClickableLayout, 
    id: id || nil,
    width: width, 
    height: height,
    **options do

    #カーソルがコントロールから外れた
    _DEFINE_ :on_mouse_out do
    end

    #カーソルがコントロールに乗った
    _DEFINE_ :on_mouse_over do
    end

    #キーがクリックされた
    _DEFINE_ :on_key_push do
    end

    #キーがクリック解除された
    _DEFINE_ :on_key_up do
    end

    #カーソルがボタン外にある
    _DEFINE_ :on_mouse_inner_out do
      on_mouse_out
      #マウスが領域内に入ったら色を変える
      _WAIT_ do
        _CHECK_MOUSE_ :cursor_over do
          _BREAK_
        end
      end
      _RETURN_ do
        on_mouse_inner_over
      end
    end

    #カーソルがボタン上にある
    _DEFINE_ :on_mouse_inner_over do
      on_mouse_over
      _WAIT_ do
        _CHECK_MOUSE_ [:cursor_out, :key_push] do
          _BREAK_
        end
      end
      _CHECK_MOUSE_ :cursor_out do
        _RETURN_ do
          on_mouse_inner_out
        end
      end

      #マウスがクリックされたら付与ブロックを実行する
      _CHECK_MOUSE_ :key_push do
        _RETURN_ do
          on_key_inner_push
        end
      end
    end

    #ボタン上でカーソルが押された
    _DEFINE_ :on_key_inner_push do
      on_key_push
      _WAIT_ do
        _CHECK_MOUSE_ :key_up do
          _BREAK_
        end
      end
      _RETURN_ do
        on_key_inner_up
      end
    end
    
    #ボタン上でカーソルが押された
    _DEFINE_ :on_key_inner_up do
      on_key_up
      _RETURN_ do
        on_mouse_inner_over
      end
    end

    #ブロック実行
    _CHECK_BLOCK_ do
      _YIELD_ id, options
    end

    _END_FRAME_

    on_mouse_inner_out
  end
end

#テキストボタン
_DEFINE_ :_TEXT_BUTTON_ do 
 |id: nil, #コントロールID
  width: 128, #ボタンＸ幅
  height: 32, #ボタンＹ幅
  text: "", #表示文字列
  out_color: [0,0,0], #カーソルがボタン外にある時の背景色
  in_color: [255,255,0], #カーソルがボタン上にある時の背景色
  char_options: {},
  **options|
  
  _BUTTON_BASE_ id: id, width: width, height: height, **options do
    #背景
    _CREATE_ :DrawableLayout, id: :bg, 
      width: width, height: height, bgcolor: out_color
    #テキスト
    _CREATE_ :Char, id: :text, char: text, **char_options

    #カーソルがコントロールから外れた
    _DEFINE_ :on_mouse_out do
      _SEND_ [:bg] do
        _SET_ bgcolor: out_color
      end
    end

    #カーソルがコントロールに乗った
    _DEFINE_ :on_mouse_over do
      _SEND_ [:bg] do
        _SET_ bgcolor: in_color
      end
    end

    #ブロック実行
    _CHECK_BLOCK_ do
      _YIELD_ id, options
    end
  end
end

#ボタンコントロール
_DEFINE_ :_IMAGE_BUTTON_ do |options|
  _BUTTON_BASE_ options[:_ARGUMENT_],
    width:256, 
    height:256,
    id:  options[:_ARGUMENT_],
    **options do

    _CREATE_ :TileMap, 
      width: 256,
      height: 256 do
      _SET_ map_array: [[0]]
      _SET_TILE_ 0, path: options[:normal]||"./resource/button_normal.png"
      _SET_TILE_ 1, path: options[:over]||"./resource/button_over.png"
      _SET_TILE_ 2, path: options[:down]||"./resource/button_key_down.png"
    end

    #カーソルがコントロールから外れた
    _DEFINE_ :on_mouse_out do
      _SEND_(0){ _MAP_STATUS_ 0}
    end

    #カーソルがコントロールに乗った
    _DEFINE_ :on_mouse_over do
      #マウスが領域内に入ったら色を変える
      _SEND_(0){ _MAP_STATUS_ 1}
    end

    #キーがクリックされた
    _DEFINE_ :on_key_push do
      #画像を「DOWN」に差し替える
      _SEND_(0){ _MAP_STATUS_ 2}
      on_key_push_user
    end

    #キーがクリック解除された
    _DEFINE_ :on_key_up do
    end

    #ユーザーフック用コマンド
    _DEFINE_ :on_key_push_user do
    end

    #ブロック実行
    _CHECK_BLOCK_ do
      _YIELD_ 
    end

  end
end


###############################################################################
#ラベル
###############################################################################

#既読管理ラベル
_DEFINE_ :_LABEL_ do |options|

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
      _CHECK_ :_TEMP_, equal: {_ACTIVE_CHAPTER_NAME_: nil} do
        raise
      end
      #idを設定
      _SET_ :_TEMP_, _ACTIVE_CHAPTER_ID_: options[:id]
    #ラベルにＩＤが記述されていない場合
    else
      #アクティブチャプター名が設定されていない場合
      _CHECK_ :_TEMP_, equal: {_ACTIVE_CHAPTER_NAME_: nil} do
        #例外発生
        raise
      end
      #アクティブIDが既に設定されている場合
      _CHECK_ :_TEMP_, not_equal: {_ACTIVE_CHAPTER_ID_: nil} do
        #アクティブIDをインクリメント
        _GET_ :_ACTIVE_CHAPTER_ID_, 
              datastore: :_TEMP_ do |_ACTIVE_CHAPTER_ID_:|
          _SET_ :_TEMP_, _ACTIVE_CHAPTER_ID_: _ACTIVE_CHAPTER_ID_ + 1
        end
      end
      #アクティブIDが既に設定されていない場合
      _CHECK_ :_TEMP_, equal: {_ACTIVE_CHAPTER_ID_: nil} do
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

###############################################################################
#ヘルパーコマンド関連
###############################################################################

#配列の中に指定した値が含まれていればブロックを実行する
_DEFINE_ :_CHECK_ARRAY_INCLUDE_ do |array:, value:|
  if array.include?(value)
    _YIELD_
  end
end

#１フレーム待機するLOOP
_DEFINE_ :_WAIT_ do |options|
  _LOOP_ options[:count] do
    _CHECK_ options do
      _RETURN_
    end
    _CHECK_BLOCK_ do
      _YIELD_
    end
    _END_FRAME_
  end
end
