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

    @offset_x = options[:offset_x] || 0 #描画オフセットＸ座標
    @offset_y = options[:offset_y] || 0 #描画オフセットＹ座標

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

    @draw_option[:alpha] = @draw_option[:alpha] || 255

    #回り込み指定（省略時は:none）
    @float_mode = options[:float_mode] || :none
    @align_y = options[:align_y] || :none

    #TODO：いらない気がする
    @width  = options[:width] || 0  #横幅
    @height = options[:height] || 0 #縦幅

    #ルールトランジション用の画像ファイルパスがあるならシェーダーを初期化する
    self.rule = options[:rule] if options[:rule]

    super
  end

  #描画
  def render(offset_x, offset_y, target, parent_size)
    return offset_x, offset_y unless @visible

    if @align_y == :bottom 
      x_pos = offset_x + @x_pos + @offset_x
      y_pos = offset_y + @y_pos + @offset_y + parent_size[:height] - @height
    else
      x_pos = offset_x + @x_pos + @offset_x
      y_pos = offset_y + @y_pos + @offset_y
    end

    #下位エンティティを自エンティティに描画する場合
    if @child_controls_draw_to_entity
      #下位エンティティを自エンティティに描画
      super(0, 0, @entity, {:width => @width, :height => @height})


      #自エンティティを上位ターゲットに描画
      target.draw_ex(x_pos, y_pos, @entity, @draw_option)
    else
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
end

module Drawable #ムーブ
  def command_move(options, inner_options)

    options[:count] = 0 unless options[:count]

    #初期値が設定されていない場合は現在値を設定する
    options[:start] = [@x_pos, @y_pos] unless options[:start]
  
    #透明度が設定されていなければ現在の値で初期化
    unless options[:start][2]
      options[:start][2] = @draw_option[:alpha]
    end

    start_x = options[:start][0]
    start_y = options[:start][1]
    start_alpha = options[:start][2]

    end_x = options[:end][0]
    end_y = options[:end][1]

    #透明度が設定されていなければ現在の値で初期化
    unless options[:end][2]
      options[:end][2] = @draw_option[:alpha]
    end

    end_alpha = options[:end][2]

    #移動先座標の決定
    @x_pos = (start_x + (end_x - start_x).to_f / options[:total_frame] * options[:count]).to_i
    @y_pos = (start_y + (end_y - start_y).to_f / options[:total_frame] * options[:count]).to_i
    @draw_option[:alpha] = (start_alpha + (end_alpha - start_alpha).to_f / options[:total_frame] * options[:count]).to_i

    #カウントが指定フレーム未満の場合
    if options[:count] < options[:total_frame]
      #待機モードを初期化
      @idle_mode = false
      #:moveコマンドをスタックし直す
      push_command_to_next_frame(:move, options, inner_options)
    end

    #カウントアップ
    options[:count] += 1
  end

  def command_move_path(options, inner_options)

    options[:count] = 0 unless options[:count]

    path = options[:path]

    #始点／終点を強制的に通過させるかどうか
    if options[:origin]
      #TODO：これだと開始時／終了時にもたってしまい、ゲームで使う補間に適さないように思える。どちらを標準にすべきか検討
      step =(path.size.to_f + 1)/ options[:total_frame] * options[:count] - 1.0
    else
      #Ｂスプライン補間時に始点終点を通らない
      step =(path.size.to_f - 1)/ options[:total_frame] * options[:count]
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

      case options[:type]
      when :spline
        coefficent = b_spline_coefficent(step - index)
      when :line
        coefficent = line_coefficent(step - index)
      else
        coefficent = line_coefficent(step - index)
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
    @x_pos = x.round
    @y_pos = y.round
    @draw_option[:alpha] = alpha.round

    #カウントアップ
    options[:count] += 1

    #カウントが指定フレーム以下の場合
    if options[:count] <= options[:total_frame]
      #待機モードを初期化
      @idle_mode = false
      #:move_lineコマンドをスタックし直す
      push_command_to_next_frame(:move_path, options, inner_options)
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

module Drawable #トランジション

  def rule=(file_path)
    @rule = TransitionShader.new(Image.load(file_path))
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

  def command_transition_rule(options, inner_options)
    count =  options[:count]
    total_frame =  options[:total_frame]
    vague =  options[:vague]

    @rule.g_min = (((vague + total_frame).fdiv(total_frame)) * count - vague).fdiv(total_frame)
    @rule.g_max = (((vague + total_frame).fdiv(total_frame)) * count).fdiv(total_frame)

    #カウントが指定フレーム未満の場合
    if options[:count] < options[:total_frame]
      @draw_option[:shader] = @rule
      #待機モードを初期化
      @idle_mode = false
      #カウントアップ
      options[:count] += 1
      #:transition_ruleコマンドをスタックし直す
      push_command_to_next_frame(:transition_rule, options, inner_options)
    else
      @draw_option[:shader] = nil
    end
  end

  class TransitionShader < DXRuby::Shader
    #ルールトランジションを実行するHLSLスクリプト
    hlsl = <<EOS
    float g_min;
    float g_max;
    float2 scale;
    texture tex0;
    texture tex1;
    sampler Samp0 = sampler_state
    {
     Texture =<tex0>;
    };
    sampler Samp1 = sampler_state
    {
     Texture =<tex1>;
     AddressU = WRAP;
     AddressV = WRAP;
    };

    struct PixelIn
    {
      float2 UV : TEXCOORD0;
    };
    struct PixelOut
    {
      float4 Color : COLOR0;
    };

    PixelOut PS(PixelIn input)
    {
      PixelOut output;
      output.Color = tex2D( Samp0, input.UV );
      output.Color.a *= smoothstep(g_min, g_max, tex2D( Samp1, input.UV * scale ).r );

      return output;
    }

    technique Transition
    {
     pass P0
     {
      PixelShader = compile ps_2_0 PS();
     }
    }
EOS

    #HLSLスクリプトと引数を定義
    @@core = DXRuby::Shader::Core.new(
      hlsl,
      {
        :g_min => :float,
        :g_max => :float,
        :scale => :float, # HLSL側がfloat2の場合は:floatを指定して[Float, Flaot]という形で渡す
        :tex1 => :texture,
      }
    )

    #image：ルール画像のImageオブジェクト(省略でクロスフェード)
    def initialize(image=nil)
      super(@@core, "Transition")
      if image
        @image = image
      else
        @image = DXRuby::Image.new(1, 1, [0,0,0])
      end

      self.g_min = 1.0
      self.g_max = 1.0
      self.tex1   = @image
      self.scale  = [ DXRuby::Window.width.fdiv(@image.width), 
                      DXRuby::Window.height.fdiv(@image.height)
                    ]
    end

  end
end