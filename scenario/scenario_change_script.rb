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

_CREATE_ :LayoutControl, 
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
    set :normal, visible: false
    set :over,   visible: true
    set :key_down, visible: false
  end
  on_mouse_out do
    set :over,   visible: false
    set :normal, visible: true
    set :key_down, visible: false
  end
  on_key_down do
    set :over,   visible: false
    set :normal, visible: false
    set :key_down, visible: true
  end
  on_key_up do
    set :key_down, visible: false
    set :normal, visible: false
    set :over,   visible: true
    _SET_ :user_data, flag: true
  end
end

about do
  _CHECK_ [:not_nil], key: :flag, keep: true do
    _SET_ :user_data, scenario: 1
    #↓ここがもう少し簡潔に表現できると良い
    _SEND_ :default_text_page_control0, interrupt: true do
      _BREAK_
    end
    _BREAK_
  end
  text "スクリプト１－Ａ■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  pause
  flush
  text "スクリプト１－Ｂ■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  pause
  _SET_ :user_data, scenario: 2
end

#TODO;ここでフレームを送らない場合、次のスクリプトファイルが:default_text_page_control0に読み込まれた後で_BREAK_が機能してしまう。どうにかならんかなーこれ
_END_FRAME_

flush

_CHECK_ [:equal], key: :scenario, val: 1 do
  _INCLUDE_ "./scenario/scenario_change_script_3.rb"
end

_CHECK_ [:equal], key: :scenario, val: 2 do
  _INCLUDE_ "./scenario/scenario_change_script_2.rb"
end

text "インクルードしたスクリプト終了後処理はここに移ります"

pause