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

  #TODO:いらない気がする
  attr_reader :x_pos
  attr_reader :y_pos
  attr_reader :width
  attr_reader :height

  def initialize(options, control = nil)
    super(options)

    @x_pos = options[:x_pos] || 0 #描画Ｘ座標
    @y_pos = options[:y_pos] || 0 #描画Ｙ座標

    #TODO：いらない気がする
    @width  = options[:width] || 0  #横幅
    @height = options[:height] || 0 #縦幅

    @join_right  = options[:join_right] || false #親Controlの右側に接続するか
    @join_bottom = options[:join_bottom] || false #親Controlの下側に接続するか
  end

  #可視設定
  def command_visible(options)
    @visible = options[:visible]
    return :continue #フレーム続行
  end

  #トランジションコマンド
  def command_transition(options) 
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
    control.send_command(:transition_crossfade, options)
    return :continue
  end

  def command_transition_crossfade(options)

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
      send_command_interrupt(:transition_crossfade, options)
      #待機モードを初期化
      @idol_mode = false
      return :continue #フレーム終了
    else

      dispose() #リソースの解放
      return :continue#フレーム続行
    end
  end

  #フェードインコマンド
  #count:現在カウント
  #frame:フレーム数
  #start:開始α値
  #last:終了α値
  def command_transition_fade(options) 
    #スキップモードであれば最終値を設定し、フレーム内処理を続行する
    if @skip_mode
      @draw_option[:alpha] = options[:last]
      return :continue #アイドル状態でタスク探査続行
    end

    #透明度の決定
    @draw_option[:alpha] = options[:start] + 
                          (((options[:last] - options[:start]).to_f / options[:frame]) * options[:count]).to_i

    #カウントアップ
    options[:count] += 1

    #カウントが指定フレーム以下の場合
    if options[:count] <= options[:frame]
      #待機モードを初期化
      @idol_mode = false
      #:transition_crossfadeコマンドをスタックし直す
      return :continue, [:transition_fade, options] #非アイドル状態でタスク探査続行
    else
      return :continue #アイドル状態でタスク探査続行
    end
  end
end
