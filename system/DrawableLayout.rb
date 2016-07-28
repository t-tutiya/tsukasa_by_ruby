#! ruby -E utf-8

###############################################################################
#TSUKASA for DXRuby ver1.2.1(2016/5/2)
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

module Tsukasa

class DrawableLayout < Helper::Drawable
  #Ｘ幅
  def width=(arg)
    super
    @update_flag = true
  end

  #Ｙ幅
  def height=(arg)
    super
    @update_flag = true
  end

  #アップデート時の背景色
  attr_reader  :bgcolor 
  def bgcolor=(arg)
    @bgcolor = arg
    @update_flag = true
  end
  
  def initialize(options, yield_stack, root_control, parent_control, &block)
  
    super

    @bgcolor = options[:bgcolor]  || [0,0,0,0]
    #保持オブジェクトの初期化
    @entity = DXRuby::RenderTarget.new( options[:width]  || 1, 
                                options[:height] || 1, 
                                @bgcolor)

    self.width = options[:width]
    self.height = options[:height]

    @update_flag = false
  end
  
  def render(offset_x, offset_y, target)
    if @update_flag
      @entity = DXRuby::RenderTarget.new(@width, @height, @bgcolor)
      @update_flag = false
    end

    super
  end

  def dispose()
    @entity.dispose if @entity
    super
  end

  #DrawableLayout上に直線を引く
  def _LINE_(yield_stack, options)
    @entity.draw_line( 
      options[:x1], options[:y1], options[:x2], options[:y2], options[:color], options[:z])
  end

  #DrawableLayout上に矩形を描く
  def _BOX_(yield_stack, options)
    if options[:fill]
      @entity.draw_box_fill( 
        options[:x1], options[:y1], options[:x2], options[:y2], 
        options[:color], options[:z])
    else
      @entity.draw_box(
        options[:x1], options[:y1], options[:x2], options[:y2], 
        options[:color], options[:z])
    end
  end

  #DrawableLayout上に円を描く
  def _CIRCLE_(yield_stack, options)
    if options[:fill]
      @entity.draw_circle_fill(
        options[:x], options[:y], options[:r], options[:color], options[:z])
    else
      @entity.draw_circle( 
        options[:x], options[:y], options[:r], options[:color], options[:z])
    end
  end

  #DrawableLayout上に文字を描く
  def _TEXT_(yield_stack, options)
    options[:weight] = 4 unless options[:weight]
    options[:option] = {} unless options[:option]
    if options[:color]
      options[:option][:color] = options[:color]  
    else
      options[:option][:color] = [0, 0, 0, 0]
    end

    @entity.draw_font_ex(
      options[:x] || 0, options[:y] || 0,
      options[:text],
      DXRuby::Font.new( options[:size] || 24,
                options[:font_name] || "",  
                {
                  weight: options[:weight] * 100,
                  italic: options[:italic] || false
                }
              ),
      options[:option])
  end
end

end