#! ruby -E utf-8

require './system/Tsukasa.rb'
require 'pp'

###############################################################################
#TSUKASA for DXRuby ver2.1(2016/12/23)
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


##############################################################################
#設定
##############################################################################

#ウィンドウのサイズ
width = 1024
height = 600

#ウィンドウの表示位置
x = 0
y = 0

#画面中央へ自動配置する（true=する/false=しない（初期値：true））
center = true

#puts DXRuby::VERSION

##############################################################################
#内部実装
##############################################################################

#ベース背景色
DXRuby::Window.bgcolor=[0,0,0]
#サイズ設定
DXRuby::Window.resize(width, height)

if center
  x, y = DXRuby::Window.get_current_mode
  x = x / 2 - width / 2
  y = y / 2 - height / 2
end

DXRuby::Window.x = x
DXRuby::Window.y = y

tsukasa = Tsukasa::Window.new()do
  #ヘルパーコントロール群

  #データストアコントロール
  require_relative './system/Data.rb'
  #タイルマップ管理
  require_relative './system/TileMap.rb'
  #シェーダー処理
  require_relative './system/Shader.rb'
  #ルールトランジション
  require_relative './system/RuleTransition.rb'

  #タイトルバーの文字列を設定
  _SET_ caption: "Tsukasa Engine powered by DXRuby"

  #一時データストア
  _CREATE_ :Data, id: :_TEMP_
  #ローカルデータストア
  _CREATE_ :Data, id: :_LOCAL_
  #システムデータストア
  _CREATE_ :Data, id: :_SYSTEM_

  #キー入力管理コントロール
  _CREATE_ :Input, id: :_INPUT_

  #プラグインネイティブファイルの読み込み
  Dir.glob("./plugin_control/*.rb").each do |path|
    require path
  end

  #プラグインスクリプトファイルの読み込み
  Dir.glob("./plugin_script/*.rb").each do |path|
    _INCLUDE_ path
  end

  #初期レイヤ（背景）
  _CREATE_ :Image, z:    0, id: :base
  #初期レイヤ０
  _CREATE_ :Image, z: 1000, id: :img0
  #初期レイヤ１
  _CREATE_ :Image, z: 2000, id: :img1
  #初期レイヤ２
  _CREATE_ :Image, z: 3000, id: :img2

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
  _DEFINE_PROPERTY_ _DEFAULT_TEXT_PAGE_: [:_ROOT_, :text0]

  #画面サイズ変更
  _RESIZE_ width: 1024, height: 600

  #最初に実行するスクリプトファイルを呼びだす
  _INCLUDE_ "./first.rb"
end

#ゲームループ
DXRuby::Window.loop(true) do

  #司エンジン処理
  tsukasa.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
  tsukasa.render(0, 0, DXRuby::Window)

  #スクリプトで終了コマンドが実行された場合
  break if tsukasa.exit
end
