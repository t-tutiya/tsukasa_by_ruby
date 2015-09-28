#! ruby -E utf-8

require 'dxruby'
require './system/tsukasa.rb'

#初期化
Window.resize(800, 600)

tsukasa = Tsukasa.new({ :width => 800,
                        :height => 600,
                        })
#ゲームループ
Window.loop do
  #pp "frame"
  #Ragエンジン処理
  tsukasa.update
  #Ragエンジン描画
  tsukasa.render(0, 0, Window, {:width => 800, :height => 600})
end
