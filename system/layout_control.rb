#! ruby -E utf-8

require 'dxruby'

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

class LayoutControl < Control
  include Layoutable
  include Clickable

  #描画
  def render(offset_x, offset_y, target, parent_size)
    return offset_x, offset_y unless @visible

    x = offset_x + @x + @offset_x
    y = offset_y + @y + @offset_y

    if @align_y == :bottom 
      y += parent_size[:height] - @height
    end

    dx, dy =  super(x, y, target, parent_size)
    return dx + offset_x, dy + offset_y
  end

  def siriarize(options = {})

    options.update({
      :x  => @x,
      :y => @y,

      :offset_x => @offset_x,
      :offset_y => @offset_y,

      :visible => @visible,

      :float_mode => @float_mode,
      :align_y => @align_y,

      :real_width => @real_width,
      :real_height => @real_height,
    })

    return super(options)
  end

end