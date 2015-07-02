#! ruby -E utf-8

require 'dxruby'
require_relative './module_movable.rb'
require_relative './module_drawable.rb'
require_relative './control_container.rb'

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

class LayoutContainer < Control
  include Movable #移動関連モジュール
  include Drawable #描画関連モジュール

  def initialize(options, system_options)
    options[:child_controls_draw_to_entity] = true
    super

    #保持オブジェクトの初期化
    @entity = RenderTarget.new( options[:width], 
                                            options[:height], 
                                            [0, 0, 0, 0])

    @width  = @entity.width
    @height = @entity.height

  end

  def dispose()
    #pp self.class
    #pp "dispose"
    @entity.dispose
    super
  end

end
