#! ruby -E utf-8

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

#puts DXRuby::VERSION

#コンフィグファイルの読み込み
_INCLUDE_ "./default/config.rb"

#デフォルトのユーザー定義コマンド群の読み込み
_INCLUDE_ "./default/default_script.rb"

#標準ユーティリティー群の読み込み
_INCLUDE_ "./default/utility_script.rb"

#ウィンドウの閉じるボタンの押下チェック
#ウィンドウ枠外にマウスカーソルが出た場合のアイコン表示管理
_CREATE_ :ClickableLayout, id: :requested_close,
  width: DXRuby::Window.width, height: DXRuby::Window.height do
  _DEFINE_ :inner_loop do
    #ウィンドウの閉じるボタンが押された場合に呼びだされる。
    _CHECK_REQUESTED_CLOSE_ do
      _EXIT_ #アプリを終了する
      _RETURN_
    end
    
    _GET_ :_CURSOR_VISIBLE_, datastore: :_SYSTEM_ do |options|
      _CHECK_MOUSE_ :cursor_off do
        #カーソルを表示する
        DXRuby::Input.mouse_enable = true unless options[:_CURSOR_VISIBLE_]
      end

      _CHECK_MOUSE_ :cursor_on do
        #カーソルを不可視に戻す
        DXRuby::Input.mouse_enable = false unless options[:_CURSOR_VISIBLE_]
      end
    end
    _END_FRAME_
    _RETURN_ do
      inner_loop
    end
  end
  inner_loop
end

#プラグインスクリプトファイルの読み込み
_GET_ :_PLUGIN_PATH_, datastore: :_SYSTEM_ do |_PLUGIN_PATH_:|
  Dir.glob(_PLUGIN_PATH_).each do |path:|
    _INCLUDE_ path
  end
end

#初期レイヤ（背景）
_CREATE_ :Image,
  z: 0, #描画順序
  id: :base

#初期レイヤ０
_CREATE_ :Image,
  z: 1000, #描画順序
  id: :img0

#初期レイヤ１
_CREATE_ :Image,
  z: 2000, #描画順序
  id: :img1

#初期レイヤ２
_CREATE_ :Image,
  z: 3000, #描画順序
  id: :img2

#初期テキストウィンドウ
_TEXT_WINDOW_ :text0, 
  x: 96,
  y: 256 + 164,
  width: 1024,
  height: 192,
  size: 32, 
  font_name: "ＭＳＰ ゴシック",
  z: 1000000 #描画順序

#初期テキストウィンドウのidを格納
_SET_ :_TEMP_, _DEFAULT_TEXT_PAGE_: :text0

#タイトルバーの文字列を設定
_WINDOW_STATUS_ caption: "Tsukasa Engine powered by DXRuby", #文字列
                cursor_type: IDC_ARROW,
                x: 0,
                y: 0

#最初に実行するスクリプトファイルを呼びだす
_INCLUDE_ "./first.rb"
