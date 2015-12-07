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

module Layoutable

  attr_accessor  :x
  attr_accessor  :y

  attr_accessor  :offset_x
  attr_accessor  :offset_y

  attr_accessor  :visible

  attr_accessor  :float_mode
  attr_accessor  :align_y

  attr_accessor  :width
  attr_accessor  :height

  attr_accessor  :real_width
  attr_accessor  :real_height

  def initialize(options, inner_options, root_control)
    @x = options[:x] || 0 #描画Ｘ座標
    @y = options[:y] || 0 #描画Ｙ座標

    @offset_x = options[:offset_x] || 0 #描画オフセットＸ座標
    @offset_y = options[:offset_y] || 0 #描画オフセットＹ座標

    #可視フラグ（省略時はtrue）
    @visible = options[:visible] == false ? false : true

    #回り込み指定（省略時は:none）
    @float_mode = options[:float_mode] || :none
    @align_y = options[:align_y] || :none

    @real_width = @width  = options[:width] ? options[:width] : 0
    @real_height = @height = options[:height] ? options[:height] : 0

    super
  end

  #描画
  def render(offset_x, offset_y, target, parent)
    return 0, 0 unless @visible

    #次フレームのクリッカブル判定に使うマウスカーソル座標を取得
    @mouse_pos_x = parent[:mouse_pos_x]
    @mouse_pos_y = parent[:mouse_pos_y]

    #下位コントロールを上位ターゲットに直接描画
    super(offset_x, offset_y, target, 
          { :width => @width, 
            :height => @height,
            :mouse_pos_x => @mouse_pos_x - @x,
            :mouse_pos_y => @mouse_pos_y - @y
          })

    #連結指定チェック
    case @float_mode
    #右連結
    when :left
      dx = @width
      dy = @y
    #下連結
    when :bottom
      dx = @x
      dy = @height
    #連結解除
    when :none
      dx = 0
      dy = 0
    else
      pp @float_mode
      raise
    end

    return dx, dy
  end
end
