#! ruby -E utf-8

require 'dxruby'

require_relative './Image_font_maker'

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

###############################################################################
#汎用テキストマネージャクラス
###############################################################################

class TextPageControl < LayoutControl

  #############################################################################
  #公開インターフェイス
  #############################################################################

#  attr_accessor  :use_image_font
#  attr_accessor  :image_face

  #テキストページ情報

  attr_accessor  :line_spacing  #行間
  attr_accessor  :charactor_pitch #文字間
  attr_accessor  :line_height #行の高さ

  attr_accessor  :indent

  #文字基礎情報

  attr_reader  :size #文字サイズ
  def size=(arg)
    @char_option[:size] = arg
  end
  
  attr_reader  :color #文字色
  def color=(arg)
    @char_option[:color] = arg
  end

  attr_reader  :font_name
  def font_name=(arg)
    @char_option[:font_name] = arg
  end

    #TODO：以下はdxrubyのFont情報と無関係なので管理を分離する
    # :fontname
    #      #指定されたフォント名がレンダリング済みフォントとして登録されている場合
    #      if Image_font.regist?(value.to_s)
    #        #フォント名をイメージフォント名として設定
    #        target[:image_face] = value.to_s
    #        #イメージフォント使用中フラグを立てる
    #        target[:use_image_font] = true
    #      else
    #        #フォント名を設定
    #        target[:fontname] = value.to_s
    #        #イメージフォント使用中フラグをクリア
    #        target[:use_image_font] = false
    #      end

  attr_reader :weight # 太字（bool || integer）
  def weight=(arg)
    @char_option[:weight] = arg
  end
  attr_reader :italic # イタリック（bool）
  def italic=(arg)
    @char_option[:italic] = arg
  end
  attr_reader :z #描画順指定（TODO：反映未確認）
  def z=(arg)
    @char_option[:z] = arg
  end
  attr_reader  :aa   #アンチエイリアスのオンオフ
  def aa=(arg)
    @char_option[:aa] = arg
  end

  #袋文字関連
    
  attr_reader :edge  # 袋文字を描画するかどうかをtrue/falseで指定します。
  def edge=(arg)
    @char_option[:edge] = arg
  end
  attr_reader :edge_color  # 袋文字の枠色を指定します。配列で[R, G, B]それぞれ0～255
  def edge_color=(arg)
    @char_option[:edge_color] = arg
  end
  attr_reader :edge_width  # 袋文字の枠の幅を0～の数値で指定します。1で1ピクセル
  def edge_width=(arg)
    @char_option[:edge_width] = arg
  end
  attr_reader :edge_level  # 袋文字の枠の濃さを0～の数値で指定します。大きいほど濃くなりますが、幅が大きいほど薄くなります。値の制限はありませんが、目安としては一桁ぐらいが実用範囲でしょう。
  def edge_level=(arg)
    @char_option[:edge_level] = arg
  end

  #影文字関連

  attr_reader :shadow    # 影を描画するかどうかをtrue/falseで指定します
  def shadow=(arg)
    @char_option[:shadow] = arg
  end
  attr_reader :shadow_edge   # edgeがtrueの場合に、枠の部分に対して影を付けるかどうかをtrue/falseで指定します。trueで枠の影が描かれます
  def shadow_edge=(arg)
    @char_option[:shadow_edge] = arg
  end
  attr_reader :shadow_color    # 影の色を指定します。配列で[R, G, B]、それぞれ0～255
  def shadow_color=(arg)
    @char_option[:shadow_color] = arg
  end
  attr_reader :shadow_x    # 影の位置を相対座標で指定します。+1は1ピクセル右になります
  def shadow_x=(arg)
    @char_option[:shadow_x] = arg
  end
  attr_reader :shadow_y    # 影の位置を相対座標で指定します。+1は1ピクセル下になります
  def shadow_y=(arg)
    @char_option[:shadow_y] = arg
  end


  #ルビ関連情報

  attr_accessor  :rubi_size #ルビサイズ
  def rubi_size=(arg)
    @rubi_option[:size] = arg
  end

  attr_accessor  :rubi_offset_x #ルビ幅
  def rubi_offset_x=(arg)
    @rubi_option[:offset_x] = arg
  end

  attr_accessor  :rubi_offset_y
  def rubi_offset_y=(arg)
    @rubi_option[:offset_y] = arg
  end

  attr_accessor  :rubi_pitch
  def rubi_pitch=(arg)
    @rubi_option[:charactor_pitch] = arg
  end

  def initialize(argument, options, inner_options, root_control)
    #レンダリング済みフォント使用中かどうか
    @use_image_font = options[:use_image_font] || false
    #レンダリング済みフォントのフォント名
    @image_face = options[:image_face] || nil

    @line_spacing = options[:line_spacing] || 12   #行間の幅
    @charactor_pitch = options[:charactor_pitch ] || 3 #文字間の幅
    @line_height = options[:line_height] || 32    #行の高さ

    #文字情報
    @char_option = {
      :size => options[:size] || 24,                 #フォントサイズ
      :font_name => options[:font_name] || "ＭＳ 明朝",        #フォント名
      :weight => options[:bold] || false, #太字
      :italic => options[:italic] || false, #イタリック

      :color => options[:color] || [255,255,255],     #色
      :aa => options[:aa] || true,                 #アンチエイリアスのオンオフ

      :edge => options[:edge] || true,               #縁文字
      :shadow => options[:shadow] || true,            #影

      :edge_color => options[:edge_color] || [0, 0, 0], #縁文字：縁の色
      :edge_width => options[:edge_width] || 2,            #縁文字：縁の幅
      :edge_level => options[:edge_level] || 16,           #縁文字：縁の濃さ

      :shadow_color => options[:shadow_color] || [0, 0, 0],    #影：影の色
      :shadow_x => options[:shadow_x] || 0,              #影:オフセットＸ座標
      :shadow_y => options[:shadow_y] || 0,              #影:オフセットＹ座標
    }

    #ルビ文字情報
    @rubi_option = {
      :size => options[:rubi_size] || 12,            #ルビ文字のフォントサイズ
      #ルビの表示開始オフセット値
      :offset_x => options[:rubi_offset_x] || 0,
      :offset_y => options[:rubi_offset_y] || -1 * (options[:rubi_size] || 12),
      #ルビ文字のベース文字からのピッチ幅
      :charactor_pitch => options[:rubi_pitch] || 12,
      #ルビの待ちフレーム数
      :wait_frame => options[:rubi_wait_frame] || 2 
    }

    #次に描画する文字のＸ座標とインデントＸ座標オフセットをリセット
    @indent = options[:indent] || 0 

    #文字ＩＤ
    @charactor_id = 0

    super

    @function_list[:_CHAR_RENDERER_] =options[:_CHAR_RENDERER_] || Proc.new(){}
    @function_list[:_CHAR_WAIT_] = options[:_CHAR_WAIT_] || Proc.new(){}
    @function_list[:_LINE_WAIT_] = options[:_LINE_WAIT_] || Proc.new(){}

    #次のアクティブ行コントロールを追加  
    interrupt_command(:_CREATE_, 
                      :LayoutControl,
                      {
                        :width => @width,
                        :height => @line_height,
                        :float_x => :bottom, 
                        :float_y => :bottom
                      }, 
                      {})
  end

  def serialize(control_name = :TextPageControl, **options)
    
    options.update({
      :line_spacing => @line_spacing,
      :charactor_pitch => @charactor_pitch,
      :line_height => @line_height,

      :indent => @indent,

      :char_option => @char_option,
      :rubi_option => @rubi_option,
    })

    return super(control_name, options)
  end

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #############################################################################
  #文字列関連コマンド
  #############################################################################

  #charコマンド
  #指定文字（群）を描画チェインに連結する
  def command__CHAR_(argument, options, inner_options)
    #文字コントロールを生成する
    @control_list.last.push_command(:_CREATE_, 
                                    :CharControl, 
                                    {
                                      :align_y => :bottom,
                                      :charactor => argument,
                                      :command_list=> options[:command_list],
                                      :float_x => :left,
                                      :id => @charactor_id
                                    }.merge(@char_option), 
                                    {
                                      :block =>@function_list[:_CHAR_RENDERER_]
                                    })

    #文字のＩＤを更新
    @charactor_id += 1

    #文字幅スペーサーを生成する
    @control_list.last.push_command(:_CREATE_, 
                                    :LayoutControl, 
                                    {
                                      :width => @charactor_pitch,
                                      :height => @line_height,
                                      :align_y => :bottom,
                                      :float_x => :left}, 
                                    {})
  end

  #textコマンド
  #指定文字列を描画チェインに連結する
  def command__TEXT_(argument, options, inner_options)
    command_list = Array.new

    #第１引数が設定されていない場合
    unless argument
      result = ""
      #キーで指定されたデータストアのデータを文字列とする
      options.each do |key, value|
        result = @root_control.send(key)[value]
      end
      argument = result.to_s
    end

    #第１引数がシンボルの場合
    if argument.instance_of?(Symbol)
      #キーで指定された一時データストアのデータを文字列とする
      argument = @root_control.send(:_TEMP_)[argument]
    end

    #イメージフォントを使うかどうか
    if @use_image_font
      char_command = :image_char
    else
      char_command = :_CHAR_
    end

    #文字列を分解してcharコマンドに変換する
    argument.to_s.each_char do |ch|
      #１文字分の出力コマンドをスタックする
      command_list.push([char_command, ch, {}, inner_options])
      #文字待機処理をスタックする
      command_list.push([:_CALL_, :_CHAR_WAIT_, {}, inner_options])
    end

    #展開したコマンドをスタックする
    eval_commands(command_list)
  end

  def command__RUBI_(argument, options, inner_options)
    #ルビを出力するTextPageControlを生成する
    rubi_layout =[:_CREATE_, 
                  :TextPageControl, 
                  { :command_list => [[:_TEXT_, argument, {},inner_options]],
                    :x => @rubi_option[:offset_x],
                    :y => @rubi_option[:offset_y],
                    :height=> @rubi_option[:size],
                    :size => @rubi_option[:size],
                    :line_height => @rubi_option[:size],
                    :font_name => @char_option[:font_name],
                    :line_spacing => 0,
                    :charactor_pitch => @rubi_option[:charactor_pitch],
                    :_LINE_WAIT_ => @function_list[:_LINE_WAIT_],
                    :_CHAR_WAIT_ => @function_list[:_CHAR_WAIT_],
                    :_CHAR_RENDERER_ => @function_list[:_CHAR_RENDERER_]},
                  {}]

    #TextPageControlをベース文字に登録する。
    @control_list.last.push_command(:_CREATE_, 
                                    :LayoutControl, 
                                    {
                                      :width => 0,
                                      :height => @size,
                                      :command_list => [rubi_layout],
                                      :float_x => :left
                                    }, 
                                    {})
  end

  #line_feedコマンド
  #改行処理（CR＋LF）
  def command__LINE_FEED_(argument, options, inner_options)

    #インデントスペーサーの作成
    if @indent > 0
      command_list =[
                      [ :_CREATE_, 
                        :LayoutControl, 
                        {
                          :width => @indent,
                          :height => @line_height,
                          :float_x => :left
                        }, 
                        inner_options
                      ]
                    ]
    else
      command_list = nil
    end

    eval_commands([
                    #行間待機処理を設定する
                    [:_CALL_, :_LINE_WAIT_, {}, inner_options],
                    #次のアクティブ行コントロールを追加  
                    [ :_CREATE_, 
                      :LayoutControl, 
                      {
                        :width => @width,
                        :height => @line_spacing,
                        :float_x => :bottom, 
                        :float_y => :bottom
                      }, 
                      inner_options
                    ],
                    #行間ピッチ分の無形コントロールを追加
                    [ :_CREATE_, 
                      :LayoutControl, 
                      {
                        :width => @width,
                        :height => @line_height,
                        #インデント用無形コントロール
                        :command_list => command_list, 
                        :float_x => :bottom, 
                        :float_y => :bottom
                      }, 
                      inner_options
                    ],
                  ])
    #文字ＩＤの連番をリセット
    @charactor_id = 0
  end

  #flushコマンド
  #メッセージレイヤの消去
  def command__FLUSH_(argument, options, inner_options)
    #子コントロールをクリアする
    @control_list.each do |control|
      control.interrupt_command(:_DELETE_, argument, options, {})
    end

    #次のアクティブ行コントロールを追加  
    interrupt_command(:_CREATE_, 
                      :LayoutControl, 
                      {
                        :width => @width,
                        :height => @line_height,
                        :float_x => :bottom, 
                        :float_y => :bottom
                      }, 
                      inner_options)
    
    #文字ＩＤの連番をリセット
    @charactor_id = 0
  end

  #############################################################################
  #レンダリング済みフォントデータファイル登録コマンド
  #############################################################################

  #image_charコマンド
  #指定文字（群）のレンダリング済みフォントを描画チェインに連結する
  def command_image_char(argument, options, inner_options) #改修前
    raise
#以下旧仕様なので動作しない
#TODO：イメージフォントデータ関連が現仕様と乖離しているので一旦コメントアウト
=begin
    #文字コントロールを生成する
    interrupt_command(:_CREATE_, {
                    :_ARGUMENT_ => :CharControl, 
                   :x => @next_char_x + @margin_x,
                   :y => @next_char_y + @margin_y + @line_height - @font.size, #行の高さと文字の高さは一致していないかもしれないので、下端に合わせる
                   :char => "",
                   :font => @font,
                   :font_config => @font_config,
                   :graph => true,
                   },
                   {:block => @function_list[:_CHAR_RENDERER_]},
#                   @font.glyph(options[:char].to_s)
                 )

    #描画座標を１文字＋文字ピッチ分進める
    @next_char_x += @font.get_width(options[:char].to_s) + 
                    @charactor_pitch
=end
  end

  #graphコマンド
  #指定画像を描画チェインに連結する
  def command_graph(argument, options, inner_options)#改修前
    #以下旧仕様で動かない
    raise
=begin
    #:is_charが省略されている場合初期値を設定する
    options[:is_char] = true if !options.key?(:is_char)

    #指定された画像を読み込む
    image = Image.load(options[:file_path])

    #:color_keyオプションが設定されている場合
    if options.key?(:color_key)
      #抜き色を設定する
      image.set_color_key(options[:color_key])
    end
    #文字レンダラオブジェクトを生成し、描画チェインに連結する
    #TODO：こっち未修正
    @control_list.push(CharControl.new(
                    {:x => @next_char_x + @margin_x,
                     :y => @next_char_y + @margin_y + @line_height - @font.size, #行の高さと文字の高さは一致していないかもしれないので、下端に合わせる
                     :char => "",
                     :font => @font,
                     :font_config => @font_config,
                     :graph => options[:is_char]},
                    image
                  ))
    #描画座標を画像横幅＋文字ピッチ分進める
    @next_char_x += image.width + @charactor_pitch

    #:waitコマンドを追加でスタックする（待ち時間は遅延評価とする）
    #TODO:恐らくこのwaitもスクリプトで定義可能でないとマズイ
    interrupt_command(:_WAIT_, 
                          {:count => @wait_frame,
                           :key_down => K_RCONTROL,
                           :key_push => K_SPACE,
                           }, inner_options)
=end
  end


  #レンダリング済みフォントデータファイルを登録する
  def command_map_image_font(argument, options, inner_options)#改修前
    raise
    #レンダリング済みフォントデータファイルを任意フォント名で登録
    Image_font.regist(options[:font_name].to_s, options[:file_path].to_s)
  end
end
