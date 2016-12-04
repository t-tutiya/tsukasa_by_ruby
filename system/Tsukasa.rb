#! ruby -E utf-8
# coding: utf-8

#$VERBOSE = true

###############################################################################
#TSUKASA for DXRuby ver2.0(2016/8/28)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2016> <tsukasa TSUCHIYA>
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
require_relative './Image.rb'
require_relative './Layout.rb'
require_relative './DrawableLayout.rb'
require_relative './ClickableLayout.rb'
require_relative './Sound.rb'
require_relative './Char.rb'
require_relative './Data.rb'

#ウィンドウ
require_relative './Window.rb'

#複合コントロール群
require_relative './TextPage.rb'
require_relative './TileMap.rb'
require_relative './RuleShader.rb'

