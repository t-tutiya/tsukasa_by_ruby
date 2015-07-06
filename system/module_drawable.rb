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

#TODO:Controlクラスに統合する
#TODO:コマンドはカテゴリーごとにファイルを分ける
module Drawable
  #プロパティ
  attr_accessor  :x_pos
  attr_accessor  :y_pos
  attr_accessor  :visible

  attr_accessor  :float_mode
  attr_accessor  :z

  attr_reader  :width
  attr_reader  :height

  def initialize(options, system_options, system_property)
    @x_pos = options[:x_pos] || 0 #描画Ｘ座標
    @y_pos = options[:y_pos] || 0 #描画Ｙ座標

    #可視フラグ（省略時はtrue）
    @visible = options[:visible] == false ? false : true

    #子コントロールを自エンティティに描画するかどうか
    @child_controls_draw_to_entity = options[:child_controls_draw_to_entity]

    @draw_option = {} #描画オプション
    @draw_option[:z] = options[:index] || 0 #重ね合わせ順序

    super

    #回り込み指定（省略時は:none）
    @float_mode = options[:float_mode] || :none

    #TODO：いらない気がする
    @width  = options[:width] || 0  #横幅
    @height = options[:height] || 0 #縦幅
  end

  #可視設定
  def command_visible(options, target)
    @visible = options[:visible]
    return :continue
  end
  
  #描画
  def render(offset_x, offset_y, target)
    return offset_x, offset_y unless @visible

    #下位エンティティを自エンティティに描画する場合
    if @child_controls_draw_to_entity
      #下位エンティティを自エンティティに描画
      super(offset_x, offset_x, @entity)
      #自エンティティを上位ターゲットに描画
      target.draw_ex(@x_pos, @y_pos, @entity, @draw_option)
    else
      #エンティティを持っているなら自エンティティを上位ターゲットに描画
      target.draw_ex(offset_x + @x_pos, offset_y + @y_pos, @entity, @draw_option) if @entity
      #下位エンティティを上位ターゲットに描画
      super(offset_x + @x_pos, offset_y + @y_pos, target)
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
      dx = dy =  0
    else
      raise
    end

    return dx, dy
  end


=begin
  #トランジションコマンド
  def command_transition(options, target) 
    #一時サーフェイスを生成
    target = RenderTarget.new(@width, @height, [0, 0, 0, 0])
    #一時サーフェイスに子要素を描画
    render(0, 0, target)
    #一時サーフェイスをimage化
    control = ImageControl.new({}, target.to_image)
    #imageをコントロールリストに追加
    @control_list.push(control)
    #オプションを追加
    options[:count] = 0

    #トランジション実行コマンドを発行
    #TODO send_commandではなくinterrupt_command_allなのは、この時点でcontrolには匿名ＩＤ(:anonymous_control)が設定されている為。匿名ＩＤ自体を直接指定しても良いが、ひとまずこうしておく。
    control.send_script(:transition_crossfade, options)
    return :continue
  end

  def command_transition_crossfade(options, target)

    #スキップモードであれば最終値を設定し、フレーム内処理を続行する
    if @skip_mode
      @draw_option[:alpha] = 0

      dispose() #リソースの解放
      return :continue #フレーム続行
    end

    #透明度の決定
    @draw_option[:alpha] = 255 - (options[:count].to_f / options[:frame] * 255).to_i
    #カウントアップ
    options[:count] += 1

    #カウントが指定フレーム以下の場合
    if options[:count] <= options[:frame]
      #:transition_crossfadeコマンドをスタックし直す
      interrupt_command(:transition_crossfade, options)
      #待機モードを初期化
      @idle_mode = false
      return :continue #フレーム終了
    else

      dispose() #リソースの解放
      return :continue#フレーム続行
    end
  end
=end
  #フェードインコマンド
  #count:現在カウント
  #frame:フレーム数
  #start:開始α値
  #last:終了α値
  def command_transition_fade(options, target, command_name = :transition_fade) 
    #透明度の決定
    @draw_option[:alpha] = options[:start] + 
                          (((options[:last] - options[:start]).to_f / options[:frame]) * options[:count]).to_i

    #カウントアップ
    options[:count] += 1

    #カウントが指定フレーム以下の場合
    if options[:count] <= options[:frame]
      #待機モードを初期化
      @idle_mode = false
      #:transition_crossfadeコマンドをスタックし直す
      return :continue, [command_name, options] #非アイドル状態でタスク探査続行
    else
      return :continue
    end
  end
  
  def command_transition_fade_with_skip(options, target) 
    #pp @skip_mode
    #pp "D"
    #pp @id
    #pp @command_list
    #スキップモードであれば最終値を設定し、フレーム内処理を続行する
    if @skip_mode
      @draw_option[:alpha] = options[:last]
      return :continue
    end

    return command_transition_fade(options, target, :transition_fade_with_skip)
  end
end
