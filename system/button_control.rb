#! ruby -E utf-8

require 'dxruby'
require_relative './script_compiler.rb'
require_relative './module_movable.rb'
require_relative './module_drawable.rb'
require_relative './control_container.rb'
require_relative './image_control.rb'

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
  #ボタン制御コマンド群
  #TODO:これは無くても動いて欲しいが、現状だとscript_compilerを通す為に必要
  impl_define :normal,                    []
end

#ボタンコントロール
class ButtonControl  < Control
  include Drawable
  include Movable

  def initialize(options, inner_options, root_control)
    options[:child_controls_draw_to_entity] = false
    super

    #TODO；本来はここでnormalの初期化が必要なように思える
    @entity = nil
  end

  #ボタンのノーマル状態
  def command_normal(options, target)
    #マウスカーソル座標を取得
    x = Input.mouse_pos_x
    y = Input.mouse_pos_y

=begin
    if !@visible
      #normalを維持
      return :continue, [:normal, {}]  #コマンド探査終了
    end
=end
    #マウスが画像の範囲内に入った場合
    if @x_pos < x  and x < @x_pos + @control_list[0].width and
       @y_pos < y  and y < @y_pos + @control_list[0].height
      #描画コントロールをoverに切り替え
      send_script(:visible, {:visible => false}, {:target_id => :normal})
      send_script(:visible, {:visible => true}, {:target_id => :over})
      return :continue, [:over, {}]  #コマンド探査終了
    else
      #normalを維持
      return :continue, [:normal, {}]  #コマンド探査終了
    end
  end

  #マウスカーソルが範囲内に入っている
  def command_over(options, target)
    #マウスカーソル座標を取得
    x = Input.mouse_pos_x
    y = Input.mouse_pos_y

    #マウスが画像の範囲外に出た場合
    if !(@x_pos < x  and x < @x_pos + @control_list[0].width and
         @y_pos < y  and y < @y_pos + @control_list[0].height)
      #描画コントロールをoutに切り替え
      send_script(:visible, {:visible => false}, {:target_id => :over})
      send_script(:visible, {:visible => true}, {:target_id => :out})
      return :continue, [:out, {}]  #コマンド探査終了
    end

    #マウスボタンが押された場合
    if Input.mouse_push?( M_LBUTTON )
      #描画コントロールをkey_downに切り替え
      send_script(:visible, {:visible => false}, {:target_id => :over})
      send_script(:visible, {:visible => true}, {:target_id => :key_down})
      return :continue, [:key_down, {}]  #フレーム終了
    else
      #overを維持
      return :continue, [:over, {}]  #コマンド探査終了
    end
  end

  #ボタンが押下されている状態
  def command_key_down(options, target)
    #マウスカーソル座標を取得
    x = Input.mouse_pos_x
    y = Input.mouse_pos_y

    #マウスが画像の範囲外に出た場合
    if !(@x_pos < x  and x < @x_pos + @control_list[0].width and
         @y_pos < y  and y < @y_pos + @control_list[0].height)
      #描画コントロールをoutに切り替え
      send_script(:visible, {:visible => false}, {:target_id => :key_down})
      send_script(:visible, {:visible => true}, {:target_id => :out})
      return :continue, [:out, {}] #コマンド探査終了
    end

    #マウスボタン押下が解除された場合
    if Input.mouse_release?( M_LBUTTON )
      #描画コントロールをkey_upに切り替え
      send_script(:visible, {:visible => false}, {:target_id => :key_down})
      send_script(:visible, {:visible => true}, {:target_id => :key_up})
      #イベント実行
      return :continue, [:key_up, {}] #コマンド探査終了
    else
      #key_downを維持
      return :continue, [:key_down, {}] #コマンド探査終了
    end
  end

  #ボタンから指が離れた後の状態
  def command_key_up(options, target)
    #イベントを実行
    interrupt_command(:fire, {:fire => :key_up})

    #描画コントロールをoverに切り替え
    send_script(:visible, {:visible => false}, {:target_id => :key_up})
    send_script(:visible, {:visible => true}, {:target_id => :over})
    return :continue, [:over, {}] #コマンド探査終了
  end

  #マウスカーソルが範囲外に出た後の状態
  def command_out(options, target)
    #描画コントロールをnormalに切り替え
    send_script(:visible, {:visible => false}, {:target_id => :out})
    send_script(:visible, {:visible => true}, {:target_id => :normal})
    return :continue, [:normal, {}] #コマンド探査終了
  end
end
