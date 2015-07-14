#! ruby -E utf-8

require 'dxruby'
require_relative './script_compiler.rb'
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

#コマンド宣言
class ScriptCompiler
  impl_define :on_mouse_over, [:block]
  impl_define :on_mouse_out,  [:block]
  impl_define :on_key_down,   [:block]
  impl_define :on_key_up,     [:block]
end

#クリックイベントが発生するコントロールの基底クラス
#TODO：将来的にはSpriteクラスを使い、任意形状でカーソルとの当たり判定が出来るようにする
class ClickableControl < Control
  include Drawable

  def initialize(options, inner_options, root_control)
    @child_controls_draw_to_entity = false
    @over_status = :out
    @key_down_status = :up

    super
  end

  def command_on_mouse_over(options, inner_options)
    #マウスカーソル座標を取得
    x = Input.mouse_pos_x
    y = Input.mouse_pos_y

    if  @over_status == :out and
        @x_pos < x  and x < @x_pos + @width and
        @y_pos < y  and y < @y_pos + @height

      @over_status = :over
      eval_block(options, inner_options, inner_options[:block])
    end

    return :continue, [:on_mouse_over, options, inner_options]
  end
  
  def command_on_mouse_out(options, inner_options)
    #マウスカーソル座標を取得
    x = Input.mouse_pos_x
    y = Input.mouse_pos_y

    if  @over_status == :over and
      !(@x_pos < x  and x < @x_pos + @width and
        @y_pos < y  and y < @y_pos + @height)

      @over_status = :out
      eval_block(options, inner_options, inner_options[:block])
    end

    return :continue, [:on_mouse_out, options, inner_options]
  end

  def command_on_key_down(options, inner_options)

    #マウスボタン押下された場合
    if  @over_status == :over and @key_down_status == :up and
        Input.mouse_push?( M_LBUTTON )

        @key_down_status = :down
        eval_block(options, inner_options, inner_options[:block])
    end

    return :continue, [:on_key_down, options, inner_options]
  end

  def command_on_key_up(options, inner_options)

    #マウスボタン押下が解除された場合
    if  @over_status == :over and  @key_down_status == :down and
        Input.mouse_release?( M_LBUTTON )

        @key_down_status = :up
        eval_block(options, inner_options, inner_options[:block])
    end

    return :continue, [:on_key_up, options, inner_options]
  end
end
