require 'dxruby'

# イージングを可能にするEasingモジュール
# GetterとSetterさえあれば何にでもinclude/extendして使える。updateメソッドで値更新。
module Easing

  # 内部保持用のパラメータ構造体
  # setter      : Setterメソッドのシンボル
  # from        : 開始時の値
  # to          : 目標値
  # count       : 経過フレーム数
  # duration    : 完了フレーム数
  # easing_proc : イージング関数。0.0～1.0の値を渡し、補正した0.0～1.0の値を返すProcオブジェクト
  # loop        : trueだとcountがdurationに達したときに0に戻って自動的に繰り返す
  # set_proc    : easing_procが返した値とfrom/toから値を生成するProcオブジェクト。これが返した値がSetterに渡される。通常はDEAFULT_SET_PROCが入る
  # end_proc    : animateメソッドに渡したブロックが格納される。countがdurationに達したときに呼ばれる
  EasingParameter = Struct.new(:setter, :from, :to, :count, :duration, :easing_proc, :loop, :set_proc, :end_proc)

  # デフォルトのset_proc。見ての通り。
  DEFAULT_SET_PROC = ->x, param{x * (param.to - param.from) + param.from}

  # イージング処理開始。
  # to          : ハッシュで渡す。{x:50, y:100}とするとselfのxを50、yを100に変化させる
  # duration    : 変化にかけるフレーム数。updateを呼ぶと1フレーム経過する
  # easing_proc : イージング関数。シンボルで渡すと内蔵イージング関数が使える。Procを渡すと0.0～1.0を受け取って0.0～1.0を返すイージング関数を直接指定できる
  #
  # (opt) loop     : trueにするとイージング処理が終わってもまたfromから繰り返す
  # (opt) set_proc : 0.0～1.0の値とEasingParameterオブジェクトを受け取ってSetterに渡す値を返すProcを指定できる
  #
  # end_proc : イージング処理終了時にブロックが呼ばれる
  #
  # メモ : toに設定した複数の項目に対して、それ以外のパラメータすべてが同時に適用されるが、animateを複数回呼べば別のパラメータを適用することも可能。
  #      : 例えばangleをloop:trueで変化させながらxとyはマウスクリックのたびに動かすなど、パラメータ単位でバラバラに処理することができる。
  def animate(to, duration, easing_proc = :liner, loop: false, set_proc: DEFAULT_SET_PROC, &end_proc)
    @easing_param ||= {}

    # easing_procがシンボルの場合、EasingProcHash定数からProcを取り出す
    if easing_proc.kind_of?(Symbol)
      tmp = EasingProcHash[easing_proc]

      # EasingProcHashに無い場合はupdateでコケるがそれだと原因がさっぱりわからないのでここで例外にしておく
      raise ArgumentError, "easing_proc\":#{easing_proc}\" not found." unless tmp
      easing_proc = tmp
    end

    # toの各項目についてEasingParameterを生成して@easing_paramに設定する
    to.each do |k, v|
      setter = (k.to_s + "=").to_sym
      @easing_param[k] = EasingParameter.new(setter, self.__send__(k), v, 0, duration, easing_proc, loop, set_proc, end_proc)
    end
  end

  # イージング処理を終了させる
  # 引数無しで全部停止。シンボルを渡すと項目単位で停止することができる。配列を渡すことで複数同時停止も可能。どうでもいいけど配列のネストもできる
  def stop_animate(key = nil)
    @easing_param ||= {}
    if key
      if key.respond_to?(:each)
        key.each do |k|
          self.stop_animate(k)
        end
      else
        @easing_param.delete(key)
      end
    else
      @easing_param.clear
    end
  end

  # イージング処理を1フレーム進める
  def update
    @easing_param ||= {}
    end_proc_hash = {}

    # 項目ごとのイージング処理
    @easing_param.keys.each do |key|
      param = @easing_param[key]

      # 進捗度合い算出
      param.count += 1
      x = param.count.fdiv(param.duration)

      # イージング完了判定
      if param.count >= param.duration
        # イージング完了時の処理
        if param.loop
          # loopがtrueの場合はカウントを戻してイージング関数を呼ぶ。
          # toの値になることはありえない。
          param.count = 0
          self.__send__(param.setter, param.set_proc.call(param.easing_proc.call(x), param))
        else
          # 通常の終了時はtoの値で停止する。
          self.__send__(param.setter, param.set_proc.call(param.easing_proc.call(x), param))
          @easing_param.delete(key)
        end

        # 終了時処理の登録
        if param.end_proc
          # Procをキー、シンボルの配列を値にしておく。後で呼び出す。
          if end_proc_hash.has_key?(param.end_proc)
            end_proc_hash[param.end_proc] << key
          else
            end_proc_hash[param.end_proc] = [key]
          end
        end
      else
        # 終わってなかったときは通常処理
        self.__send__(param.setter, param.set_proc.call(param.easing_proc.call(x), param))
      end
    end

    # end_procの呼び出し
    end_proc_hash.each do |k, syms|
      k.call(syms)
    end

    super
  end

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

if __FILE__ == $0
  class EasingTestSprite < Sprite
    include Easing
  end
  
  sprites = Array.new(Easing::EasingProcHash.size){|i|EasingTestSprite.new(80,i*12+1,Image.new(10,10,C_WHITE))}
  font = Font.new(12)
  name_ary = Easing::EasingProcHash.to_a.map{|a|a[0]}
  
  Window.loop do
    sprites.size.times do |i|
      Window.draw_font(0, i * 12, name_ary[i].to_s, font, color:C_GREEN)
      Window.draw_font(570, i * 12, name_ary[i].to_s, font, color:C_GREEN)
    end

    if Input.mouse_push?(M_LBUTTON)
      sprites.each_with_index do |s, i|
        s.x = 80
        s.animate({x:550}, 120, name_ary[i])
      end
    end

    if Input.mouse_push?(M_RBUTTON)
      sprites.each do |s|
        s.x = 80
        s.stop_animate(:x)
      end
    end

    Sprite.update(sprites)
    Sprite.draw(sprites)
    break if Input.key_push?(K_ESCAPE)
  end
end
