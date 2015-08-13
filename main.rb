#! ruby -E utf-8

require 'dxruby'
require 'pp'
require './system/tsukasa.rb'

#初期化
Window.resize(1280, 720)

tsukasa = Tsukasa.new({ :width => 1280,
                :height => 720,
#                :script_path => "./scenario/scenario_function.rb",
#                :script_path => "./scenario/scenario_clickable.rb",
#                :script_path => "./scenario/scenario_yield.rb",
#                :script_path => "./scenario/scenario_if.rb",
#                :script_path => "./scenario/scenario_case_when.rb",
#                :script_path => "./scenario/scenario_while.rb",
#                :script_path => "./scenario/scenario_text.rb",
#                :script_path => "./scenario/scenario_image_tiles_container.rb",
#                :script_path => "./scenario/scenario_layout.rb",
#                :script_path => "./scenario/scenario_scope.rb",
#                :script_path => "./scenario/scenario_change_script.rb",
#                :script_path => "./scenario/scenario_check.rb",
                :script_path => "./scenario/scenario_collision.rb",
                :id => :default_rendertarget_container
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