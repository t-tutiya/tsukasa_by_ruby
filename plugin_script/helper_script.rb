#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver2.2(2017/1/28)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2017> <tsukasa TSUCHIYA>
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
#ヘルパーコマンド：待機
###############################################################################

#１フレーム待機する
#オプション：_CHECK_条件
# count:_LOOP_に渡されるカウント（整数）
# input:_CHECK_INPUT_に渡される条件（ハッシュ）
_DEFINE_ :_WAIT_ do |options|
  _LOOP_ options[:count] do
    _CHECK_ options do
      _BREAK_
    end
    if options[:input]
      _CHECK_INPUT_ options[:input] do
        _BREAK_
      end
    end
    _CHECK_BLOCK_ do
      _YIELD_
    end
    _HALT_
  end
end

###############################################################################
#ヘルパーコマンド：マウス／ゲームパッド入力
###############################################################################

#キー入力_CHECK_
_DEFINE_ :_CHECK_INPUT_  do |options|
  _CHECK_ [:_ROOT_, :_INPUT_], options do
    _YIELD_
  end
end

###############################################################################
#ヘルパーコマンド：子コントロールの描画
###############################################################################

#Imageを生成し、指定したコントロール配下を描画する
_DEFINE_ :_TO_IMAGE_ do 
  |_ARGUMENT_:, width: nil, height: nil, scale: nil, z: Float::INFINITY, visible: true|
  _GET_ [:width, :height] do |options|
    #width/heightのどちらかが設定されていない場合、現在の幅を使用する
    unless width and height
      width = options[:width]
      height= options[:height]
    end
    #新規Imageの生成（初期設定では不可視）
    _CREATE_ :Image, id: _ARGUMENT_, z: z, visible: false,
      width: width, height: height do
      #自身と並列の子コントロールを描画する（自身は除く）
      _DRAW_ [:_PARENT_], scale: scale
      #可視設定を更新する
      _SET_ visible: visible
      #ブロックコマンド実行
      _CHECK_BLOCK_ do
        _YIELD_
      end
    end
  end
  #Imageのコマンドリストを評価させるために１フレ送る
  _HALT_
end

###############################################################################
#ヘルパーコマンド：セーブロード管理
###############################################################################

#_SYSTEM_コントロールを保存する
#※保存されるのは次フレームなので注意
_DEFINE_ :_SYSTEM_SAVE_ do |_ARGUMENT_:|
  _SERIALIZE_ control: [:_ROOT_, :_SYSTEM_] do |command_list:|
    db = PStore.new(_ARGUMENT_)
    db.transaction do
      db["key"] = command_list
    end
  end
end

#_SYSTEM_コントロールに読み込む
#※保存されるのは次フレームなので注意
_DEFINE_ :_SYSTEM_LOAD_ do |_ARGUMENT_:|
  _SEND_ [:_ROOT_, :_SYSTEM_] do
    db = PStore.new(_ARGUMENT_)
    command_list = nil
    db.transaction do
      command_list = db["key"]
    end
    _SERIALIZE_ command_list
  end
end

#_LOCAL_コントロールを保存する
#※保存されるのは次フレームなので注意
_DEFINE_ :_LOCAL_SAVE_ do |_ARGUMENT_:|
  _SEND_ [:_ROOT_, :_LOCAL_] do
    _SERIALIZE_ do |command_list:|
      db = PStore.new(_ARGUMENT_)
      db.transaction do
        db["key"] = command_list
      end
    end
  end
end

#_LOCAL_コントロールを読み込む
#※保存されるのは次フレームなので注意
_DEFINE_ :_LOCAL_LOAD_ do |_ARGUMENT_:|
  _SEND_ [:_ROOT_, :_LOCAL_] do
    db = PStore.new(_ARGUMENT_)
    command_list = nil
    db.transaction do
      command_list = db["key"]
    end
    _SERIALIZE_ command_list
  end
end

#コントロールツリーを保存する
_DEFINE_ :_QUICK_SAVE_ do |_ARGUMENT_:|
  _SERIALIZE_ do |command_list:|
    db = PStore.new(_ARGUMENT_)
    db.transaction do
      db["key"] = command_list
    end
  end
end

#コントロールツリーを読み込む
_DEFINE_ :_QUICK_LOAD_ do |_ARGUMENT_:|
  db = PStore.new(_ARGUMENT_)
  command_list = nil
  db.transaction do
    command_list = db["key"]
  end
  _SERIALIZE_ command_list
end

###############################################################################
#ヘルパーコマンド：汎用ボタン
###############################################################################

#汎用ボタンロジック
_DEFINE_ :_BUTTON_BASE_ do |id:, shape:, **options|
  _CREATE_ :ClickableLayout, 
    id: id || nil, shape: shape,
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
        _CHECK_ collision: :cursor_over do
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
        _CHECK_ collision: [:cursor_out, :key_push] do
          _BREAK_
        end
      end
      _CHECK_ collision: :cursor_out do
        _RETURN_ do
          on_mouse_inner_out
        end
      end

      #マウスがクリックされたら付与ブロックを実行する
      _CHECK_ collision: :key_push do
        _RETURN_ do
          on_key_inner_push
        end
      end
    end

    #ボタン上でカーソルが押された
    _DEFINE_ :on_key_inner_push do
      on_key_push
      _WAIT_ do
        _CHECK_ collision: :key_up do
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

    _HALT_

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
  
  _BUTTON_BASE_ id: id, shape: [0,0,width,height], width: width, height: height, **options do
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
      _YIELD_
    end
  end
end

#ボタンコントロール
_DEFINE_ :_IMAGE_BUTTON_ do |options|
  _BUTTON_BASE_ options[:_ARGUMENT_],
    shape: [0,0,256,256],
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

