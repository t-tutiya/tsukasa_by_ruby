#! ruby -E utf-8

require 'dxruby'
require './system/tsukasa.rb'

width = 800
heigth = 600

#初期化
Window.resize(width, heigth)

tsukasa = Tsukasa.new({ :width => width,
                        :height => heigth,
                        })
#ゲームループ
Window.loop do
  #pp "frame"
  #Ragエンジン処理
  tsukasa.update
  #Ragエンジン描画
  tsukasa.render(0, 0, Window)
end
