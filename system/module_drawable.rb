#! ruby -E utf-8

require 'dxruby'
require_relative './script_compiler.rb'

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

#モンキーパッチ
module Window
  #外枠のみの四角形を描画する
  def self.draw_box_line(x1, y1, x2, y2, color = [255,255,255], z = 0)
    Window.draw_line( x1, y1, x2, y1, [255,255,255], z)
    Window.draw_line( x2, y1, x2, y2, [255,255,255], z)
    Window.draw_line( x1, y1, x1, y2, [255,255,255], z)
    Window.draw_line( x1, y2, x2, y2, [255,255,255], z)
  end
end

class RenderTarget
  #外枠のみの四角形を描画する
  def draw_box_line(x1, y1, x2, y2, color = [255,255,255], z = 0)
    draw_line( x1, y1, x2, y1, [255,255,255], z)
    draw_line( x2, y1, x2, y2, [255,255,255], z)
    draw_line( x1, y1, x1, y2, [255,255,255], z)
    draw_line( x1, y2, x2, y2, [255,255,255], z)
  end
end

module Drawable
  @@_DRAWBABL_DEBUG_ = true

  def initialize(options, inner_options, root_control)
    @x_pos = options[:x_pos] || 0 #描画Ｘ座標
    @y_pos = options[:y_pos] || 0 #描画Ｙ座標

    #可視フラグ（省略時はtrue）
    @visible = options[:visible] == false ? false : true

    #子コントロールを自エンティティに描画するかどうか
    @child_controls_draw_to_entity = options[:child_controls_draw_to_entity] || false

    if options[:draw_option]
      @draw_option = options[:draw_option]
    else
      #描画オプション
      @draw_option = {
                      :z => options[:index] || 0 #重ね合わせ順序
                      } 
    end

    #回り込み指定（省略時は:none）
    @float_mode = options[:float_mode] || :none
    @align_y = options[:align_y] || :none

    #TODO：いらない気がする
    @width  = options[:width] || 0  #横幅
    @height = options[:height] || 0 #縦幅

    super
  end

  #描画
  def render(offset_x, offset_y, target, parent_size)
    return offset_x, offset_y unless @visible

    #下位エンティティを自エンティティに描画する場合
    if @child_controls_draw_to_entity
      #下位エンティティを自エンティティに描画
      super(0, 0, @entity, {:width => @width, :height => @height})

      x_pos = offset_x + @x_pos
      y_pos = offset_y + @y_pos

      #自エンティティを上位ターゲットに描画
      target.draw_ex(x_pos, y_pos, @entity, @draw_option)
    else
      if @align_y == :bottom
        y_pos = offset_y + @y_pos + parent_size[:height] - @height
        x_pos = offset_x + @x_pos
      else
        y_pos = offset_y + @y_pos
        x_pos = offset_x + @x_pos
      end

      #エンティティを持っているなら自エンティティを上位ターゲットに描画
      target.draw_ex(x_pos, y_pos, @entity, @draw_option) if @entity
      #下位エンティティを上位ターゲットに描画
      super(offset_x + @x_pos, 
            offset_y + @y_pos, 
            target, 
            {:width => @width, :height => @height})
    end

    #デバッグ用：コントロールの外枠を描画する
    if @@_DRAWBABL_DEBUG_
      target.draw_box_line(x_pos, y_pos, x_pos + @width,  y_pos + @height)
    end

    dx = offset_x + @x_pos
    dy = offset_y + @y_pos

    #連結指定チェック
    case @float_mode
    #右連結
    when :right
      dx += @width
    #下連結
    when :bottom
      dy += @height
    #連結解除
    when :none
      dx = offset_x
      dy = offset_y
    else
      pp @float_mode
      raise
    end

    return dx, dy
  end

  #フェードインコマンド
  #count:現在カウント
  #frame:フレーム数
  #start:開始α値
  #last:終了α値
  def command_transition_fade(options, inner_options) 
    #スキップモードであれば最終値を設定し、フレーム内処理を続行する
    if @skip_mode
      @draw_option[:alpha] = options[:last]
      return
    end

    #透明度の決定
    @draw_option[:alpha] = options[:start] + 
                          (((options[:last] - options[:start]).to_f / options[:frame]) * options[:count]).to_i

    #カウントアップ
    options[:count] += 1

    #カウントが指定フレーム以下の場合
    if options[:count] <= options[:frame]
      #:transition_fadeコマンドをスタックし直す
      push_command_to_next_frame(:transition_fade, options, inner_options)
    end
  end
end