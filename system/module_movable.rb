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
  def command_move_line(options, inner_options)
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
      push_command_to_next_frame(:move_line, options, inner_options)
    end
  end
end
