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

procedure :log,
  impl: <<"EOS"
    [[:create, {:create => :ImageControl,
      :file_path => options[:file_path], 
      :x_pos =>     0, 
      :y_pos =>     0, 
      :id =>       :test}]]
EOS

#log file_path: "./sozai/bg_sample.png"


create :ImageControl ,
       file_path: "./sozai/bg_sample.png", x_po: 0, y_pos: 0, 
       id: :BG do
  move offset_x: 300,offset_y: 0, frame: 60, offset: true
  transition_fade frame: 200,
                  count: 0,
                  start: 0,
                  last: 255
  wait_command :move_line
  move offset_x: -100, offset_y: 0, frame: 60, offset: true
end

=begin
create :LayoutContainer,
  x_pos: 0,
  y_pos: 0,
  width: 300,
  height: 300,
  id: :main_text_layer do

  #ボタンコントロール
  create :ButtonControl, x_pos: 0, y_pos: 0, id: :button2 do
          button_create :ImageControl, 
                 :file_path=>"./sozai/button_normal.png", 
                 :id=>:normal
          button_create :ImageControl, 
                :file_path=>"./sozai/button_over.png", 
                :id=>:over
          button_create :ImageControl, 
                :file_path=>"./sozai/button_key_down.png", 
                :id=>:key_down
          button_create :ImageControl, 
                :file_path=>"./sozai/button_key_up.png", 
                :id=>:key_up do
  #                flag :key=>1, :data=>true
                end
          button_create :ImageControl, 
                :file_path=>"./sozai/button_out.png", 
                :id=>:out
  end
end

#ボタンコントロール
create :ButtonControl, :x_pos => 0, :y_pos => 0, :id=>:button1 do
        button_create :ImageControl, 
               :file_path=>"./sozai/button_normal.png", 
               :id=>:normal
        button_create :ImageControl, 
              :file_path=>"./sozai/button_over.png", 
              :id=>:over
        button_create :ImageControl, 
              :file_path=>"./sozai/button_key_down.png", 
              :id=>:key_down
        button_create :ImageControl, 
              :file_path=>"./sozai/button_key_up.png", 
              :id=>:key_up do
                flag :key=>1, :data=>2
                flag :key=>2, :data=>true
              end
        button_create :ImageControl, 
              :file_path=>"./sozai/button_out.png", 
              :id=>:out
end
=end

#ボタンコントロール
create :ButtonControl, :x_pos => 0, :y_pos => 0, :id=>:button1 do
        create :ImageControl, 
               :file_path=>"./sozai/button_normal.png", 
               :id=>:normal
        create :ImageControl, 
              :file_path=>"./sozai/button_over.png", 
              :id=>:over,
              :visible => false
        create :ImageControl, 
              :file_path=>"./sozai/button_key_down.png", 
              :id=>:key_down,
              :visible => false
        create :ImageControl, 
              :file_path=>"./sozai/button_key_up.png", 
              :id=>:key_up,
              :visible => false
        create :ImageControl, 
              :file_path=>"./sozai/button_out.png", 
              :id=>:out,
              :visible => false

        event :key_up do
          flag :key=>3, :data=>2
          flag :key=>4, :data=>true
        end
        normal
end

event :key_up do
  next_frame
  next_frame
  next_frame
  next_frame
end

event :key_down do
  next_frame
end

next_frame

=begin
WHILE "true", target_control: :button1 do
  move_line x: 300, y: 0,   count:0, frame: 60, start_x: 0,   start_y: 0
  move_line x: 300, y: 300, count:0, frame: 60, start_x: 300, start_y: 0
  move_line x: 0,   y: 300, count:0, frame: 60, start_x: 300, start_y: 300
  move_line x: 0,   y: 0,   count:0, frame: 60, start_x: 0,   start_y: 300
end
=end
=begin
update :key_up, visible: true
update :normal, visible: false
=end








create :LayoutContainer,
  x_pos: 128,
  y_pos: 528,
  width: 1024,
  height: 600,
  id: :main_text_layer do
    #メッセージウィンドウ
    create :CharContainer, 
      id: :default_text_layer,
      font_config: { :size => 32, 
                     :face => "ＭＳＰ ゴシック"},
      style_config: { :wait_frame => 2,} do
      char_renderer do
      	transition_fade frame: 30,
          count: 0,
          start: 0,
          last: 255
        sleep_frame
        transition_fade frame: 60,
          count: 0,
          start: 255,
          skip: 255,
          last:128
      end
    end
end

next_frame

#wait_flag "3"
#next_frame
#stop

text "てｓｔ"

#next_scenario "./scenario/scenario04b.rb"

#next_frame

=begin
text "ＡＤＶエンジン「司（Tsukasa）」のα１バージョンを"
line_feed
text "ひとまず公開します。testA"
pause
flash
=end
#pause #これがあるとスクリプトファイルが二回読み込まれる
#pause #これがあるとスクリプトファイルが二回読み込まれる

IF "false" do
  THEN do
    EVAL "pp 'test 1_a'"
  end
  ELSE do
    EVAL "pp 'test 1_b'"
    #text "test"
  end
end

IF "false" do
  THEN do
    EVAL "pp 'test 1_c'"
  end
  ELSE do
    EVAL "pp 'test 1_d'"
    #text "test"
  end
end
#wait_flag 1
#pause

IF "false" do
  THEN do
    EVAL "pp 'test 2_a'"
  end
  ELSE do
    EVAL "pp 'test 2_b'"
    #text "test"
  end
end


EVAL "pp 'YESYES2'"

IF "@@global_flag[:user_1] == 1" do
  THEN do
    EVAL "pp 'YES'"
    next_scenario "./scenario/scenario04b.rb"
  end
  ELSE do
    EVAL "pp 'NO'"
    next_scenario "./scenario/scenario04c.rb"
  end
end

pause
