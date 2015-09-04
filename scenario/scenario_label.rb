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

#TODO：これ、動いてはいるけど元のon_key_upが上書きされているわけではない。

_SCOPE_ do
label name: "test", title: "xxxxx"
  text "スクリプト１１１１１１１１１１１１１１１１１"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  page_pause
end

_SCOPE_ do
  label 
  text "スクリプト２２２２２２２２２２２２２２２２２"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  page_pause
end

_SCOPE_ do
  label name: "test2"
  text "スクリプト３３３３３３３３３３３３３３３３３"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  page_pause
end

_SCOPE_ do
  label title: "yyyy"
  text "スクリプト４４４４４４４４４４４４４４４４４"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  page_pause
end

_SCOPE_ do
  label title: "zzzz"
  text "スクリプト５５５５５５５５５５５５５５５５５"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  page_pause
end

_SCOPE_ do
  label
  text "スクリプト６６６６６６６６６６６６６６６６６"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  page_pause
end

_SCOPE_ do
  label
  text "スクリプト７７７７７７７７７７７７７７７７７"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  page_pause
end

_SCOPE_ do
  label
  text "スクリプト８８８８８８８８８８８８８８８８８"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  page_pause
end

_SCOPE_ do
  label
  text "スクリプト９９９９９９９９９９９９９９９９９"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  page_pause
end

