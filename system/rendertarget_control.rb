#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver1.2(2016/3/1)
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

class RenderTargetControl < Control
  include Drawable

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
  
  #枠線の太さ（初期値０）
  attr_accessor  :border
  #枠線のRGB配列（初期値[255,255,255]）
  attr_accessor  :border_color

  def initialize(options, yield_block_stack, root_control, &block)
    @bgcolor = options[:bgcolor]  || [0,0,0,0]
    #保持オブジェクトの初期化
    options[:entity] = RenderTarget.new(options[:width]  || 1, 
                                        options[:height] || 1, 
                                        @bgcolor)
    @update_flag = false

    self.border = options[:border]  || 0
    self.border_color = options[:border_color]  || [255,255,255]

    super
  end
  
  def update(offset_x, offset_y, target, 
              parent_control_width, 
              parent_control_height, 
              mouse_pos_x,
              mouse_pos_y )
    if @update_flag
      @entity = RenderTarget.new(@width, @height, @bgcolor)
      @update_flag = false
    end
    
    #枠線を引く
    if @border > 0
      width = @width - 1
      height = @height - 1
      @entity.draw_box_fill(0              , 0, 
                            width          , @border, 
                            @border_color, @z)
      @entity.draw_box_fill(width - @border, 0, 
                            width          , height        , 
                            @border_color, @z)
      @entity.draw_box_fill(0              , 0, 
                            @border        , height        , 
                            @border_color, @z)
      @entity.draw_box_fill(0              , height - @border, 
                            width          , height        , 
                            @border_color, @z)
    end
    super
  end

  def dispose()
    @entity.dispose if @entity
    super
  end

  #ツリー配下のコントロールをImageに書き出しコントロールリストの末端に追加する
  def _TO_IMAGE_(argument, options, yield_block_stack, &block)
    rt = RenderTarget.new(@width, @height)
    update( 0, 0, rt, { :width => @width, 
                        :height => @height,
                        :mouse_pos_x => @mouse_pos_x,
                        :mouse_pos_y => @mouse_pos_y})

    #拡大率が設定されている場合
    if options[:scale]
      rt2 = RenderTarget.new( options[:scale] * @width, 
                              options[:scale] * @height,)
      rt2.draw_ex(-1 * options[:scale]**2 * @width,
                  -1 * options[:scale]**2 * @height,
                  rt,
                  {:scale_x => options[:scale],
                   :scale_y => options[:scale],})
      entity  = rt2.to_image
    else
      entity  = rt.to_image
    end
    #イメージコントロールを生成する
    @command_list.unshift([:_CREATE_, 
                :ImageControl, 
               {:entity => entity,
                :z => options[:z] || Float::INFINITY, #描画順を正の無限大とする
                :visible => options[:visible] || true, #デフォルトでは可視
                :id => argument
                }, 
                yield_block_stack, block])
  end
end
