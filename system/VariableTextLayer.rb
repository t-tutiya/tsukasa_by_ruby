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
=begin
class VariableCharContainer < CharContainer
  def initialize(options, control = nil)
    options[:draw_to_entity] = true
    super(options)

    #文字列を描画するコントロールを生成
    @text_layer = RenderTarget.new(options[:width], 
                                   options[:height], 
                                   [0, 0, 0, 0])

    @entity     = RenderTarget.new(options[:width], 
                                   options[:height], 
                                   [0, 0, 0, 0])

    #ＢＧオブジェクトの初期化
    @bg_image = [Image.load(options[:bg_path])]

    @move_offset_y = 0
    @text_layer_height = options[:height]
  end

  #描画
  def render(x_pos, y_pos, target, parent_x_end, parent_y_end)
    #背景画像をタイルとして一時表示
    @text_layer.draw_tile( nil, nil, [[0]], @bg_image, nil, nil, nil, nil, 0)
    #テキストレイヤを一時描画
    @control_list.each do |entity|
      entity.draw(x_pos, y_pos, @text_layer, @width, @height)
    end
    #一時描画をトリミングする
    @entity.draw_ex(0, @move_offset_y, @text_layer, @draw_option)

    #連結フラグが設定されているなら親コントロールの座標を追加する
    x_pos += parent_x_end if @join_right
    y_pos += parent_y_end if @join_bottom

    #描画
    target.draw_ex( x_pos + @x_pos, 
                    y_pos + @y_pos, 
                    @entity, 
                    @draw_option)
  end

  #resizeタグ
  #RenderTargetを再作成する
  def command_resize(options)

    @text_layer   = RenderTarget.new(@width, @height  + 8, [0,0,0,0])
    @entity = RenderTarget.new(@width, @height + 8 , [0,0,0,0])

    #:waitコマンドを追加でスタックする（待ち時間は遅延評価とする）
    @y_pos -= 17
    @move_offset_y = 16
    send_command(:test_command, {:count => 16}, @id, true)

    return false #フレーム続行
  end

  def command_test_command(options)

    @y_pos += 1
    @move_offset_y = options[:count]

    return false if options[:count] == 0
      
    #:waitコマンドを追加でスタックする（待ち時間は遅延評価とする）
    send_command(:test_command, {:count => options[:count] - 1}, @id, true)
    return true
  end
end
=end
#可変長テキストレイヤ
class VariableTextLayer < Control
  include Drawable #描画関連モジュール

  def initialize(options, control = nil)
  
    options[:height] = 272
  
    #文字列を描画するコントロールを生成
    @body =  RenderTarget.new( options[:width], 
                               options[:height], 
                               [0, 0, 0, 0])
    @body_target =  RenderTarget.new( options[:width], 
                                      options[:height], 
                                      [0, 0, 0, 0])

    @header = Image.load(options[:header])
    @footer = Image.load(options[:footer])

    @entity = RenderTarget.new( 
                          options[:width], 
                          options[:height] + @header.height + @footer.height ,
                          [0,0,0,0])


    #ＢＧオブジェクトの初期化
    @bg_image = [Image.load(options[:bg_path])]
    @move_offset_y = 0
    @text_layer_height = options[:height]
    
    #TODO：いらない気がする
    @width  = options[:width] || 0  #横幅
    @height = options[:height] || 0 #縦幅

    super(options)
  end

  #描画
  def render(x_pos, y_pos, target, parent_x_end, parent_y_end)
    #pp "===="
    #pp @move_offset_y
    #pp @header.height - @move_offset_y
    #pp @text_layer_height

    #背景画像をタイルとして一時表示
    @body.draw_tile( nil, nil, [[0]], @bg_image, nil, nil, nil, nil, 0)
    #テキストレイヤを一時描画
    @control_list[0].render(0, 0, @body, parent_x_end, parent_y_end)
    #一時描画をトリミングする
    @body_target.draw_ex(0, @move_offset_y, @body, @draw_option)
    #描画
    @entity.draw_ex(0, 
                    @header.height - @move_offset_y, 
                    @body_target, 
                    @draw_option)

    #ヘッダーを描画
    @entity.draw_ex(0, 0, @header, @draw_option)
    #フッターを描画
    @entity.draw_ex(0, 
                    @header.height - @move_offset_y + @text_layer_height,
                    @footer, 
                    @draw_option)

    #コントロールをサーフェエスに描画
    target.draw_ex(x_pos + @x_pos, y_pos + @y_pos, @entity, @draw_option) if @visible

    return target #引数を返値に伝搬する
  end
=begin
  #line_feedコマンド
  def command_test_command(options)

    @y_pos -= 1
    @move_offset_y = options[:count]

    return false if options[:count] == 0
      
    #:waitコマンドを追加でスタックする（待ち時間は遅延評価とする）
    send_command(:test_command, {:count => options[:count] - 1}, @id, true)
    return true
  end

  def command_check_height(options)
    #:waitコマンドを追加でスタックする（待ち時間は遅延評価とする）
    send_command(:check_height, {}, @id)

    return true if @text_layer_height == @control_list[0].height

    #pp @control_list[0].height
    if @text_layer_height != @control_list[0].height
      @text_layer_height = @control_list[0].height
      #レンダーターゲットを再生成する
      @body   = RenderTarget.new(@width, @text_layer_height , [0,0,0,0])
      @body_target = RenderTarget.new(@width, @text_layer_height , [0,0,0,0])
      @entity = RenderTarget.new( 
                       @width, 
                       @text_layer_height + @header.height + @footer.height,
                       [0,0,0,0])
      #:waitコマンドを追加でスタックする（待ち時間は遅延評価とする）
      send_command(:test_command, {:count => 16}, @id, true)
      return false
    end
  end
=end

  def command_text2(options)
    options[:text] = options[:text2]

    send_command(:text, options, :default_text_layer)
    send_command(:line_feed, nil, :default_text_layer)

    eval_block([
      [:eval, {:eval => "pp 'test'",:target_control => @id}],
      [:pause2, {:target_control => @id}]
    ])

#    if options[:last]
#      send_command(:resize, nil)
#    end

    return :continue 
  end

  def command_resize(options)
    @text_layer_height = @height += 18

    #文字列を描画するコントロールを生成
    @body =  RenderTarget.new( @width, 
                              @height, 
                               [0, 0, 0, 0])

    @body_target =  RenderTarget.new( @width, 
                                       @height, 
                                      [0, 0, 0, 0])

    @entity = RenderTarget.new( 
                      @width, 
                      @height + @header.height + @footer.height ,
                      [0,0,0,0])

    return :continue 
  end

  def command_pause2(options)
    return :continue if @skip_mode  #TODO:このロジックはプロシージャーで対応する
    #■ルートの待機処理

    eval_block([
      #スリープモードを設定
      [:sleep_mode, {:sleep_mode => :sleep,:target_control => @id}],
      #ウェイク待ち
      [:wait_wake, {:target_control => @id}],
      #描画レイヤのサイズを更新する
      [:resize, {:target_control => @id}]
    ])

    #■行表示中スキップ処理

    #idolになるかキー入力を待つ
    #※wait中にキーが押された場合、waitはスキップモードフラグを立てる
    send_command(:wait_key_push_with_idol, nil, :default_text_layer)

    #ルートにウェイクを送る
    #TODO：本来rootにのみ通知できれば良い筈
    send_command(:sleep_mode_all, {:sleep_mode_all => :wake}, :default_text_layer)

    return :continue
  end

end
