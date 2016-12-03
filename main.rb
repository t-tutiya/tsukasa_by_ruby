#! ruby -E utf-8

require './system/Tsukasa.rb'
require 'pp'

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
      #tksスクリプト用のパーサーを登録
      _SCRIPT_PARSER_ ext_name: :tks, path: "./TKSParser.rb",parser: :TKSParser

      #デフォルトのユーザー定義コマンド群の読み込み
      _INCLUDE_ "./default/default_script.rb"

      #標準ユーティリティー群の読み込み
      _INCLUDE_ "./default/utility_script.rb"

      #一時データストア
      _CREATE_ :Data, id: :_TEMP_
      #ローカルデータストア
      _CREATE_ :Data, id: :_LOCAL_
      #システムデータストア
      _CREATE_ :Data, id: :_SYSTEM_

      #カーソル可視設定
      _SET_ [:_ROOT_, :_SYSTEM_], _CURSOR_VISIBLE_: true
      #マウスカーソルの可視設定
      _DEFINE_ :_MOUSE_ENABLE_ do |_ARGUMENT_:|
        _SET_ [:_ROOT_, :_SYSTEM_], _CURSOR_VISIBLE_: _ARGUMENT_
        DXRuby::Input.mouse_enable = _ARGUMENT_
      end

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
          
          _GET_ :_CURSOR_VISIBLE_, control: [:_ROOT_, :_SYSTEM_] do |options|
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

      #TODO:requested_closeに依存してる
      _RESIZE_ width: 1024, height: 600

      #プラグインファイルの配置フォルダと検索対象
      _SET_ [:_ROOT_, :_SYSTEM_], _PLUGIN_PATH_: "./plugin/*.rb"

      #プラグインスクリプトファイルの読み込み
      _GET_ :_PLUGIN_PATH_, control: :_SYSTEM_ do |_PLUGIN_PATH_:|
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
      _SET_ [:_ROOT_, :_TEMP_], _DEFAULT_TEXT_PAGE_: :text0

      #タイトルバーの文字列を設定
      _WINDOW_STATUS_ caption: "Tsukasa Engine powered by DXRuby", #文字列
                      x: 0,
                      y: 0

      #最初に実行するスクリプトファイルを呼びだす
      _INCLUDE_ "./first.rb"
end

#ゲームループ
DXRuby::Window.loop(true) do

  #司エンジン処理
  tsukasa.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
  tsukasa.render(0, 0, DXRuby::Window)

  #スクリプトで終了コマンドが実行された場合
  break if tsukasa.close?
end
