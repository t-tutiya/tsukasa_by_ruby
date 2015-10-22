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

class RenderTargetControl < Control
  include Drawable
  include Clickable
  
  def initialize(options, inner_options, root_control)
    options[:render_target] = true unless options[:render_target] == false

    if options[:render_target]
      options[:child_controls_draw_to_entity] = true
      #保持オブジェクトの初期化
      options[:entity] = RenderTarget.new(options[:width]  || 1, 
                                          options[:height] || 1, 
                                          options[:color]  || [0,0,0,0])
    end

    super
  end

  def dispose()
    @entity.dispose if @entity
    super
  end

  #ツリー配下のコントロールをImageに書き出しコントロールリストの末端に追加する
  def command__TO_IMAGE_(options, inner_options)
    rt = RenderTarget.new(@width, @height)
    render( 0, 0, rt, {:width => @width, :height => @height})
    entity  = rt.to_image
    #イメージコントロールを生成する
    interrupt_command([:_CREATE_, 
               {:_ARGUMENT_ => :ImageControl, 
                :entity => entity,
                :z => options[:z] || Float::INFINITY, #描画順を正の無限大とする
                :id => options[:_ARGUMENT]
                }, 
                inner_options])
  end
end
