#! ruby -E utf-8

require 'dxruby'
require './system/tsukasa.rb'

#初期化
Window.resize(1280, 720)

tsukasa = Tsukasa.new({ :width => 1280,
                        :height => 720,
                        })
#ゲームループ
Window.loop do
  #pp "frame"
  #Ragエンジン処理
  tsukasa.update
  #Ragエンジン描画
  tsukasa.render(0, 0, Window, {:width => 1280, :height => 720})
end
