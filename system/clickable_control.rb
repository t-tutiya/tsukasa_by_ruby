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
  impl_define :on_mouse_over,   [:block]
  impl_define :on_mouse_out,    [:block]
  impl_define :on_key_down,     [:block]
  impl_define :on_key_down_out, [:block]
  impl_define :on_key_up,       [:block]
  impl_define :on_key_up_out,   [:block]
end

#クリックイベントが発生するコントロールの基底クラス
#TODO：将来的にはSpriteクラスを使い、任意形状でカーソルとの当たり判定が出来るようにする
class ClickableControl < Control
  include Drawable

  def initialize(options, inner_options, root_control)
    @child_controls_draw_to_entity = false
    @over = false
    @out = true

    super
  end

  def update()
    #マウスカーソル座標を取得
    @x = Input.mouse_pos_x
    @y = Input.mouse_pos_y

    super
  end

  def command_on_mouse_over(options, inner_options)
    #カーソルが指定範囲の中にある場合
    if  @x_pos < @x  and @x < @x_pos + @width and
        @y_pos < @y  and @y < @y_pos + @height
      #前フレームでイベントが実行されていないなら実行
      eval_block(options, inner_options, inner_options[:block]) unless @over
      @over = true
    else
      @over = false
    end

    return :continue, [:on_mouse_over, options, inner_options]
  end
  
  def command_on_mouse_out(options, inner_options)
    #カーソルが指定範囲の外にある場合
    unless  @x_pos < @x  and @x < @x_pos + @width and
            @y_pos < @y  and @y < @y_pos + @height
      #前フレームでイベントが実行されていないなら実行
      eval_block(options, inner_options, inner_options[:block]) unless @out
      @out = true
    else
      @out = false
    end

    return :continue, [:on_mouse_out, options, inner_options]
  end

  def command_on_key_down(options, inner_options)
    #マウスボタンが押下された場合
    if  Input.mouse_push?( M_LBUTTON ) and
        @x_pos < @x  and @x < @x_pos + @width and
        @y_pos < @y  and @y < @y_pos + @height

      eval_block(options, inner_options, inner_options[:block])
    end

    return :continue, [:on_key_down, options, inner_options]
  end

  def command_on_key_down_out(options, inner_options)
    #マウスボタンが範囲外で押下された場合
    if  Input.mouse_push?( M_LBUTTON ) and
        !(@x_pos < @x  and @x < @x_pos + @width and
          @y_pos < @y  and @y < @y_pos + @height)

      eval_block(options, inner_options, inner_options[:block])
    end

    return :continue, [:on_key_down_out, options, inner_options]
  end

  def command_on_key_up(options, inner_options)
    #マウスボタン押下が解除された場合
    if  Input.mouse_release?( M_LBUTTON ) and
        @x_pos < @x  and @x < @x_pos + @width and
        @y_pos < @y  and @y < @y_pos + @height

        eval_block(options, inner_options, inner_options[:block])
    end

    return :continue, [:on_key_up, options, inner_options]
  end

  def command_on_key_up_out(options, inner_options)
    #マウスボタン押下が範囲外で解除された場合
    if  Input.mouse_release?( M_LBUTTON ) and
      !(@x_pos < @x  and @x < @x_pos + @width and
        @y_pos < @y  and @y < @y_pos + @height)

        eval_block(options, inner_options, inner_options[:block])
    end

    return :continue, [:on_key_up_out, options, inner_options]
  end
end
