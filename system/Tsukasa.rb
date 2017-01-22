#! ruby -E utf-8
# coding: utf-8

#$VERBOSE = true

###############################################################################
#TSUKASA for DXRuby ver2.2(2017/1/28)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2017> <tsukasa TSUCHIYA>
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

$dxruby_no_include = true #DXRubyがグローバル空間にincludeされるのを抑制する
require 'dxruby'

#ベースコントロール
require_relative './Control.rb'

#コントロール群

#レイアウトコントロール
require_relative './Layout.rb'
#描画実体を持つレイアウトコントロール
require_relative './DrawableLayout.rb'
#衝突判定を持つレイアウトコントロール
require_relative './ClickableLayout.rb'
#画像コントロール
require_relative './Image.rb'
#SE/BGMコントロール
require_relative './Sound.rb'
#キー入力コントロール
require_relative './Input.rb'
#ウィンドウコントロール
require_relative './Window.rb'

