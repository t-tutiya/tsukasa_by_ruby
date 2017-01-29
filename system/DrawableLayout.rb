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

require_relative './Drawable.rb'

module Tsukasa

class DrawableLayout < Control
  include Drawable
  #Ｘ幅
  def width=(arg)
    @width = arg
    @update_flag = true
  end

  #Ｙ幅
  def height=(arg)
    @height = arg
    @update_flag = true
  end

  def relative_x
    @entity.ox
  end
  def relative_x=(arg)
    @entity.ox = arg
  end
  def relative_y
    @entity.oy
  end
  def relative_y=(arg)
    @entity.oy = arg
  end

  #アップデート時の背景色
  attr_reader  :bgcolor 
  def bgcolor=(arg)
    @entity.bgcolor = @bgcolor = arg
    @entity.update
  end
  
  def initialize(system, width:, height:, bgcolor: [0,0,0,0], **options, &block)
  
    super

    @bgcolor = bgcolor
    #保持オブジェクトの初期化
    @entity = DXRuby::RenderTarget.new(width, height, @bgcolor)

    self.width = width
    self.height = height

    @update_flag = false
  end
  
  def render(offset_x, offset_y, target)
    if @update_flag
      @entity.resize(@width, @height)
      @entity.update
      @update_flag = false
    end

    super
  end

  def dispose()
    @entity.dispose if @entity
    super
  end

  #DrawableLayout上に直線を引く
  def _LINE_(x1:, y1:, x2:, y2:, color:, z: nil)
    @entity.draw_line(x1, y1, x2, y2, color, z)
  end

  #DrawableLayout上に矩形を描く
  def _BOX_(x1:, y1:, x2:, y2:, color:, fill: false, z: nil)
    if fill
      @entity.draw_box_fill(x1, y1, x2, y2, color, z)
    else
      @entity.draw_box(x1, y1, x2, y2, color, z)
    end
  end

  #DrawableLayout上に円を描く
  def _CIRCLE_(x:, y:, r:, color:, fill: false)
    if fill
      @entity.draw_circle_fill(x, y, r, color, z)
    else
      @entity.draw_circle(x, y, r, color, z)
    end
  end

  #DrawableLayout上に文字を描く
  def _TEXT_(_ARGUMENT_: "", x: 0, y: 0, size: 24, font_name: "", weight: 4, italic: false, option: {}, color: [0, 0, 0, 0])
    option[:color] = color

    @entity.draw_font_ex(x, y, _ARGUMENT_, 
      DXRuby::Font.new(size, font_name, {weight: weight*100, italic: italic}),
      option)
  end
end

end