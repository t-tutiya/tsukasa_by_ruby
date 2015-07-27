#! ruby -E utf-8
# coding: utf-8

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

require 'dxruby'
require_relative './module_movable.rb'
require_relative './module_drawable.rb'
require_relative './module_clickable.rb'

require_relative './control_container.rb'

require_relative './image_control.rb'
require_relative './image_tiles_container.rb'

require_relative './button_control.rb'
require_relative './se_control.rb'

require_relative './rendertarget_container.rb'
require_relative './layout_control.rb'
require_relative './text_page_control.rb'
#require_relative './char_container.rb'
require_relative './log_container.rb'

require_relative './VariableTextLayer.rb'

require_relative './script_compiler.rb'

#TODO：モジュールであるべきか？
class Tsukasa < Control

  def initialize(options, inner_options = {})
    options[:default_script_path] = "./system/default_script.rb"
    super
  end
end
