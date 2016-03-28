#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver1.2(2016/3/1)
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

###############################################################################
#汎用テキストマネージャクラス
###############################################################################

class CharControl < RenderTargetControl
  ############################################################################
  #書体情報
  ############################################################################

  # 文字サイズ
  attr_reader :size    
  def size=(arg)
    @size = arg
    @option_update = true
  end

  #書体
  attr_reader :font_name
  def font_name=(arg)
    @font_name = arg
    @option_update = true
  end

  # 太字（bool|integer）にするかどうか。数字なら太さ
  attr_reader :weight    
  def weight=(arg)
    @weight = arg
    @option_update = true
  end

  # イタリック（bool）にするかどうか
  attr_reader :italic  
  def italic=(arg)
    @italic = arg
    @option_update = true
  end

  # 文字
  attr_reader :charactor    
  def charactor=(arg)
    @charactor = arg
    @option_update = true
  end

  ############################################################################
  #パラメーター
  ############################################################################

  #アンチエイリアスのオンオフ
  def aa=(arg)
    @font_draw_option[:aa] = arg
    @option_update = true
  end
  def aa
    @font_draw_option[:aa]
  end

  # 文字色
  def color=(arg)
    @font_draw_option[:color] = arg
    @option_update = true
  end
  def color
    @font_draw_option[:color]
  end

  ############################################################################
  #袋文字関連
  ############################################################################

  #袋文字を描画するかどうかをtrue/falseで指定します。
  def edge=(arg)
    @font_draw_option[:edge] = arg
    @option_update = true
  end
  def edge
    @font_draw_option[:edge]
  end

  #袋文字の枠色を指定します。配列で[R, G, B]それぞれ0～255
  def edge_color=(arg)
    @font_draw_option[:edge_color] = arg
    @option_update = true
  end
  def edge_color
    @font_draw_option[:edge_color]
  end

  #袋文字の枠の幅を0～の数値で指定します。1で1ピクセル
  def edge_width=(arg)
    @font_draw_option[:edge_width] = arg
    @option_update = true
  end
  def edge_width
    @font_draw_option[:edge_width]
  end

  #袋文字の枠の濃さを0～の数値で指定します。大きいほど濃くなりますが、幅が大きいほど薄くなります。値の制限はありませんが、目安としては一桁ぐらいが実用範囲でしょう。
  def edge_level=(arg)
    @font_draw_option[:edge_level] = arg
    @option_update = true
  end
  def edge_level
    @font_draw_option[:edge_level]
  end

  ############################################################################
  #影文字関連
  ############################################################################

  #影を描画するかどうかをtrue/falseで指定します
  def shadow=(arg)
    @font_draw_option[:shadow] = arg
    @option_update = true
  end
  def shadow
    @font_draw_option[:shadow]
  end

  #edgeがtrueの場合に、枠の部分に対して影を付けるかどうかをtrue/falseで指定します。trueで枠の影が描かれます
  def shadow_edge=(arg)
    @font_draw_option[:shadow_edge] = arg
    @option_update = true
  end
  def shadow_edge
    @font_draw_option[:shadow_edge]
  end

  #影の色を指定します。配列で[R, G, B]、それぞれ0～255
  def shadow_color=(arg)
    @font_draw_option[:shadow_color] = arg
    @option_update = true
  end
  def shadow_color
    @font_draw_option[:shadow_color]
  end

  #影の位置を相対座標で指定します。+1は1ピクセル右になります
  def shadow_x=(arg)
    @font_draw_option[:shadow_x] = arg
    @option_update = true
  end
  def shadow_x
    @font_draw_option[:shadow_x]
  end

  #影の位置を相対座標で指定します。+1は1ピクセル下になります
  def shadow_y=(arg)
    @font_draw_option[:shadow_y] = arg
    @option_update = true
  end
  def shadow_y
    @font_draw_option[:shadow_y]
  end

  #############################################################################
  #公開インターフェイス
  #############################################################################

  def initialize(options, yield_block_stack, root_control, parent_control, &block)
    @font_draw_option = {}

    #フォントサイズ
    self.size = options[:width] = options[:height] = options[:size] || 24 

    self.font_name = options[:font_name] || "ＭＳ 明朝" #フォント名

    self.charactor = options[:charactor] || raise #描画文字

    self.weight = options[:weight] || false #太字
    self.italic = options[:italic] || false  #イタリック

    self.color = options[:color] || [255,255,255] #色
    self.aa = options[:aa] || true #アンチエイリアスのオンオフ

    self.edge = options[:edge] || true #縁文字
    self.shadow = options[:shadow] || true #影

    self.edge_color = options[:edge_color] || [0, 0, 0] #縁文字：縁の色
    self.edge_width = options[:edge_width] || 2 #縁文字：縁の幅
    self.edge_level = options[:edge_level] || 16 #縁文字：縁の濃さ

    self.shadow_color = options[:shadow_color] || [0, 0, 0] #影：影の色
    self.shadow_x = options[:shadow_x] || 0 #影:オフセットＸ座標
    self.shadow_y = options[:shadow_y] || 0 #影:オフセットＹ座標
    self.shadow_edge = options[:shadow_edge] || false #影：影の縁文字

    super
  end

  def update(mouse_pos_x, mouse_pos_y, index)
    if @option_update
      #文字が設定されていなければ戻る
      return super unless @charactor

      #現状での縦幅、横幅を取得
      width = Font.new( @size, @font_name, 
                            { :weight=>@weight, 
                              :italic=>@italic}).get_width(@charactor)
      if width == 0
        width = 1
      end

      height = @size

      #イタリックの場合、文字サイズの半分を横幅に追加する。
      if @italic
        width += @font_draw_option[:size]/2
      end

      #影文字の場合、オフセット分を縦幅、横幅に追加する
      if @font_draw_option[:shadow]
        width += @font_draw_option[:shadow_x]
        height += @font_draw_option[:shadow_y]
      end

      #袋文字の場合、縁サイズの２倍を縦幅、横幅に追加。
      if @font_draw_option[:edge]
        width += @font_draw_option[:edge_width] * 2
        height += @font_draw_option[:edge_width] * 2
      end

     self.width = width
     self.height = height

      @control_list.clear

      #文字用のimageを作成
      _CREATE_( :ImageControl, 
                {
                  width: width, 
                  height: height,
                  size: @size,
                  font_name: @font_name,
                  weight: @weight,
                  italic: @italic,
                  charactor: @charactor,
                  draw_option: @font_draw_option,
                  font_color: @font_draw_option[:color]
                },
                {}) do |arg, options|
        #フォントを描画
        _TEXT_  x:0, y:0, 
                text: options[:charactor], 
                size: options[:size],
                font_name: options[:font_name],
                weight: options[:weight],
                italic: options[:italic],
                color: options[:font_color],
                option: options[:draw_option]
      end
      @option_update = false
    end

    return super
  end

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private
end
