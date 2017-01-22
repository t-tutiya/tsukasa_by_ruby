#! ruby -E utf-8

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

require_relative './Control.rb'

module Tsukasa

module Helper

class Layoutable < Control
  #座標
  attr_accessor  :x
  attr_accessor  :y

  #オフセット座標
  attr_accessor  :offset_x
  attr_accessor  :offset_y

  #次のコントロールの接続方向指定
  attr_accessor  :float_x
  attr_accessor  :float_y

  #寄せ指定
  attr_accessor  :align_x
  attr_accessor  :align_y

  #サイズ
  attr_accessor  :width
  attr_accessor  :height

  def initialize(system, options, &block)
    @x = options[:x] || 0 #描画Ｘ座標
    @y = options[:y] || 0 #描画Ｙ座標

    @offset_x = options[:offset_x] || 0 #描画オフセットＸ座標
    @offset_y = options[:offset_y] || 0 #描画オフセットＹ座標

    @width = options[:width] || 1 #幅
    @height = options[:height] || 1 #高さ

    #次コントロールの接続方向指定
    @float_x = options[:float_x]
    @float_y = options[:float_y]

    #下寄せ指定
    @align_x = options[:align_x]
    @align_y = options[:align_y]

    super
  end

  def update(mouse_pos_x, mouse_pos_y, index)
    super(mouse_pos_x - @x - @offset_x, 
          mouse_pos_y - @y - @offset_y,
          index)
    return check_float
  end

  #Ｘ方向のセンタリング補正
  def check_align_x()
    case @align_x
    when nil
      offset_x = 0
    when :right 
      offset_x = @parent_control.width - @width
    when :center 
      offset_x = @parent_control.width/2 - @width/2
    else
      raise
    end

    return offset_x
  end

  #Ｙ方向のセンタリング補正
  def check_align_y()
    case @align_y
    when nil
      offset_y = 0
    when :bottom 
      offset_y = @parent_control.height - @height
    when :center 
      offset_y = @parent_control.height/2 - @height/2
    else
      raise
    end

    return offset_y
  end

  def check_float
    #連結指定チェック
    case @float_x
    when nil
      dx = 0
    #右連結
    when :left
      dx = @width + @offset_x + @x
    else
      raise
    end

    #連結指定チェック
    case @float_y
    when nil
      dy = 0
    #下連結
    when :bottom
      dy = @height + @offset_y + @y
    else
      raise
    end

    return dx, dy
  end
end

end

end