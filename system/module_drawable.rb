#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver1.0(2015/12/24)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
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

module Drawable
  include Layoutable
  #Imageのキャッシュ機構の簡易実装
  #TODO:キャッシュ操作：一括クリア、番号を指定してまとめて削除など
  @@image_cache = Hash.new
  #キャッシュされていない画像パスが指定されたら読み込む
  @@image_cache.default_proc = ->(hsh, key) {
    hsh[key] = Image.load(key)
  }

  attr_accessor  :entity

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

  def shader=(arg)
    @draw_option[:shader] = find_control(arg)[0].entity
  end

  #描画時の指定座標x/yに、画像のcenter_x/yで指定した位置が来るように補正されます
  #bool (default: false)
  def offset_sync=(arg)
    @draw_option[:offset_sync] = arg
  end
  def offset_sync()
    @draw_option[:offset_sync]
  end

  def initialize(argument, options, inner_options, root_control)
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

    @entity = options[:entity] || nil

    if @entity
      options[:width] = @entity.width
      options[:height] = @entity.height
    end

    super
  end

  #描画
  def render(offset_x, offset_y, target, 
              width , 
              height , 
              mouse_pos_x,
              mouse_pos_y )

    #描画オブジェクトを持ち、かつ可視でなければ戻る
    return 0, 0 unless @entity and @visible

    #下揃えを考慮
    if @align_y == :bottom 
      offset_y += height - @height
    end

    #下位エンティティを自エンティティに描画
    dx, dy = super(0, 0, 
                    @entity, 
                    @width, 
                    @height, 
                    mouse_pos_x,
                    mouse_pos_y)

    #自エンティティを上位ターゲットに描画
    target.draw_ex( @x + @offset_x + offset_x,
                    @y + @offset_y + offset_y, 
                    @entity, 
                    @draw_option)

    return dx, dy
  end

  def serialize(control_name, **options)
    
    options[:draw_option] = @draw_option

    return super(control_name, options)
  end
end

