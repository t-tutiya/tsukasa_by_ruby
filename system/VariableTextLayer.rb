#! ruby -E utf-8

require 'dxruby'
require_relative './module_movable.rb'
require_relative './module_drawable.rb'
require_relative './control_container.rb'

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
#可変長テキストレイヤ
class VariableTextLayer < Control
  include Drawable #描画関連モジュール

  def initialize(options)
    options[:draw_to_entity] = true
    #保持オブジェクトの初期化
    @entity = RenderTarget.new( options[:width], 
                                            options[:height], 
                                            [0, 0, 0, 0])

    @width  = @entity.width
    @height = @entity.height
    super(options)
  end

  def command_line_feed(options, target)
    send_command(:line_feed, nil, :default_text_layer)
    eval_block([
      [:eval, {:eval => "pp 'test'"}, {:target_id => @id}],
      [:pause, {}, {:target_id => @id}],
      [:resize, {}, {:target_id => @id}],
    ])
    return :continue 
  end

  #TODO:これ書かずに済ませられないものか
  def command_text(options, target)
    send_command(:text, options, :default_text_layer)
    return :continue 
  end

  def command_resize(options, target)
    @height += 18

    @entity = RenderTarget.new( 
                      @width, 
                      @height ,
                      [0,0,0,0])

    return :continue 
  end

  def command_pause(options, target)
    return :continue if @skip_mode

    #■ルートの待機処理
    eval_block([
        #スリープモードを設定
        [:sleep_mode, {:sleep_mode => :sleep}, {:target_id => @id}],
        #ウェイク待ち
        [:wait_wake, {}, {:target_id => @id}],
      ])

    #■行表示中スキップ処理
    #idleになるかキー入力を待つ
    #※wait中にキーが押された場合、waitはスキップモードフラグを立てる
    send_command(:wait_key_push_with_idle, nil, :default_text_layer)

    #ルートにウェイクを送る
    #TODO：本来rootにのみ通知できれば良い筈
    send_command(:sleep_mode_all, {:sleep_mode_all => :wake}, :default_text_layer)

    return :continue
  end

end
