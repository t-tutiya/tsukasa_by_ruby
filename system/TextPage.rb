#! ruby -E utf-8

###############################################################################
#TSUKASA for DXRuby ver2.2(2017/1/28)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2017> <tsukasa TSUCHIYA>
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

require_relative './Layout.rb'

module Tsukasa

class TextPage < Layout

  #############################################################################
  #公開インターフェイス
  #############################################################################

  #テキストページ情報

  attr_accessor  :line_spacing  #行間
  attr_accessor  :character_pitch #文字間
  attr_accessor  :line_height #行の高さ

  attr_accessor  :indent

  #文字基礎情報

  #文字サイズ
  def size()
    @char_option[:size]
  end
  def size=(arg)
    @char_option[:size] = arg
  end
  
  #文字色
  def color()
    @char_option[:color]
  end
  def color=(arg)
    @char_option[:color] = arg
  end

  #フォント名
  def font_name()
    @char_option[:font_name]
  end
  def font_name=(arg)
    @char_option[:font_name] = arg
  end

  # 太字（bool || integer）
  def weight()
    @char_option[:weight]
  end
  def weight=(arg)
    @char_option[:weight] = arg
  end

  # イタリック（bool）
  def italic()
    @char_option[:italic]
  end
  def italic=(arg)
    @char_option[:italic] = arg
  end

  #描画順指定（TODO：反映未確認）
  def z()
    @char_option[:z]
  end
  def z=(arg)
    @char_option[:z] = arg
  end

  #アンチエイリアスのオンオフ
  def aa()
    @char_option[:aa]
  end
  def aa=(arg)
    @char_option[:aa] = arg
  end

  #袋文字関連
    
  # 袋文字を描画するかどうかをtrue/falseで指定します。
  def edge()
    @char_option[:edge]
  end
  def edge=(arg)
    @char_option[:edge] = arg
  end

  # 袋文字の枠色を指定します。配列で[R, G, B]それぞれ0～255
  def edge_color()
    @char_option[:edge_color]
  end
  def edge_color=(arg)
    @char_option[:edge_color] = arg
  end

  # 袋文字の枠の幅を0～の数値で指定します。1で1pixcel
  def edge_width()
    @char_option[:edge_width]
  end
  def edge_width=(arg)
    @char_option[:edge_width] = arg
  end

  # 袋文字の枠の濃さを0～の数値で指定します。大きいほど濃くなりますが、幅が大きいほど薄くなります。値の制限はありませんが、目安としては一桁ぐらいが実用範囲でしょう。
  def edge_level()
    @char_option[:edge_level]
  end
  def edge_level=(arg)
    @char_option[:edge_level] = arg
  end

  #影文字関連

  # 影を描画するかどうかをtrue/falseで指定します
  def shadow()
    @char_option[:shadow]
  end
  def shadow=(arg)
    @char_option[:shadow] = arg
  end

  # edgeがtrueの場合に、枠の部分に対して影を付けるかどうかをtrue/falseで指定します。trueで枠の影が描かれます
  def shadow_edge()
    @char_option[:shadow_edge]
  end
  def shadow_edge=(arg)
    @char_option[:shadow_edge] = arg
  end

  # 影の色を指定します。配列で[R, G, B]、それぞれ0～255
  def shadow_color()
    @char_option[:shadow_color]
  end
  def shadow_color=(arg)
    @char_option[:shadow_color] = arg
  end

  # 影の位置を相対座標で指定します。+1は1ピクセル右になります
  def shadow_x()
    @char_option[:shadow_x]
  end
  def shadow_x=(arg)
    @char_option[:shadow_x] = arg
  end

  # 影の位置を相対座標で指定します。+1は1ピクセル下になります
  def shadow_y()
    @char_option[:shadow_y]
  end
  def shadow_y=(arg)
    @char_option[:shadow_y] = arg
  end


  #ルビ関連情報

  #ルビサイズ
  def rubi_size()
    @rubi_option[:size]
  end
  def rubi_size=(arg)
    @rubi_option[:size] = arg
  end

  #ルビオフセットＸ座標
  def rubi_offset_x()
    @rubi_option[:offset_x]
  end
  def rubi_offset_x=(arg)
    @rubi_option[:offset_x] = arg
  end

  #ルビオフセットＹ座標
  def rubi_offset_y()
    @rubi_option[:offset_y]
  end
  def rubi_offset_y=(arg)
    @rubi_option[:offset_y] = arg
  end

  #ルビ文字幅
  def rubi_pitch()
    @rubi_option[:character_pitch]
  end
  def rubi_pitch=(arg)
    @rubi_option[:character_pitch] = arg
  end

  def initialize(system, options, &block)
    @line_spacing = options[:line_spacing] || 12   #行間の幅
    @character_pitch = options[:character_pitch ] || 0 #文字間の幅
    @line_height = options[:line_height] || 32    #行の高さ

    @next_char_x = 0 #次のCharの描画X座標
    @next_line_y = 0 #次の行の描画Y座標

    #文字情報
    @char_option = {
      :size => options[:size] || 24,                 #フォントサイズ
      :font_name => options[:font_name] || "ＭＳ 明朝",        #フォント名
      :weight => options[:bold] || false, #太字
      :italic => options[:italic] || false, #イタリック

      :color => options[:color] || [255,255,255],     #色
      :aa => (options[:aa] != false),            #アンチエイリアスのオンオフ

      :edge => (options[:edge] == true), #縁文字
      :shadow => (options[:shadow] == true),       #影

      :edge_color => options[:edge_color] || [0, 0, 0], #縁文字：縁の色
      :edge_width => options[:edge_width] || 2,            #縁文字：縁の幅
      :edge_level => options[:edge_level] || 16,           #縁文字：縁の濃さ

      :shadow_color => options[:shadow_color] || [255, 255, 255],   #影：影の色
      :shadow_x => options[:shadow_x] || 8,              #影:オフセットＸ座標
      :shadow_y => options[:shadow_y] || 8,              #影:オフセットＹ座標
      :z => options[:z] || 1000000, #描画順
    }

    #ルビ文字情報
    @rubi_option = {
      :size => options[:rubi_size] || 12,            #ルビ文字のフォントサイズ
      #ルビの表示開始オフセット値
      :offset_x => options[:rubi_offset_x] || 0,
      :offset_y => options[:rubi_offset_y] || -12,
      #ルビ文字のベース文字からのピッチ幅
      :character_pitch => options[:rubi_pitch] || 12,
      #ルビの待ちフレーム数
      :wait_frame => options[:rubi_wait_frame] || 2 
    }

    #次に描画する文字のＸ座標とインデントＸ座標オフセットをリセット
    @indent = options[:indent] || 0 

    super

    @function_list[:_CHAR_RENDERER_] = Proc.new(){}
    @function_list[:_CHAR_WAIT_] = Proc.new(){}
    @function_list[:_LINE_WAIT_] = Proc.new(){}

    #次のアクティブ行コントロールを追加  
    unshift_command(:_CREATE_, 
                    nil,
                    nil,
                    {
                      _ARGUMENT_: :Layout, 
                      width: @width,
                      height: @line_height,
                      y: @next_line_y
                    })

    #その次の行コントロールのY座標を生成
    @next_line_y += (@line_height + @line_spacing)
  end

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #############################################################################
  #文字列関連コマンド
  #############################################################################

  #charコマンド
  #指定文字（群）を文字列チェインに連結する。
  def _INSERT_CHAR_(_ARGUMENT_: nil, image_path: nil)
    #文字コントロールを生成する
    @control_list.last.push_command(:_CREATE_, nil, nil,
                                {
                                  :_ARGUMENT_ => :Char, 
                                  :offset_x => @character_pitch,
                                  :char => _ARGUMENT_,
                                  :x => @next_char_x, 
                                  :y => @line_height - @char_option[:size],
                                  :image_path => image_path
                                }.merge(@char_option),
                                &@function_list[:_CHAR_RENDERER_]
                               )

    #文字待機処理をスタックする
    unshift_command(:_CHAR_WAIT_)

    #次の文字の描画X座標を生成
    @next_char_x += DXRuby::Font.new( @char_option[:size], 
                          @char_option[:font_name], 
                          { :weight=>@char_option[:weight], 
                            :italic=>@char_option[:italic],
                            :auto_fitting=>true }).get_width(_ARGUMENT_ || "")
  end

  #外字画像を文字列チェインに連結する。
  def _INSERT_CHAR_IMAGE_(_ARGUMENT_: nil, width: 0, height: 0)
    #文字コントロールを生成する
    @control_list.last.push_command(:_CREATE_, nil, nil,
                                {
                                  :_ARGUMENT_ => :Char, 
                                  :offset_x => @character_pitch,
                                  :image_path => _ARGUMENT_,
                                  :x => @next_char_x, 
                                  :y => @line_height - height,
                                }.merge(@char_option),
                                &@function_list[:_CHAR_RENDERER_]
                               )

    #文字待機処理をスタックする
    unshift_command(:_CHAR_WAIT_)

    #次の文字の描画X座標を生成
    @next_char_x += width
  end


  #指定したコマンドブロックを文字列の末端に追加する
  def _INSERT_COMMAND_(width: 0, height: 0, skip: false, **)
    @control_list.last.push_command_block(@temporary_command_block, 
                                          @temporary_yield_stack,
                                          {
                                            x: @next_char_x,
                                            y: @line_height - height
                                          })

    #文字待機処理をスタックする
    unshift_command(:_CHAR_WAIT_)
    
    unless skip
      @next_char_x += width
    end
  end

  #textコマンド
  #指定文字列を描画チェインに連結する
  def _TEXT_(_ARGUMENT_:)
    #文字列を分解してcharコマンドに変換する
    _ARGUMENT_.to_s.reverse.each_char do |ch|
      #１文字分の出力コマンドをスタックする
      unshift_command(:_INSERT_CHAR_, {_ARGUMENT_: ch})
    end
  end

  def _RUBI_(_ARGUMENT_:)
    #TextPageをベース文字に登録する。
    @control_list.last.push_command(:_CREATE_, nil, nil, 
                                    {
                                      :_ARGUMENT_ => :Layout, 
                                      :width => 0,
                                      :height => @size,
                                    })

    #ルビを出力するTextPageを生成する
    @control_list.last.push_command(:_SEND_, {_ARGUMENT_: -1, 
      text: _ARGUMENT_,
      x: @rubi_option[:offset_x],
      y: @rubi_option[:offset_y],
      size:  @rubi_option[:size],
      character_pitch: @rubi_option[:character_pitch],
      font_name: @char_option[:font_name],
      _LINE_WAIT_: @function_list[:_LINE_WAIT_],
      _CHAR_WAIT_: @function_list[:_CHAR_WAIT_],
      _CHAR_RENDERER_:  @function_list[:_CHAR_RENDERER_]
    }) do |
      text:, 
      x:,
      y:,
      size:, 
      character_pitch:, 
      font_name:, 
      _LINE_WAIT_:, 
      _CHAR_WAIT_:,
      _CHAR_RENDERER_:|
      _CREATE_ :TextPage, 
        x: x,
        y: y,
        height: size,
        size: size,
        line_height: size,
        font_name: font_name,
        line_spacing: 0,
        character_pitch: character_pitch do
        _DEFINE_(:_LINE_WAIT_, &_LINE_WAIT_)
        _DEFINE_(:_CHAR_WAIT_, &_CHAR_WAIT_)
        _DEFINE_(:_CHAR_RENDERER_, &_CHAR_RENDERER_)
        _TEXT_ text
      end
    end
    
    end

  #line_feedコマンド
  #改行処理（CR＋LF）
  def _LINE_FEED_(**)
    #インデント用無形コントロールの追加
    unshift_command(:_GET_, _ARGUMENT_: [:indent, :line_height]) do 
      |indent:, line_height:|
      _SEND_ -1 do
        _CREATE_ :Layout, width: indent, height: line_height
      end
    end

    #次のアクティブ行コントロールの追加  
    unshift_command(:_CREATE_, 
                    {
                      :_ARGUMENT_ => :Layout, 
                      :width => @width,
                      :height => @line_height,
                      :y => @next_line_y,
                    })

    #行間待機処理を設定する
    unshift_command(:_LINE_WAIT_)

    #文字描画X座標をリセット
    @next_char_x = @indent
    #その次の行コントロールのY座標を生成
    @next_line_y += (@line_height + @line_spacing)
  end

  #flushコマンド
  #メッセージレイヤの消去
  def _FLUSH_(**)
    #子コントロールをクリアする
    @control_list.each do |control|
      control._DELETE_()
    end
    @control_list.clear

    @next_char_x = 0
    @next_line_y = 0

    #次のアクティブ行コントロールを追加  
    unshift_command(:_CREATE_, 
                    {
                      :_ARGUMENT_ => :Layout, 
                      :width => @width,
                      :height => @line_height,
                      :y => @next_line_y 
                    })

    #その次の行コントロールのY座標をリセット
    @next_line_y = @line_height + @line_spacing
  end
end

end