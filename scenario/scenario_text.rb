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

#右ＣＴＲＬによるテキストスキップ機構（未完成）
_CHECK_ [:key_down] , key_code: K_RCONTROL, keep: true do
  _SEND_ :default_text_page_control0 , interrupt: true do
    _SEND_ :all , interrupt: true do
      _SET_ :_MODE_STATUS_, skip: true
#      _SET_ :_MODE_STATUS_, wake: :true
    end
   end
end

text "★★★★★テスト中"

_SEND_ :default_text_page_control0 do
  _SET_  size: 64
  _SET_  line_height: 64
end

rubi "●", text: "■■■■■"
rubi "◆", text: "test"

text "●●●●●"
line_feed

text "■■■■■■"

#pause icon: :page_icon_func
line_feed
text "■■■■■■■■■■■"
lp
text "■■■■■■■■■■■"

_SEND_ :default_text_page_control0 do
  _SET_  size: 32
  _SET_  line_height: 32
end

page_pause

#render_to_image
#backlay

text "■■■■■■■■■■■■■■■■■■■■■■"
lp
line_feed
text "■■■■■■■■■■■"
lp
text "■■■■■■■■■■■"
lp
line_feed
text "■■■■■■■■■■■"
lp
text "■■■■■■■■■■■"
page_pause

text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
page_pause

text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
page_pause

text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
page_pause

text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
line_feed
text "■■■■■■■■■■■■■■■■■■■■■■"
page_pause

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