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

#_SEND_ :default_char_container do
#  _SET_ align_y: :bottom
#end
=begin
_SEND_ :default_char_container do
  _RUBI_ "●", rubi: "★★★★"
  #_SET_  font_config: {size: 64}
end
_SEND_ :default_char_container, interrupt: true do
  _SET_  style_config: {line_height: 64}
  _SET_ indent: 128
  text "◆◆◆◆"
end
=end


text "★★★★★"


_SEND_ :default_char_container do
  _RUBI_ "●", rubi: "test"
  #_SET_  font_config: {size: 64}
end

text "●●●●●"
line_feed

text "■■■■■■"

pause icon: :page_icon_func
line_feed
text "■■■■■■■■■■■"
pause icon: :line_icon_func
text "■■■■■■■■■■■"
pause
line_feed
text "■■■■■■■■■■■"
pause
text "■■■■■■■■■■■"
pause
flush

text "■■■■■■■■■■■■■■■■■■■■■■"
pause
line_feed
text "■■■■■■■■■■■"
pause
text "■■■■■■■■■■■"
pause
line_feed
text "■■■■■■■■■■■"
pause
text "■■■■■■■■■■■"
pause
flush

text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
pause
flush

text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
pause
flush

text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
pause
flush

text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
pause
flush

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