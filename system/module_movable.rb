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

module Movable

=begin
  def command_move(options)

    control_options = {}

    if options[:offset]
      control_options[:x] = options[:offset_x] + @x_pos
      control_options[:y] = options[:offset_y] + @y_pos
    else
      control_options[:x] = options[:x]
      control_options[:y] = options[:y]
    end

    #スキップモードであれば設定し、フレーム内処理を続行する
    if @skip_mode
      @x_pos = control_options[:x]
      @y_pos = control_options[:y]
      return
    end

    control_options[:start_x] = @x_pos
    control_options[:start_y] = @y_pos
    control_options[:count] = 0
    control_options[:frame] = options[:frame]

    interrupt_command(:move_line, control_options)

    #待機モードを初期化
    @idle_mode = false

    return
  end
=end
  def command_move_line(options, target, command_name = :move_line)
    #移動先座標の決定
    @x_pos = (options[:start_x] + (options[:x] - options[:start_x]).to_f / options[:frame] * options[:count]).to_i
    @y_pos = (options[:start_y] + (options[:y] - options[:start_y]).to_f / options[:frame] * options[:count]).to_i
    #カウントアップ
    options[:count] += 1

    #カウントが指定フレーム以下の場合
    if options[:count] <= options[:frame]
      #待機モードを初期化
      @idle_mode = false
      #:move_lineコマンドをスタックし直す
      return [command_name, options]
    else
      return
    end
  end

  def command_move_line_with_skip(options, target)
    #スキップモードであれば最終値を設定し、フレーム内処理を続行する
    if @skip_mode
      @x_pos = options[:x]
      @y_pos = options[:y]
      return
    end
    
    return command_move_line(options, target, :move_line_with_skip)
  end
end
