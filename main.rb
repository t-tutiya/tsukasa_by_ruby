#! ruby -E utf-8

require 'dxruby'
require 'pp'
require './system/rag.rb'

#初期化
Window.resize(1280, 720)

rag = Rag.new({ :width => 1280,
                :height => 720,
                :script_path => "./scenario/scenario02.rb",
                :id => :default_layout_container
                })
#ゲームループ
Window.loop do
  #Ragエンジン処理
  rag.update
  #Ragエンジン描画
  rag.render(0, 0, Window, 1280, 720)
end