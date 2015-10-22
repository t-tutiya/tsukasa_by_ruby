#! ruby -E utf-8

require 'dxruby'
require './system/tsukasa.rb'

width = 800
heigth = 600

#初期化
Window.resize(width, height)

tsukasa = Tsukasa.new({ :width => width,
                        :height => height,
                        })
#ゲームループ
Window.loop do
  #pp "frame"
  #Ragエンジン処理
  tsukasa.update
  #Ragエンジン描画
  tsukasa.render(0, 0, Window)
end
