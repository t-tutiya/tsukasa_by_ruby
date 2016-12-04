#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver2.0(2016/8/28)
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

#tksスクリプト用のパーサーを登録
_SCRIPT_PARSER_ ext_name: :tks, path: "./TKSParser.rb",parser: :TKSParser

#標準ポーズコマンド
_DEFINE_ :_PAUSE_ do
  #スキップ状態の場合
  _CHECK_ [:_ROOT_, :_TEMP_], equal: {_SKIP_: true} do
    #ウェイクに移行
    _SET_ [:_ROOT_, :_TEMP_], _SLEEP_: false
    _RETURN_ do
      #スキップモードの誤伝搬を防ぐ
      _END_FRAME_
    end
  end

  #テキストレイヤのクリック待ち
  _GET_ :_DEFAULT_TEXT_PAGE_ do |_DEFAULT_TEXT_PAGE_:|
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
      _SET_ [:_ROOT_, :_TEMP_], _SLEEP_: false
    end
  end

  #スリープフラグを立てる
  _SET_ [:_ROOT_, :_TEMP_], _SLEEP_: true

  #スリープフラグが下りるまで待機
  _WAIT_ [:_ROOT_, :_TEMP_], equal: {_SLEEP_: false} do
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
      _WAIT_ [:_ROOT_, :_TEMP_], equal: {_SLEEP_: false}

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
          _RETURN_ do 
            inner_loop
          end
        end
        inner_loop
      end

      #待機フラグが下がるまで待機
      _WAIT_ [:_ROOT_, :_TEMP_], equal: {_SLEEP_: false}

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
  _GET_ :_DEFAULT_TEXT_PAGE_ do |_DEFAULT_TEXT_PAGE_:|
    _SEND_ _DEFAULT_TEXT_PAGE_ do
      _SET_ options
    end
  end
end

#デフォルトテキストウィンドウの_RUBI_ラッパー
_DEFINE_ :_CHAR_RUBI_ do |options|
  _GET_ :_DEFAULT_TEXT_PAGE_ do |_DEFAULT_TEXT_PAGE_:|
    _SEND_ _DEFAULT_TEXT_PAGE_ do
      _RUBI_ options
    end
  end
end

#デフォルトテキストウィンドウの_SET_ラッパー
_DEFINE_ :_CHAR_IMAGE_ do |path:|
  _GET_ :_DEFAULT_TEXT_PAGE_ do |_DEFAULT_TEXT_PAGE_:|
    _SEND_ _DEFAULT_TEXT_PAGE_ do
      _CHAR_ image_path: path
    end
  end
end

#文字間ウェイトの更新
_DEFINE_ :_WAIT_FRAME_ do |_ARGUMENT_:|
  _GET_ :_DEFAULT_TEXT_PAGE_ do |_DEFAULT_TEXT_PAGE_:|
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
      _WAIT_  [:_ROOT_, :_TEMP_], 
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
      _WAIT_  [:_ROOT_, :_TEMP_], 
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
      _MOVE_ [20, :in_quint], alpha: [0,255] do
        #キー入力判定
        _CHECK_INPUT_  key_down: K_RCONTROL,
                       key_push: K_SPACE,
                       mouse: :push do
          #α値を初期化
          _SET_ alpha: 255
          _BREAK_
        end
        _CHECK_ [:_ROOT_, :_TEMP_], equal: {_SKIP_: true} do
          #α値を初期化
          _SET_ alpha: 255
          _BREAK_
        end
      end

      #待機フラグが下がるまで待機
      _WAIT_ [:_ROOT_, :_TEMP_], equal: {_SLEEP_: false}

      #キー伝搬を防ぐためにフレームを終了する
      _END_FRAME_

      #ハーフフェードアウト
      _MOVE_ 60, alpha: [255, 128] do
        #キー入力判定
        _CHECK_INPUT_ key_down: K_RCONTROL, 
                      key_push: K_SPACE,
                      mouse: :push do
          #α値を初期化
          _SET_ alpha: 128
          #スキップモードの場合
          _CHECK_ [:_ROOT_, :_TEMP_], equal: {_SKIP_: true} do
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
#ラベル
###############################################################################

#既読管理ラベル
_DEFINE_ :_LABEL_ do |options|

  #既読フラグハッシュが無ければ新設
  _CHECK_ [:_ROOT_, :_SYSTEM_], equal: {_READ_CHAPTER_: nil} do
    _SET_ [:_ROOT_, :_SYSTEM_], _READ_CHAPTER_: {}
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
      _SET_ [:_ROOT_, :_TEMP_], _ACTIVE_CHAPTER_ID_: options[:id]
      #アクティブチャプターを設定値で更新
      _SET_ [:_ROOT_, :_TEMP_], _ACTIVE_CHAPTER_NAME_: options[:chapter]
    #ラベルにＩＤが記述されていない場合
    else
      _GET_ :_ACTIVE_CHAPTER_NAME_, 
            control: [:_ROOT_, :_TEMP_] do |_ACTIVE_CHAPTER_NAME_:|
        #直前のアクティブチャプターと設定値が同じ場合
        if _ACTIVE_CHAPTER_NAME_ == options[:chapter]
          #アクティブIDをインクリメント
          _GET_ :_ACTIVE_CHAPTER_ID_, 
                control: [:_ROOT_, :_TEMP_] do |_ACTIVE_CHAPTER_ID_:|
            _SET_ [:_ROOT_, :_TEMP_], _ACTIVE_CHAPTER_ID_: _ACTIVE_CHAPTER_ID_ + 1
          end
        #直前のアクティブチャプターと設定値が異なる場合
        else
          #アクティブIDをゼロで初期化
          _SET_ [:_ROOT_, :_TEMP_], _ACTIVE_CHAPTER_ID_: 0
        end
      end
      #アクティブチャプターを設定値で更新
      _SET_ [:_ROOT_, :_TEMP_], _ACTIVE_CHAPTER_NAME_: options[:chapter]
    end
  else
    #ラベルにＩＤが記述されている場合
    if options[:id]
      #アクティブチャプター名が設定されていない場合
      _CHECK_ [:_ROOT_, :_TEMP_], equal: {_ACTIVE_CHAPTER_NAME_: nil} do
        raise
      end
      #idを設定
      _SET_ [:_ROOT_, :_TEMP_], _ACTIVE_CHAPTER_ID_: options[:id]
    #ラベルにＩＤが記述されていない場合
    else
      #アクティブチャプター名が設定されていない場合
      _CHECK_ [:_ROOT_, :_TEMP_], equal: {_ACTIVE_CHAPTER_NAME_: nil} do
        #例外発生
        raise
      end
      #アクティブIDが既に設定されている場合
      _CHECK_ [:_ROOT_, :_TEMP_], not_equal: {_ACTIVE_CHAPTER_ID_: nil} do
        #アクティブIDをインクリメント
        _GET_ :_ACTIVE_CHAPTER_ID_, 
              control: [:_ROOT_, :_TEMP_] do |_ACTIVE_CHAPTER_ID_:|
          _SET_ [:_ROOT_, :_TEMP_], _ACTIVE_CHAPTER_ID_: _ACTIVE_CHAPTER_ID_ + 1
        end
      end
      #アクティブIDが既に設定されていない場合
      _CHECK_ [:_ROOT_, :_TEMP_], equal: {_ACTIVE_CHAPTER_ID_: nil} do
        #アクティブIDをゼロで初期化
        _SET_ [:_ROOT_, :_TEMP_], _ACTIVE_CHAPTER_ID_: 0
      end
    end
  end

  ###################################################################
  #頭出しモードの場合
  ###################################################################

  _GET_ [:_ACTIVE_CHAPTER_ID_], control: [:_ROOT_, :_TEMP_] do |
             _ACTIVE_CHAPTER_ID_:|
    _CHECK_ [:_ROOT_, :_TEMP_], equal: {_CHAPTER_START_MODE_: true} do
      #ページが指定したＩＤでない場合
      _CHECK_ [:_ROOT_, :_LOCAL_], not_equal: {_START_: _ACTIVE_CHAPTER_ID_} do
        #ページを飛ばす
        _RETURN_
      end
      #ラベルモードをノーマルに変更する
      _SET_ [:_ROOT_, :_TEMP_], _CHAPTER_START_MODE_: false
    end
  end

  ###################################################################
  #既読スキップモードの場合
  ###################################################################

  #スキップモードの場合
  _CHECK_ [:_ROOT_, :_TEMP_], equal: {_CHAPTER_SKIP_MODE_: true} do
    _GET_ [:_ACTIVE_CHAPTER_ID_, :_ACTIVE_CHAPTER_NAME_],
          control: [:_ROOT_, :_TEMP_] do |
             _ACTIVE_CHAPTER_ID_:, _ACTIVE_CHAPTER_NAME_:|

      _GET_ :_READ_CHAPTER_, 
            control: [:_ROOT_, :_SYSTEM_] do |_READ_CHAPTER_:|

        #初出のチャプターであればハッシュに書庫を作成
        unless _READ_CHAPTER_[_ACTIVE_CHAPTER_NAME_]
          _READ_CHAPTER_[_ACTIVE_CHAPTER_NAME_] = []
        end

        #アクティブＩＤが既に書庫に格納されている場合
        if(_READ_CHAPTER_[_ACTIVE_CHAPTER_NAME_].index(_ACTIVE_CHAPTER_ID_))
          #スキップモードＯＮ
          _SET_ [:_ROOT_, :_TEMP_], _SKIP_: true
        else
          #スキップモードＯＦＦ
          _SET_ [:_ROOT_, :_TEMP_], _SKIP_: false
        end
      end
    end
  end

  ###################################################################
  #現在のチャプターを保存
  ###################################################################

  _GET_ :_READ_CHAPTER_,  control: [:_ROOT_, :_SYSTEM_] do |_READ_CHAPTER_:|
    _GET_ [:_ACTIVE_CHAPTER_ID_, :_ACTIVE_CHAPTER_NAME_],
          control: [:_ROOT_, :_TEMP_] do |
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

