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

text "スペースキーを押すとDirectSoundの初期化します"
line_feed
text "多少時間がかかります。"
page_pause

_CREATE_ :SoundControl, file_path: "./test/bell.wav", id: :test

text "初期化が終了しました。スペースキーを押すと再生します"

page_pause

_SEND_ :test do
  play
end

text "再生中。スペースキーを押すと停止します。"

page_pause

_SEND_ :test do
  stop
end

text "停止。次は無限ループ"

page_pause

_SEND_ :test do
  _SET_ loop_count: -1
  play
end

text "無限ループ中。スペースキーを押すと停止します。"

page_pause

_SEND_ :test do
  stop
end

text "停止。次はフェードイン"

page_pause

_SEND_ :test do
  fade start: 0, last: 230, fade_ms: 960
  play
end

text "フェードインしつつ無限ループ中"
line_feed
text "スペースキーを押すとフェードアウトします"
line_feed
text "上手く動いてませんが原因不明"

page_pause

_SEND_ :test do
  #初期値は省略可
  fade last: 0, fade_ms: 960
  play
end

text "フェードアウトしつつ無限ループ中。スペースキーを押すと停止します"

page_pause

_SEND_ :test do
  stop
end

