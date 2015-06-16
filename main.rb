#! ruby -E utf-8

require 'dxruby'
require 'pp'
require './system/tsukasa.rb'

#初期化
Window.resize(1280, 720)

tsukasa = Tsukasa.new({ :width => 1280,
                :height => 720,
                :script_path => "./test/scenario_sms_04.rb",
#                :script_path => "./scenario/scenario_function.rb",
#                :script_path => "./scenario/scenario_if.rb",
#                :script_path => "./scenario/scenario_case_when.rb",
#                :script_path => "./scenario/scenario_while.rb",
                :id => :default_layout_container
                })
#ゲームループ
Window.loop do
  #pp "frame"
  #Ragエンジン処理
  tsukasa.update
  #Ragエンジン描画
#  rag.render(0, 0, Window, 1280, 720)
  tsukasa.render(0, 0, Window)
end