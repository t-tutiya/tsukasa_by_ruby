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

  def command_move_spline(options, inner_options)


    options[:count] = 0 unless options[:count]

    path = options[:path]

    step = path.size.to_f / options[:total_frame] * options[:count]

    x = 0.0
    y = 0.0
    size = path.size - 1 #添え字のＭＡＸが欲しいので-1する

    #全ての座標を巡回し、それぞれの座標についてstep量に応じた重み付けを行い、その総和を現countでの座標とする
    #始点と終点を通過させる為、その前後２個に仮想の座標が存在する物としている
    -2.upto(size + 2) do |index|

      #始点と終点を通過させるために強制的な補正をかける
      if index < 0 # -2 <= index < 0
        path_index = 0 
      elsif size < index # size < index <= size + 2
        path_index = size
      else # 0 <= index <= size
        path_index = index
      end

      #重み付け関数
      coefficent = b_spline_coefficent(step - index)

      x += path[path_index][0] * coefficent
      y += path[path_index][1] * coefficent

    end

    #移動先座標の決定
    @x_pos = x.round
    @y_pos = y.round
    #カウントアップ
    options[:count] += 1

    #カウントが指定フレーム以下の場合
    if options[:count] <= options[:total_frame]
      #待機モードを初期化
      @idle_mode = false
      #:move_lineコマンドをスタックし直す
      push_command_to_next_frame(:move_spline, options, inner_options)
    end
  end

  #３次Ｂスプライン重み付け関数
  def b_spline_coefficent(t)
    t = t.abs

    # -1.0 < t < 1.0
    if t < 1.0 
      return (3.0 * t ** 3 -6.0 * t ** 2 + 4.0) / 6.0

    # -2.0 < t <= -1.0 or 1.0 <= t < 2.0
    elsif t < 2.0 
      return  -(t - 2.0) ** 3 / 6.0

    # t <= -2.0 or 2.0 <= t
    else 
      return 0.0
    end
  end


end
