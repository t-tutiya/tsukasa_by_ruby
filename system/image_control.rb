#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver1.2.1(2016/5/2)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2016> <tsukasa TSUCHIYA>
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

#画像コントロール
class ImageControl < DrawableControl
  
  attr_reader :file_path
  def file_path=(file_path)
    @file_path = file_path
    begin
      @entity = Image.load(@file_path)
    rescue DXRuby::DXRubyError => e
      puts "ファイル'#{@file_path}'の読み込みに失敗しました"
      puts e.backtrace[0]
      exit
    end
    @width = @entity.width
    @height = @entity.height
  end

  attr_reader :entity

  def dispose()
    @entity.dispose
    super
  end

  def initialize(options, yield_block_stack, root_control, parent_control, &block)
    if options[:file_path]
      self.file_path = options[:file_path]
    else
      @entity = Image.new(options[:width]  || 1,
                          options[:height] || 1,
                          options[:color]  || [0,0,0,0])
    end
    @entity = options[:entity] if options[:entity]
    options[:width] = @entity.width
    options[:height] = @entity.height
    super
  end

  #ImageControl上に直線を引く
  def _LINE_(argument, options, yield_block_stack)
    @entity.line( 
      options[:x1], options[:y1], options[:x2], options[:y2], options[:color])
  end

  #ImageControl上に矩形を描く
  def _BOX_(argument, options, yield_block_stack)
    if options[:fill]
      @entity.box_fill( 
        options[:x1], options[:y1], options[:x2], options[:y2], 
        options[:color])
    else
      @entity.box(
        options[:x1], options[:y1], options[:x2], options[:y2], 
        options[:color])
    end
  end

  #ImageControl上に円を描く
  def _CIRCLE_(argument, options, yield_block_stack)
    if options[:fill]
      @entity.circle_fill(
        options[:x], options[:y], options[:r], options[:color])
    else
      @entity.circle( 
        options[:x], options[:y], options[:r], options[:color])
    end
  end

  #ImageControl上に三角形を描く
  def _TRIANGLE_(argument, options, yield_block_stack)
    if options[:fill]
      @entity.triangle_fill(
        options[:x1], options[:y1], options[:x2], options[:y2], 
        options[:x3], options[:y3], 
        options[:color])
    else
      @entity.triangle( 
        options[:x1], options[:y1], options[:x2], options[:y2], 
        options[:x3], options[:y3], 
        options[:color])
    end
  end

  #ImageControl上に文字を描く
  def _TEXT_(argument, options, yield_block_stack)
    options[:weight] = 4 unless options[:weight]
    options[:option] = {} unless options[:option]
    if options[:color]
      options[:option][:color] = options[:color]  
    else
      options[:option][:color] = [0, 0, 0, 0]
    end

    @entity.draw_font_ex(
      options[:x] || 0, options[:y] || 0,
      options[:text],
      Font.new( options[:size] || 24,
                options[:font_name] || "",  
                {
                  weight: options[:weight] * 100,
                  italic: options[:italic] || false
                }
              ),
      options[:option])
  end

  #ImageControlを指定色で塗りつぶす
  def _FILL_(argument, options, yield_block_stack)
    @entity.fill(argument)
  end

  #ImageControlを[0,0,0,0]で塗りつぶす
  def _CLEAR_(argument, options, yield_block_stack)
    @entity.clear
  end

  #ImageControlの指定座標への色の取得／設定
  def _PIXEL_(argument, options, yield_block_stack, &block)
    if options[:color]
      @entity[options[:x], options[:y]] = options[:color]
    end
    if block
      #ブロックが付与されているならそれを実行する
      parse_block(@entity[options[:x], options[:y]], nil, 
                  yield_block_stack, &block)
    end
  end

  #ImageControlを指定座標の色を比較し、同値ならブロックを実行する
  def _COMPARE_(argument, options, yield_block_stack, &block)
    if @entity.compare(options[:x], options[:y], options[:color])
      #ブロックが付与されているならそれを実行する
      parse_block(@entity[options[:x], options[:y]], nil, 
                  yield_block_stack, &block)
    end
  end

  #画像を保存する
  def _SAVE_IMAGE_(argument, options, yield_block_stack)
    @entity.save(argument,options[:format] || FORMAT_PNG)
  end

  #指定したツリーを描画する
  def _DRAW_(argument, options, yield_block_stack, &block)
    #中間バッファのサイズを決める
    width = options[:width] || @width
    height = options[:height] || @height
    #中間バッファを生成
    rt = RenderTarget.new(width, height)

    #コントロールの初期化
    control = self
    argument = [argument] unless argument.instance_of?(Array)

    #子コントロールを再帰的に検索
    argument.each do |control_id|
      control = control.find_control(control_id)
      break unless control
    end

    #コントロールの探査に失敗
    unless control
      pp "コントロールが存在しません"
      return
    end

    #中間バッファに描画（指定したコントロール自身は描画されないので注意）
    control.render(0,0,rt)

    #拡大率が設定されている場合
    if options[:scale]
      #第２中間バッファを生成
      rt2 = RenderTarget.new( options[:scale] * width, 
                              options[:scale] * height,)
      #拡大率を反映して第２中間バッファに描画
      rt2.draw_ex(-1 * options[:scale]**2 * width,
                  -1 * options[:scale]**2 * height,
                  rt,
                  {:scale_x => options[:scale],
                   :scale_y => options[:scale],})
      #自身に描画
      @entity.draw(0,0, rt2.to_image)
    else
      #自身に描画
      @entity.draw(0,0, rt.to_image)
    end
  end
end
