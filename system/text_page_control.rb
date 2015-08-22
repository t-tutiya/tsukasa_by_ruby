#! ruby -E utf-8

require 'dxruby'

require_relative './script_compiler.rb'
require_relative './Image_font_maker'
require_relative './char_control'

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

###############################################################################
#汎用テキストマネージャクラス
###############################################################################

class TextPageControl < Control
  include Movable #移動関連モジュール
  include Drawable #描画関連モジュール

  #############################################################################
  #公開インターフェイス
  #############################################################################

  #attr_accessor  :font_config #フォント設定
  def font_config=(hash)
    @font_config.merge!(hash)
#    reset_font()
  end
  #attr_accessor  :default_font_config #デフォルトフォント設定 #現在機能していない
  def default_font_config=(hash)
    @default_font_config.merge!(hash)
  end
    #基礎情報
    # :size 文字サイズ
    # :color 文字色
    # :bold 太字（bool）
    # :italic イタリック（bool）
    # :z  #描画順指定（TODO：反映未確認）
    #
    #袋文字関連
    # :edge  #袋文字を描画するかどうかをtrue/falseで指定します。
    # :edge_color  #袋文字の枠色を指定します。配列で[R, G, B]それぞれ0～255
    # :edge_width  #袋文字の枠の幅を0～の数値で指定します。1で1ピクセル
    # :edge_level  #袋文字の枠の濃さを0～の数値で指定します。大きいほど濃くなりますが、幅が大きいほど薄くなります。値の制限はありませんが、目安としては一桁ぐらいが実用範囲でしょう。
    #
    #影文字関連
    # :shadow  #影を描画するかどうかをtrue/falseで指定します
    # :shadow_edge #edgeがtrueの場合に、枠の部分に対して影を付けるかどうかをtrue/falseで指定します。trueで枠の影が描かれます
    # :shadow_color  #影の色を指定します。配列で[R, G, B]、それぞれ0～255
    # :shadow_x  #影の位置を相対座標で指定します。+1は1ピクセル右になります
    # :shadow_y  #影の位置を相対座標で指定します。+1は1ピクセル下になります
    #
    #スケール変換関連
    #TODO：CharConrol#normarize_imageが処理をフックして、下記プロパティの中で反映されない物がありそう。スケールとか
    # :scalex  #横の拡大率
    # :scaley  #縦の拡大率
    # :centerx  #回転、拡大の中心点。省略すると一番左になります。
    # :centery  #回転、拡大の中心点。省略すると一番上になります。
    # :alpha  #アルファ値(0～255)。省略すると255になります。
    # :blend  #:alpha、:add、:add2、:sub、:sub2で合成方法を指定します。省略すると:alphaとなります。
    #   :addはソースにアルファ値を、
    #   :add2は背景に255-アルファ値を適用します。
    #   :subはアルファ値を全ての色の合成に、
    #   :sub2はRGBの色をそれぞれ別々に合成に適用します。
    # :angle  #360度系で画像の回転角度を指定します。拡大率と同時に指定した場合は拡大率が先に適用されます。
    # :aa  #アンチエイリアスのオンオフ

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
    #ルビ関連情報
    # :rubi_size ルビサイズ
    # :rubi_pitch ルビ幅

  #attr_accessor  :style_config #書式設定 #現在機能していない
  def style_config=(hash)
    @style_config.merge!(hash)
  end
  #attr_accessor  :default_style_config #デフォルト書式設定 #現在機能していない
  def default_style_config=(hash)
    @default_style_config.merge!(hash)
  end
    # :line_spacing  #行間
    # :charactor_pitch #文字間
    # :line_height #行の高さ
    # :wait_frame #一文字置きの待機フレーム
    # :line_feed_wait_frame #改行時の待機フレーム

  def initialize(options, inner_options, root_control)
    @child_controls_draw_to_entity = false
    @char_renderer = options[:char_renderer]

    font_config  = options[:font_config]  || {} #フォントコンフィグ
    style_config = options[:style_config] || {} #スタイルコンフィグ

    #draw_font_exに渡すオプション
    @default_font_config = {
      :color => [255,255,255],     #色
      :aa => true,                 #アンチエイリアスのオンオフ

      :edge_color => [48, 48, 48], #縁文字：縁の色
      :edge_width => 2,            #縁文字：縁の幅
      :edge_level => 16,           #縁文字：縁の濃さ

      :shadow_color => [0,0,0],    #影：影の色
      :shadow_x => 1,              #影:オフセットＸ座標
      :shadow_y => 1,              #影:オフセットＹ座標
    }

    @edge = options[:edge] || true               #縁文字
    @shadow = options[:shadow] || false            #影

    #影：縁まで影を落とすか
    #TODO：現行コードでは未使用
    @shadow_edge = options[:shadow_edge] || false      

    #レンダリング済みフォント使用中かどうか
    @use_image_font = options[:use_image_font] || false
    #レンダリング済みフォントのフォント名
    @image_face = options[:image_face] || nil

    #フォントオブジェクト用の情報
    @size = options[:size] || 24                 #フォントサイズ
    @fontname = options[:fontname] || "ＭＳ 明朝"        #フォント名
    @bold = options[:bold] || false #太字
    @italic = options[:italic] || false #イタリック

    #font_configのデフォルト値を更新
    @default_font_config.merge!(font_config)

    #fong_configの初期化
    command_reset_font_config(nil, nil)

    #スタイルの初期設定
    @default_style_config = {
      :line_spacing => 12,   #行間の幅
      :charactor_pitch => 3, #文字間の幅
      :line_height => 32,    #行の高さ
    }

    #文字描画後の待ちフレーム数
    @wait_frame = options[:wait_frame] || 2 
    #改行後の待ちフレーム数
    @line_feed_wait_frame = options[:line_feed_wait_frame] || 0

    ###ルビ関連

    @rubi_size = options[:rubi_size]|| 12            #ルビ文字のフォントサイズ
    #ルビの表示開始オフセット値
    @rubi_offset_x = options[:rubi_offset_x] || 0
    @rubi_offset_y = options[:rubi_offset_y] || -@rubi_size
    #ルビ文字のベース文字からのピッチ幅
    @rubi_pitch = options[:rubi_pitch] || 12
    #ルビの待ちフレーム数
    @rubi_wait_frame = options[:rubi_wait_frame] || 20 

    #style_configのデフォルト値を更新
    @default_style_config.merge!(style_config)

    #style_configの初期化
    command_reset_style_config(nil, nil)

    #次に描画する文字のＸ座標とインデントＸ座標オフセットをリセット
    @indent = options[:indent] || 0 

    super
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
  def command__CHAR_(options, inner_options)
    target = @control_list.last
    #文字コントロールを生成する
    target.push_command([:_CREATE_, 
               {:_ARGUMENT_ => :CharControl, 
                :char => options[:_ARGUMENT_],

                :font_config => @font_config,
                :skip_mode =>  @skip_mode,

                :size => @size,
                :fontname => @fontname,
                :weight => @bold,
                :italic => @italic,
                :edge => @edge,
                :shadow => @shadow,

                :float_mode => :right}, 
               {:block => @char_renderer}])

    #文字幅スペーサーを生成する
    target.push_command([:_CREATE_, 
                {:_ARGUMENT_ => :LayoutControl, 
                :width => @style_config[:charactor_pitch],
                :height => @style_config[:line_height],
                :float_mode => :right}, 
               {:block => @char_renderer}])
  end

  #image_charコマンド
  #指定文字（群）のレンダリング済みフォントを描画チェインに連結する
  def command_image_char(options, inner_options)
    raise
#以下旧仕様なので動作しない
#TODO：イメージフォントデータ関連が現仕様と乖離しているので一旦コメントアウト
=begin
    #文字コントロールを生成する
    interrupt_command([:_CREATE_, {
                    :_ARGUMENT_ => :CharControl, 
                   :x_pos => @next_char_x + @margin_x,
                   :y_pos => @next_char_y + @margin_y + @style_config[:line_height] - @font.size, #行の高さと文字の高さは一致していないかもしれないので、下端に合わせる
                   :char => "",
                   :font => @font,
                   :font_config => @font_config,
                   :skip_mode =>  @skip_mode,
                   :graph => true,
                   },
                   {:block => @char_renderer},
#                   @font.glyph(options[:char].to_s])
                 )

    #描画座標を１文字＋文字ピッチ分進める
    @next_char_x += @font.get_width(options[:char].to_s) + 
                    @style_config[:charactor_pitch]
=end
  end

  #textコマンド
  #指定文字列を描画チェインに連結する
  def command__TEXT_(options, inner_options)
    command_list = Array.new

    #イメージフォントを使うかどうか
    if @font_config[:use_image_font]
      char_command = :image_char
    else
      char_command = :_CHAR_
    end

    #文字列を分解してcharコマンドに変換する
    options[:_ARGUMENT_].each_char do |ch|
      #１文字分の出力コマンドをスタックする
      command_list.push([char_command, 
                        {:_ARGUMENT_ => ch}, 
                        inner_options])
      #:waitコマンドをスタックする。待ち時間は遅延評価とする
      command_list.push([:_WAIT_, 
                        {:_ARGUMENT_ => [:count, :skip, :key_push],
                         :count => @wait_frame}, 
                         inner_options])
    end

    #展開したコマンドをスタックする
    eval_commands(command_list)
  end

  #graphコマンド
  #指定画像を描画チェインに連結する
  def command_graph(options, inner_options)
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
                    {:x_pos => @next_char_x + @margin_x,
                     :y_pos => @next_char_y + @margin_y + @style_config[:line_height] - @font.size, #行の高さと文字の高さは一致していないかもしれないので、下端に合わせる
                     :char => "",
                     :font => @font,
                     :font_config => @font_config,
                     :skip_mode =>  @skip_mode,
                     :graph => options[:is_char]},
                    image
                  ))
    #描画座標を画像横幅＋文字ピッチ分進める
    @next_char_x += image.width + @style_config[:charactor_pitch]

    #:waitコマンドを追加でスタックする（待ち時間は遅延評価とする）
    interrupt_command([:_WAIT_, 
                          {:_WAIT_ => [:count, :skip, :key_push],
                           :count => @wait_frame}, inner_options])
=end
  end

  def command__RUBI_(options, inner_options)

    #ルビを構成するコマンド列を作成

    rubi_command_list = Array.new

    options[:rubi].each_char do |rubi|
      rubi_command_list.push([:_CREATE_, 
                 {:_ARGUMENT_ => :CharControl, 
                  :char => rubi,

                  :font_config => @font_config,

                  :size => @rubi_size,
                  :fontname => @font_config[:fontname],
                  :weight => @bold,
                  :italic => @italic,
                :edge => @edge,
                :shadow => @shadow,

                  :skip_mode =>  @skip_mode,
                  :float_mode => :right}, 
                 {:block => @char_renderer}])

      #文字幅スペーサーを生成する
      rubi_command_list.push([:_CREATE_, 
                  {:_ARGUMENT_ => :LayoutControl, 
                  :width => @rubi_pitch,
                  :height => @rubi_size,
                  :float_mode => :right}, 
                 {:block => @char_renderer}])

    rubi_command_list.push([:_WAIT_, 
                      {:_ARGUMENT_ => [:count, :skip, :key_push],
                       :count => @rubi_wait_frame}, 
                       inner_options])
    end

    rubi_layout =[:_CREATE_, 
                  { :_ARGUMENT_ => :LayoutControl, 
                    :command_list => rubi_command_list,
                    :x_pos => @rubi_offset_x,
                    :y_pos => @rubi_offset_y,
                    :width=> 128,
                    :height=> @rubi_size}, inner_options]

    #ベース文字
    @control_list.last.push_command([:_CREATE_, 
               {:_ARGUMENT_ => :CharControl, 
                :command_list => [rubi_layout],
                :char => options[:_ARGUMENT_],

                :font_config => @font_config,

                :size => @size,
                :fontname => @font_config[:fontname],
                :weight => @bold,
                :italic => @italic,
                :edge => @edge,
                :shadow => @shadow,

                :skip_mode =>  @skip_mode,
                :float_mode => :right}, 
               {:block => @char_renderer}])

    #:waitコマンドをスタックする。
    @control_list.last.push_command([:_WAIT_, 
                      {:_ARGUMENT_ => [:count, :skip, :key_push],
                       :count => 2}, 
                       inner_options])
  end

  #line_feedコマンド
  #改行処理（CR＋LF）
  def command__LINE_FEED_(options, inner_options)
    #以下逆順に登録

    #改行時のwaitを設定する
    interrupt_command([:_WAIT_, 
                      {:_ARGUMENT_ => [:count, :skip, :key_push],
                       :count => @line_feed_wait_frame}, 
                       inner_options])

    #次のアクティブ行コントロールを追加  
    interrupt_command([:_CREATE_, 
                     {:_ARGUMENT_ => :LayoutControl, 
                      :width => @width,
                      :height => @style_config[:line_height],
                      #インデント用無形コントロール
                      :command_list => @indent > 0 ? [[:_CREATE_, 
                                       {:_ARGUMENT_ => :LayoutControl, 
                                        :width => @indent,
                                        :height => @style_config[:line_height],
                                        :float_mode => :right}, 
                                        inner_options]] : nil, 
                      :float_mode => :bottom}, 
                      inner_options])

    #行間ピッチ分の無形コントロールを追加
    interrupt_command([:_CREATE_, 
                     {:_ARGUMENT_ => :LayoutControl, 
                      :width => @width,
                      :height => @style_config[:line_spacing],
                      :float_mode => :bottom}, 
                      inner_options])
  end

  #flushコマンド
  #メッセージレイヤの消去
  def command__FLUSH_(options, inner_options)
    #子コントロールをクリアする
    @control_list.each do |control|
      control.interrupt_command([:_DELETE_, options, {}])
    end

    #改行を挿入して新規列レイアウトコントロールを生成する
    indent = @indent #一時的にインデントを退避＆クリアする
    @indent = 0
    command__LINE_FEED_(options, inner_options)
    @indent = indent
  end

  #############################################################################
  #フォント操作関連コマンド
  #############################################################################

  #reset_font_configタグ
  #文字属性をデフォルトに戻す
  def command_reset_font_config(options, inner_options)
    #fontの設定をデフォルト設定で上書きする
    @font_config = @default_font_config.clone

    #fontオブジェクトを再生成する
    #reset_font()
  end

  #reset_styleタグ
  #スタイルをデフォルトに戻す
  def command_reset_style_config(options, inner_options)
    #styleの設定をデフォルト設定で上書きする
    @style_config = @default_style_config.clone
  end

  #############################################################################
  #レンダリング済みフォントデータファイル登録コマンド
  #############################################################################

  #レンダリング済みフォントデータファイルを登録する
  def command_map_image_font(options, inner_options)
    #レンダリング済みフォントデータファイルを任意フォント名で登録
    Image_font.regist(options[:font_name].to_s, options[:file_path].to_s)
  end

  #############################################################################
  #内部メソッド
  #############################################################################
=begin
  #fontオブジェクトを再生成する
  def reset_font() #削除予定
    pp "reset"
    #フォントリソースを解放
    @font.dispose if @font
    #イメージフォント使用中の場合
    @font = @font_config[:use_image_font] ?
            #イメージフォントオブジェクト生成
            Image_font.new(@font_config[:image_face]) :
            #フォントオブジェクト生成
            Font.new(@font_config[:size], 
                     @font_config[:fontname],
                    {:weight => @font_config[:bold],
                     :italic => @font_config[:italic]})

    #ルビフォントリソースを解放
    @rubi_font.dispose if @rubi_font
    #ルビフォントオブジェクト生成
    @rubi_font = Font.new( @font_config[:rubi_size], 
                           @font_config[:fontname],
                          {:weight => @font_config[:bold],
                           :italic => @font_config[:italic]})
  end
=end
end
