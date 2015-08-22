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
    font = Font.new(options[:size], 
                    options[:fontname],
                    {:weight => options[:weight],
                     :italic => options[:italic]})

    #現状での縦幅、横幅を取得
    @width = font.get_width(options[:char])
    @height = font.size

    font_config = options[:font_config]

    #イタリックの場合、文字サイズの半分を横幅に追加する。
    if options[:italic]
      width = @width + font_config[:size]/2
    end

    #影文字の場合、オフセット分を縦幅、横幅に追加する
    if options[:shadow]
      width = @width + font_config[:shadow_x]
      height = @height + font_config[:shadow_y]
    end

    #袋文字の場合、縁サイズの２倍を縦幅、横幅に追加し、縁サイズ分をオフセットに加える。
    if options[:edge]
      width = @width + font_config[:edge_width] * 2
      height = @height + font_config[:edge_width] * 2
      @offset_x = -1 * font_config[:edge_width]
      @offset_y = -1 * font_config[:edge_width]
    end

    #文字用のimageを作成
    @entity = Image.new(width, height, [0, 0, 0, 0]) 
    
    #フォントを描画
    @entity.draw_font_ex( -1 * @offset_x, 
                          -1 * @offset_y, 
                          options[:char], 
                          font, 
                          font_config)
    @skip_mode = options[:skip_mode] #スキップモード初期化
    @x_pos = 0
    @y_pos = 0
  end

  def dispose()
    @entity.dispose
    super
  end
end
