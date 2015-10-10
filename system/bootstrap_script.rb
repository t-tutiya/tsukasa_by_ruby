#! ruby -E utf-8

###############################################################################
#TSUKASA for DXRuby  α１
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

#デバッグモードの設定
_SET_ :_GLOBAL_DATA_, _DEBUG_: false

#デフォルトのユーザー定義関数群
_INCLUDE_ "./system/default_script.rb"

#デバッグ用のサンプル
#_INCLUDE_ "./scenario/scenario_sound.rb"
#_INCLUDE_ "./scenario/scenario_easing.rb"
#_INCLUDE_ "./scenario/scenario_inner_function.rb"
#_INCLUDE_ "./scenario/scenario_clickable.rb"
#_INCLUDE_ "./scenario/scenario_yield.rb"
#_INCLUDE_ "./scenario/scenario_while.rb"
#_INCLUDE_ "./scenario/scenario_function.rb"
#_INCLUDE_ "./scenario/scenario_layout.rb"
#_INCLUDE_ "./scenario/scenario_scope.rb"
#_INCLUDE_ "./scenario/scenario_change_script.rb"
#_INCLUDE_ "./scenario/scenario_check.rb"
#_INCLUDE_ "./scenario/scenario_collision.rb"
#_INCLUDE_ "./scenario/scenario_ImageControl.rb"
#_INCLUDE_ "./scenario/scenario_text.rb"
#_INCLUDE_ "./scenario/scenario_label.rb"
#_INCLUDE_ "./scenario/tks_test.tks"

_INCLUDE_ "./scenario/first.tks"
