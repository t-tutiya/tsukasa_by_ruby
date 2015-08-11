#! ruby -E utf-8

###############################################################################
#TSUKASA for DXRuby α１
#汎用ゲームエンジン「司（TSUKASA）」 for DXRuby
#
#Copyright (c) <2013-2015> <tsukasa TSUCHIYA>
#
#This software is provided 'as-is', without any express or implied
#warranty. In no event will the authors be held liable for any damages
#arising from the use of this software.
#
#Permission is granted to anyone to use this software for any purpose,
#including commercial applications, and to alter it and redistribute it
#freely, subject to the following restrictions:
#
#   1. The origin of this software must not be misrepresented; you must not
#   claim that you wrote the original software. If you use this software
#   in a product, an acknowledgment in the product documentation would be
#   appreciated but is not required.
#
#   2. Altered source versions must be plainly marked as such, and must not be
#   misrepresented as being the original software.
#
#   3. This notice may not be removed or altered from any source
#   distribution.
#
#[The zlib/libpng License http://opensource.org/licenses/Zlib]
###############################################################################

#ボタン押下による範囲指定シナリオ分岐ギミックのサンプル
#現状まだ正常に動作していない

create :ButtonControl, 
        :x_pos => 150, 
        :y_pos => 150, 
        :width => 256,
        :height => 256,
        :id=>:button1 do
  image :file_path=>"./sozai/button_normal.png", 
        :id=>:normal
  image :file_path=>"./sozai/button_over.png", 
        :id=>:over, :visible => false
  image :file_path=>"./sozai/button_key_down.png", 
        :id=>:key_down, :visible => false
  on_mouse_over do
    set target: :normal, visible: false
    set target: :over,   visible: true
    set target: :key_down, visible: false
  end
  on_mouse_out do
    set target: :over,   visible: false
    set target: :normal, visible: true
    set target: :key_down, visible: false
  end
  on_key_down do
    set target: :over,   visible: false
    set target: :normal, visible: false
    set target: :key_down, visible: true
  end
  on_key_up do
    set target: :key_down, visible: false
    set target: :normal, visible: false
    set target: :over,   visible: true
    _SET_DATA_ key: :flag, val: true
  end
end

about do
  _CHECK_ [:not_nil], key: :flag, keep: true do
    _SET_DATA_ key: :scenario, val: 1
#    flash interrupt: true
    pp "ok"
    _BREAK_
    #↓これは当然実行されない
    #_BREAK_ target: :default_char_container, interrupt: true
  end
  text "スクリプト１■■■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  pause
  _SET_DATA_ key: :scenario, val: 2
end

flash

_CHECK_ [:equal], key: :scenario, val: 1 do
  _INCLUDE_ "./scenario/scenario_change_script_3.rb"
end

_CHECK_ [:equal], key: :scenario, val: 2 do
  _INCLUDE_ "./scenario/scenario_change_script_2.rb"
end

text "インクルードしたスクリプト終了後処理はここに移ります"
