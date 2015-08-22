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

  def initialize(options, inner_options, root_control)

    super
    
    #フォントオブジェクト構築
    #TODO：状況によってCharControlが実行される前に予め作っておいたFontオブジェクトがdiposeされ得るため、CharControlごとにfontオブジェクトを生成することにした。これがパフォーマンス的にありなのかちょっとわからない。
    font = Font.new(options[:size], 
                    options[:fontname],
                    {:weight => options[:weight],
                     :italic => options[:italic]})

    #現状での縦幅、横幅を取得
    @width = font.get_width(options[:char])
    @height = font.size

    #Image生成に必要な各種座標を生成する
    width, height, @offset_x, @offset_y = normalize_image(
                                          @width, 
                                          @height, 
                                          options[:font_config],
                                          options[:italic],
                                          options[:shadow],
                                          options[:edge])
    #文字用のimageを作成
    @entity = Image.new(width, height, [0, 0, 0, 0]) 
    
    #フォントを描画
    @entity.draw_font_ex( @offset_x, 
                          @offset_y, 
                          options[:char], 
                          font, 
                          options[:font_config])
    @skip_mode = options[:skip_mode] #スキップモード初期化

    @align_y = :bottom
  end

  def render(offset_x, offset_y, target, parent_size)
    dx , dy = super(offset_x - @offset_x, offset_y - @offset_y, target, parent_size)
    
    return dx + @offset_x, dy + @offset_y
  end

  def dispose()
    @entity.dispose
    super
  end

  def normalize_image(width, height, font_config, italic, shadow, edge)
    #※ボールドの対応はしない

    #イタリックの場合、文字サイズの半分を横幅に追加する。
    if italic
      width += font_config[:size]/2
    end
    #影文字の場合、オフセット分を縦幅、横幅に追加する
    if shadow
      width += font_config[:shadow_x]
      height += font_config[:shadow_y]
    end
    #袋文字の場合、縁サイズの２倍を縦幅、横幅に追加し、縁サイズ分をオフセットに加える。
    if edge
      width += font_config[:edge_width] * 2
      height += font_config[:edge_width] * 2
      offset_x = font_config[:edge_width]
      offset_y = font_config[:edge_width]
    else
      offset_x = 0
      offset_y = 0
    end

    return width , height, offset_x, offset_y
  end
end
