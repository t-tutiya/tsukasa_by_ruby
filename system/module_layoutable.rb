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

module Layoutable

  attr_accessor  :x
  attr_accessor  :y

  attr_accessor  :offset_x
  attr_accessor  :offset_y

  attr_accessor  :visible

  attr_accessor  :float_mode
  attr_accessor  :align_y

  attr_accessor  :width
  attr_accessor  :height

  attr_accessor  :real_width
  attr_accessor  :real_height

  def initialize(options, inner_options, root_control)
    @x = options[:x] || 0 #描画Ｘ座標
    @y = options[:y] || 0 #描画Ｙ座標

    @offset_x = options[:offset_x] || 0 #描画オフセットＸ座標
    @offset_y = options[:offset_y] || 0 #描画オフセットＹ座標

    #可視フラグ（省略時はtrue）
    @visible = options[:visible] == false ? false : true

    #回り込み指定（省略時は:none）
    @float_mode = options[:float_mode] || :none
    @align_y = options[:align_y] || :none

    @real_width = @width  = options[:width] ? options[:width] : 0
    @real_height = @height = options[:height] ? options[:height] : 0

    super
  end

  #描画
  def render(offset_x, offset_y, target, parent_size)
    return 0, 0 unless @visible

    #下位コントロールを上位ターゲットに直接描画
    super(offset_x, offset_y, target, {:width => @width, :height => @height})

    #連結指定チェック
    case @float_mode
    #右連結
    when :right
      dx = @width
      dy = @y
    #下連結
    when :bottom
      dx = @x
      dy = @height
    #連結解除
    when :none
      dx = 0
      dy = 0
    else
      pp @float_mode
      raise
    end

    return dx, dy
  end
end

module Layoutable
  #スプライン補間
  #これらの実装については以下のサイトを参考にさせて頂きました。感謝します。
  # http://www1.u-netsurf.ne.jp/~future/HTML/bspline.html
  def command__PATH_(options, inner_options)
    raise unless options[:_ARGUMENT_] #必須要素
    #現在の経過カウントを初期化
    options[:count] = 0 unless options[:count]

    #条件判定が存在し、かつその条件が成立した場合
    if options[:check] and check_imple(options[:check][0], options[:check][1])
      #ブロックがあれば実行し、コマンドを終了する
      eval_block(options, &inner_options[:block]) if inner_options[:block]
      return
    end

    path = options[:path]

    #始点／終点を強制的に通過させるかどうか
    if options[:origin]
      #TODO：これだと開始時／終了時にもたってしまい、ゲームで使う補間に適さないように思える。どちらを標準にすべきか検討
      step =(path.size.to_f + 1)/ options[:_ARGUMENT_] * options[:count] - 1.0
    else
      #Ｂスプライン補間時に始点終点を通らない
      step =(path.size.to_f - 1)/ options[:_ARGUMENT_] * options[:count]
    end

    x = 0.0
    y = 0.0
    alpha = 0.0
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

      options[:type] = :line unless options[:type]

      case options[:type]
      when :spline
        coefficent = b_spline_coefficent(step - index)
      when :line
        coefficent = line_coefficent(step - index)
      else
        raise
      end

      x += path[path_index][0] * coefficent
      y += path[path_index][1] * coefficent

      #透明度が設定されていなければ現在の値で初期化
      unless path[path_index][2]
        options[:path][path_index][2] = @draw_option[:alpha]
      end

      alpha += path[path_index][2] * coefficent
    end

    #移動先座標の決定
    @x = x.round
    @y = y.round
    @draw_option[:alpha] = alpha.round

    #カウントが指定フレーム以下の場合
    if options[:count] <= options[:_ARGUMENT_]
      #カウントアップ
      options[:count] += 1
      #:move_lineコマンドをスタックし直す
      push_command_to_next_frame(:_PATH_, options, inner_options)
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

  def line_coefficent(t)
    t = t.abs

    if t <= 1.0 
      return 1 - t
    # t <= -1.0 or 1.0 <= t
    else 
      return 0.0
    end
  end
end

