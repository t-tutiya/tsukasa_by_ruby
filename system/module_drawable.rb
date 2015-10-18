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
  #Imageのキャッシュ機構の簡易実装
  #TODO:キャッシュ操作：一括クリア、番号を指定してまとめて削除など
  @@image_cache = Hash.new
  #キャッシュされていない画像パスが指定されたら読み込む
  @@image_cache.default_proc = ->(hsh, key) {
    hsh[key] = Image.load(key)
  }

  attr_accessor  :x
  attr_accessor  :y

  attr_accessor  :offset_x
  attr_accessor  :offset_y

  attr_accessor  :visible

  attr_accessor  :float_mode
  attr_accessor  :align_y
  attr_accessor  :entity

  attr_accessor  :width
  attr_accessor  :height

  attr_accessor  :real_width
  attr_accessor  :real_height

  attr_accessor :entity

  attr_reader :rule_file_path
  def rule_file_path=(rule_file_path)
    @rule_file_path = rule_file_path
    #画像ファイルをキャッシュから読み込んで初期化する
    @rule_entity = TransitionShader.new(@@image_cache[rule_file_path])
  end

  #横の拡大率 
  #Float (default: 1)
  def scale_x=(arg)
    @draw_option[:scale_x] = arg
  end
  def scale_x()
    @draw_option[:scale_x]
  end

  #縦の拡大率  
  #Float (default: 1)
  def scale_y=(arg)
    @draw_option[:scale_y] = arg
  end
  def scale_y()
    @draw_option[:scale_y]
  end

  #回転、拡大の中心X座標。
  #nilで画像の中心になります。
  #Integer (default: nil)
  def center_x=(arg)
    @draw_option[:center_x] = arg
  end
  def center_x()
    @draw_option[:center_x]
  end

  #回転、拡大の中心Y座標。
  #nilで画像の中心になります。
  #Integer (default: nil)
  def center_y=(arg)
    @draw_option[:center_y] = arg
  end
  def center_y()
    @draw_option[:center_y]
  end

  #アルファ値(0～255)。
  #Integer (default: 255)
  def alpha=(arg)
    @draw_option[:alpha] = arg
  end
  def alpha()
    @draw_option[:alpha]
  end

  #:alpha、:none、:add、:add2、:subで合成方法を指定。
  #:noneは透明色、半透明色もそのまま上書き描画します。
  #:addはソースにアルファ値を、
  #:add2は背景に255-アルファ値を適用します。
  #:subはアルファ値を全ての色の合成に、
  #:sub2はRGBの色をそれぞれ別々に合成に適用します。
  #Symbol (default: :alpha)
  def blend=(arg)
    @draw_option[:blend] = arg
  end
  def blend()
    @draw_option[:blend]
  end

  #色
  #[R, G, B]で、それぞれ0～255、省略すると[255, 255, 255]になります。
  #Array (default: [255,255,255])
  def color=(arg)
    @draw_option[:color] = arg
  end
  def color()
    @draw_option[:color]
  end

  #360度系で画像の回転角度を指定します。
  #拡大率と同時に指定した場合は拡大率が先に適用されます。
  #Integer (default: 0)
  def angle=(arg)
    @draw_option[:angle] = arg
  end
  def angle()
    @draw_option[:angle]
  end

  #描画順序。
  #小さいほど奥になり、同じ値の場合は最初にdrawしたものが一番奥になります。
  #Integer|Float (default: 0)
  def z=(arg)
    @draw_option[:z] = arg
  end
  def z()
    @draw_option[:z]
  end

  #描画時の指定座標x/yに、画像のcenter_x/yで指定した位置が来るように補正されます
  #bool (default: false)
  def offset_sync=(arg)
    @draw_option[:offset_sync] = arg
  end
  def offset_sync()
    @draw_option[:offset_sync]
  end

  def initialize(options, inner_options, root_control)
    @x = options[:x] || 0 #描画Ｘ座標
    @y = options[:y] || 0 #描画Ｙ座標

    @offset_x = options[:offset_x] || 0 #描画オフセットＸ座標
    @offset_y = options[:offset_y] || 0 #描画オフセットＹ座標

    #可視フラグ（省略時はtrue）
    @visible = options[:visible] == false ? false : true

    #描画オプションの初期化
    @draw_option = options[:draw_option] || {}

    @draw_option[:scale_x] = options[:scale_x] || 1
    @draw_option[:scale_y] = options[:scale_y] || 1
    @draw_option[:center_x] = options[:center_x] || nil
    @draw_option[:center_y] = options[:center_y] || nil
    @draw_option[:alpha] = options[:alpha] || 255
    @draw_option[:blend] = options[:blend] || :alpha
    @draw_option[:color] = options[:color] || [255,255,255]
    @draw_option[:angle] = options[:angle] || 0
    @draw_option[:z] = options[:z] || 0
    @draw_option[:offset_sync] = options[:offset_sync] || false

    #回り込み指定（省略時は:none）
    @float_mode = options[:float_mode] || :none
    @align_y = options[:align_y] || :none

    @entity = options[:entity] if options[:entity]

    #子コントロールを自エンティティに描画するかどうか
    @child_controls_draw_to_entity = options[:child_controls_draw_to_entity] || false

    #ルールトランジション用の画像ファイルパスがあるならシェーダーを初期化する
    self.rule_file_path = options[:rule_file_path] if options[:rule_file_path]

    @real_width =  @width = 0
    @real_height = @height = 0

    if @entity
      @real_width = @entity.width
      @real_height = @entity.height
      @width  = options[:width] ? options[:width] : @real_width
      @height = options[:height] ? options[:height] : @real_height
    else
      @real_width = @width  = options[:width] if options[:width]
      @real_height = @height = options[:height] if options[:height]
    end

    super
  end

  #描画
  def render(offset_x, offset_y, target, parent_size)
    return offset_x, offset_y unless @visible

    if @align_y == :bottom 
      x = offset_x + @x + @offset_x
      y = offset_y + @y + @offset_y + parent_size[:height] - @height
    else
      x = offset_x + @x + @offset_x
      y = offset_y + @y + @offset_y
    end

    #下位エンティティを自エンティティに描画する場合
    if @child_controls_draw_to_entity
      #下位エンティティを自エンティティに描画
      super(0, 0, @entity, {:width => @width, :height => @height})


      #自エンティティを上位ターゲットに描画
      target.draw_ex(x, y, @entity, @draw_option)
    else
      #エンティティを持っているなら自エンティティを上位ターゲットに描画
      target.draw_ex(x, y, @entity, @draw_option) if @entity
      #下位エンティティを上位ターゲットに描画
      super(offset_x + @x, 
            offset_y + @y, 
            target, 
            {:width => @width, :height => @height})
    end

    #デバッグ用：コントロールの外枠を描画する
    if @_GLOBAL_DATA_[:_DEBUG_]
      target.draw_box_line( x, y, 
                            x + @real_width,  y + @real_height)
    end

    dx = offset_x + @x
    dy = offset_y + @y

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

  def siriarize(options = {})

    options.update({
      :x  => @x,
      :y => @y,

      :offset_x => @offset_x,
      :offset_y => @offset_y,

      :visible => @visible,

      :draw_option => @draw_option,

      :float_mode => @float_mode,
      :align_y => @align_y,

      :real_width => @real_width,
      :real_height => @real_height,

      :rule_file_path => @rule_file_path
    })

    return super(options)
  end


end

module Drawable
  def command_move(options, inner_options)
    raise unless options[:time] #必須要素

    #現在の経過カウントを初期化
    options[:count] = 0 unless options[:count]

    #条件判定が存在し、かつその条件が成立した場合
    if options[:check] and check_imple(options[:check][0], options[:check][1])
      #ブロックがあれば実行し、コマンドを終了する
      eval_block(options, &inner_options[:block]) if inner_options[:block]
      return
    end

    # Easingパラメータが設定されていなければ線形移動を設定
    options[:easing] = :liner unless options[:easing]

    options[:type].each do |key, index|

      #開始値が設定されていなければ現在の値で初期化
      unless options[:type][key].instance_of?(Array)
        options[:type][key] = [send(key), options[:type][key]]
      end

      #値を更新する
      send(key.to_s + "=", 
            (options[:type][key][0] + 
              (options[:type][key][1] - options[:type][key][0]).to_f * 
                EasingProcHash[options[:easing]].call(
                  options[:count].fdiv(options[:time])
              )
            ).to_i)
    end

    #カウントが指定フレーム未満の場合
    if options[:count] < options[:time]
      #カウントアップ
      options[:count] += 1
      #:moveコマンドをスタックし直す
      push_command_to_next_frame(:move, options, inner_options)
    end
  end

  #スプライン補間
  #これらの実装については以下のサイトを参考にさせて頂きました。感謝します。
  # http://www1.u-netsurf.ne.jp/~future/HTML/bspline.html
  def command_path_move(options, inner_options)
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
      step =(path.size.to_f + 1)/ options[:time] * options[:count] - 1.0
    else
      #Ｂスプライン補間時に始点終点を通らない
      step =(path.size.to_f - 1)/ options[:time] * options[:count]
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
    if options[:count] <= options[:time]
      #カウントアップ
      options[:count] += 1
      #:move_lineコマンドをスタックし直す
      push_command_to_next_frame(:path_move, options, inner_options)
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

module Drawable
  #ルールトランジション
  def command_transition_rule(options, inner_options)
    #現在の経過カウントを初期化
    options[:count] = 0 unless options[:count]
    #曖昧さを初期化
    options[:vague] = 40 unless options[:vague]

    #条件判定が存在し、かつその条件が成立した場合
    if options[:check] and check_imple(options[:check][0], options[:check][1])
      #ブロックがあれば実行し、コマンドを終了する
      eval_block(options, &inner_options[:block]) if inner_options[:block]
      return
    end

    @rule_entity.g_min =( ( options[:vague] + 
                            options[:time]
                          ).fdiv(options[:time]) *
                          options[:count] - 
                          options[:vague]
                        ).fdiv(options[:time])

    @rule_entity.g_max =( ( options[:vague] + 
                            options[:time]
                          ).fdiv(options[:time]) *
                          options[:count]
                        ).fdiv(options[:time])

    #カウントが指定フレーム未満の場合
    if options[:count] < options[:time]
      @draw_option[:shader] = @rule_entity
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

module Drawable
  # jQuery + jQueryEasingPluginより32種類の内蔵イージング関数。それぞれの動きはサンプルを実行して確認のこと。
  EasingProcHash = {
    :liner => ->x{x},
    :in_quad => ->x{x**2},
    :in_cubic => ->x{x**3},
    :in_quart => ->x{x**4},
    :in_quint => ->x{x**5},
    :in_expo => ->x{x == 0 ? 0 : 2 ** (10 * (x - 1))},
    :in_sine => ->x{-Math.cos(x * Math::PI / 2) + 1},
    :in_circ => ->x{x == 0 ? 0 : -(Math.sqrt(1 - (x * x)) - 1)},
    :in_back => ->x{x == 0 ? 0 : x == 1 ? 1 : (s = 1.70158; x * x * ((s + 1) * x - s))},
    :in_bounce => ->x{1-EasingProcHash[:out_bounce][1-x]},
    :in_elastic => ->x{1-EasingProcHash[:out_elastic][1-x]},
    :out_quad => ->x{1-EasingProcHash[:in_quad][1-x]},
    :out_cubic => ->x{1-EasingProcHash[:in_cubic][1-x]},
    :out_quart => ->x{1-EasingProcHash[:in_quart][1-x]},
    :out_quint => ->x{1-EasingProcHash[:in_quint][1-x]},
    :out_expo => ->x{1-EasingProcHash[:in_expo][1-x]},
    :out_sine => ->x{1-EasingProcHash[:in_sine][1-x]},
    :out_circ => ->x{1-EasingProcHash[:in_circ][1-x]},
    :out_back => ->x{1-EasingProcHash[:in_back][1-x]},
    :out_bounce => ->x{
      case x
      when 0, 1
        x
      else
        if x < (1 / 2.75)
          7.5625 * x * x
        elsif x < (2 / 2.75)
          x -= 1.5 / 2.75
          7.5625 * x * x + 0.75
        elsif x < 2.5 / 2.75
          x -= 2.25 / 2.75
          7.5625 * x * x + 0.9375
        else
          x -= 2.625 / 2.75
          7.5625 * x * x + 0.984375
        end
      end
    },
    :out_elastic => ->x{
      case x
      when 0, 1
        x
      else
        (2 ** (-10 * x)) * Math.sin((x / 0.15 - 0.5) * Math::PI) + 1
      end
    },
    :swing => ->x{0.5 - Math.cos( x * Math::PI ) / 2},
    :inout_quad => ->x{
      if x < 0.5
        x *= 2
        0.5 * x * x
      else
        x = (x * 2) - 1
        -0.5 * (x * (x - 2) - 1)
      end
    },
    :inout_cubic => ->x{
      if x < 0.5
        x *= 2
        0.5 * x * x * x
      else
        x = (x * 2) - 2
        0.5 * (x * x * x + 2)
      end
    },
    :inout_quart => ->x{
      if x < 0.5
        x *= 2
        0.5 * x * x * x * x
      else
        x = (x * 2) - 2
        -0.5 * (x * x * x * x - 2)
      end
    },
    :inout_quint => ->x{
      if x < 0.5
        x *= 2
        0.5 * x * x * x * x * x
      else
        x = (x * 2) - 2
        0.5 * (x * x * x * x * x + 2)
      end
    },
    :inout_sine => ->x{
      -0.5 * (Math.cos(Math::PI * x) - 1);
    },
    :inout_expo => ->x{
      case x
      when 0, 1
        x
      else
        if x < 0.5
          x *= 2
          0.5 * (2 ** (10 * (x - 1)))
        else
          x = x * 2 - 1
          0.5 * (-2 ** (-10 * x) + 2)
        end
      end
    },
    :inout_circ => ->x{
    if x < 0.5
      x *= 2
      -0.5 * (Math.sqrt(1 - x * x) - 1);
    else
      x = x * 2 - 2
      0.5 * (Math.sqrt(1 - x * x) + 1);
    end
    },
    :inout_back => ->x{
      case x
      when 0, 1
        x
      else
        if x < 0.5
          EasingProcHash[:in_back][x*2] * 0.5
        else
          EasingProcHash[:out_back][x*2-1] * 0.5 + 0.5
        end
      end
    },
    :inout_bounce => ->x{
      case x
      when 0, 1
        x
      else
        if x < 0.5
          EasingProcHash[:in_bounce][x*2] * 0.5
        else
          EasingProcHash[:out_bounce][x*2-1] * 0.5 + 0.5
        end
      end
    },
    :inout_elastic => ->x{
      case x
      when 0, 1
        x
      else
        if x < 0.5
          EasingProcHash[:in_elastic][x*2] * 0.5
        else
          EasingProcHash[:out_elastic][x*2-1] * 0.5 + 0.5
        end
      end
    },
  }

end
