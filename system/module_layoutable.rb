#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver1.0(2015/12/24)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
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

  #座標
  attr_accessor  :x
  attr_accessor  :y

  #オフセット座標
  attr_accessor  :offset_x
  attr_accessor  :offset_y

  #可視フラグ
  attr_accessor  :visible

  #次のコントロールの接続方向指定
  attr_accessor  :float_x
  attr_accessor  :float_y

  #寄せ指定
  attr_accessor  :align_y

  #サイズ
  attr_accessor  :width
  attr_accessor  :height

  #実サイズ（現状ではtext_page_controlのみで使用）
  attr_accessor  :real_width
  attr_accessor  :real_height

  def initialize(options, yield_block_stack, root_control, &block)
    @x = options[:x] || 0 #描画Ｘ座標
    @y = options[:y] || 0 #描画Ｙ座標

    @offset_x = options[:offset_x] || 0 #描画オフセットＸ座標
    @offset_y = options[:offset_y] || 0 #描画オフセットＹ座標

    @real_width = @width  = options[:width] || 0 #幅
    @real_height = @height = options[:height] || 0 #高さ

    #可視フラグ（省略時はtrue）
    @visible = (options[:visible] != false)

    #次コントロールの接続方向指定
    @float_x = options[:float_x]
    @float_y = options[:float_y]

    #下寄せ指定
    @align_y = options[:align_y]

    super
  end

  #描画
  def render(offset_x, offset_y, target, 
              parent_control_width, 
              parent_control_height, 
              mouse_pos_x,
              mouse_pos_y )
    #可視でなければ戻る
    return 0, 0 unless @visible

    dx, dy = check_align(parent_control_width, parent_control_height)

    offset_x += @x + @offset_x + dx
    offset_y += @y + @offset_y + dy

    mouse_pos_x -= @x
    mouse_pos_y -= @y

    #下位コントロール巡回
    @control_list.each do |child_control|
      #下位コントロールを上位ターゲットに直接描画
      child_dx, child_dy = child_control.render(offset_x, 
                                                offset_y, 
                                                target, 
                                                @width , 
                                                @height , 
                                                mouse_pos_x,
                                                mouse_pos_y )
      #次のコントロールの描画座標原点を設定する
      offset_x += child_dx
      offset_y += child_dy
      #マウス座標のオフセットを更新する
      mouse_pos_x -= child_dx
      mouse_pos_y -= child_dy
    end

    return check_float
  end
  
  def check_align(width, height)
    offest_x = offset_y = 0
    #下揃えを考慮
    case @align_y
    when :bottom 
      offset_y = height - @height
    end
    return offest_x, offset_y
  end
  
  def check_float
    #連結指定チェック
    case @float_x
    when nil
      dx = 0
    #右連結
    when :left
      dx = @width
    #下連結
    when :bottom
      dx = @x
    end

    #連結指定チェック
    case @float_y
    when nil
      dy = 0
    #右連結
    when :left
      dy = @y
    #下連結
    when :bottom
      dy = @height
    end

    return dx, dy
  end
end

