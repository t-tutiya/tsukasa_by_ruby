#! ruby -E utf-8

require './system/Tsukasa.rb'

width = 1024
height = 600

#ベース背景色
DXRuby::Window.bgcolor=[0,0,0]
#初期化
DXRuby::Window.resize(width, height)
DXRuby::Window.x = 0
DXRuby::Window.y = 0

tsukasa = Tsukasa::Window.new({ :width => width,
                                :height => height,
                                })
#ゲームループ
DXRuby::Window.loop(true) do
  #司エンジン処理
  tsukasa.update()
  tsukasa.render(0, 0, DXRuby::Window)

  #スクリプトで終了コマンドが実行された場合
  break if tsukasa.close?
end
