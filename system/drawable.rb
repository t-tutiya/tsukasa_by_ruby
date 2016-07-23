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

module Tsukasa

module Helper

class Drawable < Layoutable
  attr_reader  :entity

  #可視フラグ
  attr_accessor  :visible

  #横の拡大率 
  #Float (初期値： 1)
  def scale_x=(arg)
    @draw_option[:scale_x] = arg
  end
  def scale_x()
    @draw_option[:scale_x]
  end

  #縦の拡大率  
  #Float (初期値： 1)
  def scale_y=(arg)
    @draw_option[:scale_y] = arg
  end
  def scale_y()
    @draw_option[:scale_y]
  end

  #回転、拡大の中心X座標。
  #nilで画像の中心になります。
  #Integer (初期値： nil)
  def center_x=(arg)
    @draw_option[:center_x] = arg
  end
  def center_x()
    @draw_option[:center_x]
  end

  #回転、拡大の中心Y座標。
  #nilで画像の中心になります。
  #Integer (初期値： nil)
  def center_y=(arg)
    @draw_option[:center_y] = arg
  end
  def center_y()
    @draw_option[:center_y]
  end

  #アルファ値(0～255)。
  #Integer (初期値： 255)
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
  #Symbol (初期値： :alpha)
  def blend=(arg)
    @draw_option[:blend] = arg
  end
  def blend()
    @draw_option[:blend]
  end

  #色
  #[R, G, B]で、それぞれ0～255、省略すると[255, 255, 255]になります。
  #Array (初期値： [255,255,255])
  def color=(arg)
    @draw_option[:color] = arg
  end
  def color()
    @draw_option[:color]
  end

  #360度系で画像の回転角度を指定します。
  #拡大率と同時に指定した場合は拡大率が先に適用されます。
  #Integer (初期値： 0)
  def angle=(arg)
    @draw_option[:angle] = arg
  end
  def angle()
    @draw_option[:angle]
  end

  #描画順序。
  #小さいほど奥になり、同じ値の場合は最初にdrawしたものが一番奥になります。
  #Integer|Float (初期値： 0)
  def z=(arg)
    @draw_option[:z] = arg
  end
  def z()
    @draw_option[:z]
  end

  def shader=(arg)
    @shader = arg
    @draw_option[:shader] = find_control(@shader).entity
  end
  attr_reader  :shader

  #描画時の指定座標x/yに、画像のcenter_x/yで指定した位置が来るように補正されます
  #bool (初期値： false)
  def offset_sync=(arg)
    @draw_option[:offset_sync] = arg
  end
  def offset_sync()
    @draw_option[:offset_sync]
  end

  def initialize(options, yield_block_stack, root_control, parent_control, &block)
    @entity = nil
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

    #可視フラグ（省略時はtrue）
    @visible = (options[:visible] != false)

    super
  end

  def render(offset_x, offset_y, target)
    super(0, 0, @entity)

    #描画オブジェクトを持ち、かつ可視でなければ戻る
    return 0, 0 unless @entity and @visible
    return 0, 0 if @entity.disposed?

    #自エンティティを上位ターゲットに描画
    target.draw_ex( @x + @offset_x + offset_x + check_align_x(),
                    @y + @offset_y + offset_y + check_align_y(), 
                    @entity, 
                    @draw_option)

    return check_float
  end
end

end

end