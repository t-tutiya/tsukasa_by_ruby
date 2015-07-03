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

#文字レンダラベース
class CharControl < Control
  #移動関連モジュール読み込み
  include Movable
  include Drawable

  def initialize(options, system_options)

    super

    #Image生成に必要な各種座標を生成する
    @width, @height, offset_x, offset_y = normalize_image(
                                          options[:char], 
                                          options[:font], 
                                          options[:font_config])

    #描画座標をオフセット値を加味して設定
    @x_pos = @x_pos - offset_x
    @y_pos = @y_pos - offset_y

#TODO：イメージフォントデータ関連が現仕様と乖離しているので一旦コメントアウト
=begin
    #保持オブジェクトの初期化
    #画像が指定されている場合
    if control
      if options[:graph]
        @entity = control.effect_image_font(options[:font_config])
      else
        @entity = control
      end
      
      @width = @entity.width
      @height = @entity.height
      
    else
=end
      #文字用のimageを作成
      @entity = Image.new(@width, @height, [0, 0, 0, 0]) 
      #フォントを描画
      @entity.draw_font_ex(offset_x, 
                            offset_y, 
                            options[:char], 
                            options[:font], 
                            options[:font_config])
#    end
    
    @skip_mode = options[:skip_mode] #スキップモード初期化
  end

  def dispose()
    @entity.dispose
    super
  end

  def normalize_image(char, font, font_config)
    offset_x = offset_y = 0

    #現状での縦幅、横幅を取得
    width = font.get_width(char)
    height = font.size

    #※ボールドの対応はしない

    #イタリックの場合、文字サイズの半分を横幅に追加する。
    if font_config[:italic]
      width += font_config[:size]/2
    end
    #影文字の場合、オフセット分を縦幅、横幅に追加する
    if font_config[:shadow]
      width += font_config[:shadow_x]
      height += font_config[:shadow_y]
    end
    #袋文字の場合、縁サイズの２倍を縦幅、横幅に追加し、縁サイズ分をオフセットに加える。
    if font_config[:edge]
      width += font_config[:edge_width] * 2
      height += font_config[:edge_width] * 2
      offset_x += font_config[:edge_width]
      offset_y += font_config[:edge_width]
    end

    return width , height, offset_x, offset_y
  end
end
