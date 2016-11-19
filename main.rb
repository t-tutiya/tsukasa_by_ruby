#! ruby -E utf-8

require './system/Tsukasa.rb'

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

##############################################################################
#内部実装（弄らないでください）
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

tsukasa = Tsukasa::Window.new({ :width => width,
                                :height => height,
                                })
#ゲームループ
DXRuby::Window.loop(true) do

  #司エンジン処理
  tsukasa.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
  tsukasa.render(0, 0, DXRuby::Window)

  #スクリプトで終了コマンドが実行された場合
  break if tsukasa.close?
end
