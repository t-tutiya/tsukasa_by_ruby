#! ruby -E utf-8

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
class Image < Drawable
  #DXRuby::Imageのキャッシュマネージャー
  @@ImageCache = CacheManager.new do |id|
    DXRuby::Image.load(id)
  end
  
  def self.cache()
    return @@ImageCache
  end

  attr_reader :path
  def path=(path)
    #元Imageを解放
    @@ImageCache.dispose(@path) if @path
    #新Imageを取得
    @path = path
    @entity = @@ImageCache.load(@path)
    #XY幅を取得
    @width = @entity.width
    @height = @entity.height
  end

  def dispose()
    @@ImageCache.dispose(@path) if @path
    super
  end

  def initialize(options, yield_block_stack, root_control, parent_control, &block)
    @path = nil
    super

    if options[:path]
      self.path = options[:path]
    else
      @entity = DXRuby::Image.new(options[:width]  || 1,
                          options[:height] || 1,
                          options[:color]  || [0,0,0,0])
      #XY幅を取得
      @width = @entity.width
      @height = @entity.height
    end
  end

  #Image上に直線を引く
  def _LINE_(argument, options, yield_block_stack)
    @entity.line( 
      options[:x1], options[:y1], options[:x2], options[:y2], options[:color])
  end

  #Image上に矩形を描く
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

  #Image上に円を描く
  def _CIRCLE_(argument, options, yield_block_stack)
    if options[:fill]
      @entity.circle_fill(
        options[:x], options[:y], options[:r], options[:color])
    else
      @entity.circle( 
        options[:x], options[:y], options[:r], options[:color])
    end
  end

  #Image上に三角形を描く
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

  #Image上に文字を描く
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
      DXRuby::Font.new( options[:size] || 24,
                options[:font_name] || "",  
                {
                  weight: options[:weight] * 100,
                  italic: options[:italic] || false
                }
              ),
      options[:option])
  end

  #Imageを指定色で塗りつぶす
  def _FILL_(argument, options, yield_block_stack)
    @entity.fill(argument)
  end

  #Imageを[0,0,0,0]で塗りつぶす
  def _CLEAR_(argument, options, yield_block_stack)
    @entity.clear
  end

  #Imageの指定座標への色の取得／設定
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

  #Imageを指定座標の色を比較し、同値ならブロックを実行する
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
    rt = DXRuby::RenderTarget.new(width, height)

    #コントロールの初期化
    control = self

    #子コントロールを再帰的に検索
    Array(argument).each do |control_id|
      control = control.find_control(control_id)
      break unless control
    end

    #コントロールの探査に失敗
    unless control
      warn "コントロール\"#{argument}\"が存在しません"
      return
    end

    #中間バッファに描画（指定したコントロール自身は描画されないので注意）
    control.render(0,0,rt)

    #拡大率が設定されている場合
    if options[:scale]
      #第２中間バッファを生成
      rt2 = DXRuby::RenderTarget.new( options[:scale] * width, 
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
