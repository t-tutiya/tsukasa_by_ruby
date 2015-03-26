#! ruby -E utf-8

require 'dxruby'
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
#ボタンコントロール
class ButtonControl  < Control
  include Drawable
  include Movable

  def initialize(options)
    options[:draw_to_entity] = false
    super(options)

    @button_controls = Hash.new
    
    #TODO；ここでnormalの初期化が必要なように思える
    @entity = nil
  end

  #コントロールをリストに登録する
  def command_create(options)
    #指定されたコントロールを生成してリストに連結する
    @button_controls[options[:id]] = Module.const_get(options[:create]).new(options)
    #初期状態コントロールが生成された場合はそれをデフォルトとし、コマンドを発行する
    #TODO:多分normalが無いと落ちる
    if options[:id] == :normal
      #ストックコントロールから必要なコントロールを読み込む
      @control_list[0] = @button_controls[:normal].dup
      return false, false, [:normal, {}] #コマンド探査続行
    end
    return false #フレーム続行
  end

  #ボタンのノーマル状態
  def command_normal(options)
    #マウスカーソル座標を取得
    x = Input.mouse_pos_x
    y = Input.mouse_pos_y

    #マウスが画像の範囲内に入った場合
    if @x_pos < x  and x < @x_pos + @control_list[0].width and
       @y_pos < y  and y < @y_pos + @control_list[0].height
      #描画コントロールをoverに切り替え
      @control_list[0] = @button_controls[:over].dup
      return true, false, [:over, {}]  #コマンド探査終了
    else
      #normalを維持
      return true, false, [:normal, {}]  #コマンド探査終了
    end
  end

  #マウスカーソルが範囲内に入っている
  def command_over(options)
    #マウスカーソル座標を取得
    x = Input.mouse_pos_x
    y = Input.mouse_pos_y

    #マウスが画像の範囲外に出た場合
    if !(@x_pos < x  and x < @x_pos + @control_list[0].width and
         @y_pos < y  and y < @y_pos + @control_list[0].height)
      #描画コントロールをoutに切り替え
      @control_list[0] = @button_controls[:out].dup
      return true, false, [:out, {}]  #コマンド探査終了
    end

    #マウスボタンが押された場合
    if Input.mouse_push?( M_LBUTTON )
      #描画コントロールをkey_downに切り替え
      @control_list[0] = @button_controls[:key_down].dup
      return true, false, [:key_down, {}]  #フレーム終了
    else
      #overを維持
      return true, false, [:over, {}]  #コマンド探査終了
    end
  end

  #ボタンが押下されている状態
  def command_key_down(options)
    #マウスカーソル座標を取得
    x = Input.mouse_pos_x
    y = Input.mouse_pos_y

    #マウスが画像の範囲外に出た場合
    if !(@x_pos < x  and x < @x_pos + @control_list[0].width and
         @y_pos < y  and y < @y_pos + @control_list[0].height)
      #描画コントロールをoutに切り替え
      @control_list[0] = @button_controls[:out].dup
      return true, false, [:out, {}] #コマンド探査終了
    end

    #マウスボタン押下が解除された場合
    if Input.mouse_release?( M_LBUTTON )
      #描画コントロールをkey_upに切り替え
      @control_list[0] = @button_controls[:key_up].dup
      return true, false, [:key_up, {}] #コマンド探査終了
    else
      #key_downを維持
      return true, false, [:key_down, {}] #コマンド探査終了
    end
  end

  #ボタンから指が離れた後の状態
  def command_key_up(options)
    #描画コントロールをoverに切り替え
    @control_list[0] = @button_controls[:over].dup
    return true, false, [:over, {}] #コマンド探査終了
  end

  #マウスカーソルが範囲外に出た後の状態
  def command_out(options)
    #描画コントロールをnormalに切り替え
    @control_list[0] = @button_controls[:normal].dup
    return true, false, [:normal, {}] #コマンド探査終了
  end
end
