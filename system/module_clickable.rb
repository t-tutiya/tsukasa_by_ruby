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
  impl_define :on_mouse_over
  impl_define :on_mouse_out
  impl_define :on_key_down
  impl_define :on_key_down_out
  impl_define :on_key_up
  impl_define :on_key_up_out
end

#クリックイベントが発生するコントロールの基底クラス
#TODO：将来的にはSpriteクラスを使い、任意形状でカーソルとの当たり判定が出来るようにする
module Clickable
  def initialize(options, inner_options, root_control)
    @x_pos = options[:x_pos] || 0 #描画Ｘ座標
    @y_pos = options[:y_pos] || 0 #描画Ｙ座標

    @width  = options[:width]  || 0 #横幅
    @height = options[:height] || 0 #縦幅

    @collision_sprite = Sprite.new
    if options[:collision]
      @collision_sprite.collision = options[:collision]
    else
      @collision_sprite.collision = [0, 0, @width-1, @height-1]
    end

    @mouse_sprite = Sprite.new
    @mouse_sprite.collision = [0, 0]

    @child_controls_draw_to_entity = false
    @over = false
    @out = true

    super
  end

  def update()
    @on_mouse_over  = false
    @on_mouse_out   = false
    @on_key_down    = false
    @on_key_down_out= false
    @on_key_up      = false
    @on_key_up_out  = false

    #マウスカーソル座標を取得
    @x = Input.mouse_pos_x
    @y = Input.mouse_pos_y

    #描画範囲内かどうか
    @collision_sprite.x, @collision_sprite.y = @x_pos, @y_pos
    @mouse_sprite.x, @mouse_sprite.y = @x, @y
    if (@mouse_sprite === @collision_sprite)
      #イベント起動済みフラグクリア
      @out = false

      #イベント起動前であれば起動し、クリアフラグを立てる
      @on_mouse_over = true unless @over
      @over = true

      #キー押下チェック
      if Input.mouse_push?( M_LBUTTON )
        @on_key_down = true
      end

      #キー解除チェック
      if Input.mouse_release?( M_LBUTTON )
        @on_key_up = true
      end
    else
      #イベント起動済みフラグクリア
      @over = false

      #イベント起動前であれば起動し、クリアフラグを立てる
      @on_mouse_out = true unless @out
      @out = true

      #キー押下チェック
      if Input.mouse_push?( M_LBUTTON )
        @on_key_down_out = true
      end

      #キー解除チェック
      if Input.mouse_release?( M_LBUTTON )
        @on_key_up_out = true
      end
    end

    super
  end

  def command_on_mouse_over(options, inner_options)
    #カーソルが指定範囲に侵入した場合
    if @on_mouse_over
      eval_block(options, inner_options[:block_stack], &inner_options[:block])
    end
    push_command_to_next_frame(:on_mouse_over, options, inner_options)
  end
  
  def command_on_mouse_out(options, inner_options)
    #カーソルが指定範囲の外に移動した場合
    if @on_mouse_out
      eval_block(options, inner_options[:block_stack], &inner_options[:block])
    end
    push_command_to_next_frame(:on_mouse_out, options, inner_options)
  end

  def command_on_key_down(options, inner_options)
    #マウスボタンが押下された場合
    if @on_key_down
      eval_block(options, inner_options[:block_stack], &inner_options[:block])
    end
    push_command_to_next_frame(:on_key_down, options, inner_options)
  end

  def command_on_key_down_out(options, inner_options)
    #マウスボタンが範囲外で押下された場合
    if @on_key_down_out
      eval_block(options, inner_options[:block_stack], &inner_options[:block])
    end
    push_command_to_next_frame(:on_key_down_out, options, inner_options)
  end

  def command_on_key_up(options, inner_options)
    #マウスボタン押下が解除された場合
    if @on_key_up
      eval_block(options, inner_options[:block_stack], &inner_options[:block])
    end
    push_command_to_next_frame(:on_key_up, options, inner_options)
  end

  def command_on_key_up_out(options, inner_options)
    #マウスボタン押下が範囲外で解除された場合
    if @on_key_up_out
      eval_block(options, inner_options[:block_stack], &inner_options[:block])
    end
    push_command_to_next_frame(:on_key_up_out, options, inner_options)
  end
end
