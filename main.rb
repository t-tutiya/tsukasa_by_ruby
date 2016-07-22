#! ruby -E utf-8

require './system/tsukasa.rb'

width = 1024
height = 600

#ベース背景色
Window.bgcolor=[0,0,0]
#初期化
Window.resize(width, height)
Window.x = 0
Window.y = 0

tsukasa = Tsukasa.new({ :width => width,
                        :height => height,
                        })
#ゲームループ
Window.loop(true) do
  #司エンジン処理
  tsukasa.update()
  tsukasa.render(0, 0, Window)

  #スクリプトで終了コマンドが実行された場合
  break if tsukasa.close?
end
