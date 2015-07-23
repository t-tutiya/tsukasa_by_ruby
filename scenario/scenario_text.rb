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
create :ImageControl ,
       id: :bg,
       file_path: "./test/bg_sample.png", x_pos: 0, y_pos: 0

=begin
#標準テキストウィンドウ
#TODOデバッグ用なので各種数字は暫定
#メッセージウィンドウ
create :TextPageControl, 
  x_pos: 0,
  y_pos: 0,
  id: :default_char_container,
  font_config: { :size => 32, 
                 :fontname => "ＭＳＰ ゴシック"},
  style_config: { :wait_frame => 2,},
  char_renderer: Proc.new{
    transition_fade_with_skip frame: 15,
      count: 0,
      start: 0,
      last: 255
    wait [:command, :skip], command: :transition_fade_with_skip
    sleep_mode :sleep
    wait [:wake]
    skip_mode false
    transition_fade_with_skip frame: 60,
      count: 0,
      start: 255,
      last:128
    wait [:command, :skip], command: :transition_fade_with_skip
  } do
  set font_config: {size: 32}
end

=end
text "こんなの歪んでいる"

line_feed
text "■■■■■■■■■■■■■■■■■■■■■■■"

line_feed
text "■■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■■"
line_feed
pause
flash
=begin
text"asa）」のα１バージョンを"
line_feed
text "ひとまず"
pause
text"asa）」のα１バージョンを"
text "ひとまず"
line_feed
pause
text"公開します。testA"
pause
line_feed
text "ひとまず公開します。testA"
pause
text"asa）」のα１バージョンを"
line_feed
text "ひとまず"
=end