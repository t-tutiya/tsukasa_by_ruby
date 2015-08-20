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
    reset_font()
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

    #フォントの初期設定
    @default_font_config = {
      :size => 24,                 #フォントサイズ
      :fontname => "ＭＳ 明朝",        #フォント名
      :color => [255,255,255],     #色

      :rubi_size => 12,            #ルビ文字のフォントサイズ
      :rubi_pitch => 2,            #ルビ文字のベース文字からのピッチ幅

      :edge => true,               #縁文字
      :edge_color => [48, 48, 48], #縁文字：縁の色
      :edge_width => 2,            #縁文字：縁の幅
      :edge_level => 16,           #縁文字：縁の濃さ

      :bold => false,              #太字
      :italic => false,            #イタリック

      :shadow => false,            #影
      :shadow_edge => false,       #影：縁まで影を落とすか
      :shadow_color => [0,0,0],    #影：影の色
      :shadow_x => 1,              #影:オフセットＸ座標
      :shadow_y => 1,              #影:オフセットＹ座標

      :aa => true,                 #アンチエイリアスのオンオフ

      :use_image_font => false,    #レンダリング済みフォント使用中かどうか
      :image_face => nil,          #レンダリング済みフォントのフォント名
    }

    #font_configのデフォルト値を更新
    @default_font_config.merge!(font_config)

    #fong_configの初期化
    command_reset_font_config(nil, nil)

    #スタイルの初期設定
    @default_style_config = {
      :line_spacing => 12,   #行間の幅
      :charactor_pitch => 3, #文字間の幅
      :line_height => 32,    #行の高さ

      #その他
      :wait_frame => 2, #文字描画後の待ちフレーム数
      :line_feed_wait_frame => 0, #改行後の待ちフレーム数
    }

    #style_configのデフォルト値を更新
    @default_style_config.merge!(style_config)

    #style_configの初期化
    command_reset_style_config(nil, nil)

    #次に描画する文字のＸ座標とインデントＸ座標オフセットをリセット
    @indent_offset = 0 

    super

    #次のアクティブ行コントロールを追加  
    interrupt_command([:_CREATE_, 
                     {:_ARGUMENT_ => :LayoutControl, 
                      :width => options[:width],
                      :height => @style_config[:line_height],
                      :float_mode => :bottom}, 
                      {}])

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
  def command_char(options, inner_options)
    target = @control_list.last
    #文字コントロールを生成する
    target.push_command([:_CREATE_, 
               {:_ARGUMENT_ => :CharControl, 
                :char => options[:_ARGUMENT_],
                :font => @font,
                :font_config => @font_config,
                :skip_mode =>  @skip_mode,
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
      char_command = :char
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
                         :count => :unset_wait_frame}, 
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
                           :count => :unset_wait_frame}, inner_options])
=end
  end

  #line_feedコマンド
  #改行処理（CR＋LF）
  def command__LINE_FEED_(options, inner_options)
    #以下逆順に登録

    #改行時のwaitを設定する
    interrupt_command([:_WAIT_, 
                      {:_ARGUMENT_ => [:count, :skip, :key_push],
                       :count => @style_config[:line_feed_wait_frame]}, 
                       inner_options])

    #次のアクティブ行コントロールを追加  
    interrupt_command([:_CREATE_, 
                     {:_ARGUMENT_ => :LayoutControl, 
                      :width => options[:width],
                      :height => @style_config[:line_height],
                      :float_mode => :bottom}, 
                      inner_options])

    #行間ピッチ分の無形コントロールを追加
    interrupt_command([:_CREATE_, 
                     {:_ARGUMENT_ => :LayoutControl, 
                      :width => options[:width],
                      :height => @style_config[:line_spacing],
                      :float_mode => :bottom}, 
                      inner_options])
  end

  #flushコマンド
  #メッセージレイヤの消去
  def command__FLUSH_(options, inner_options)
    @control_list.each do |control|
      control.interrupt_command([:_DELETE_, options, {}])
    end

    #次のアクティブ行コントロールを追加  
    interrupt_command([:_CREATE_, 
                     {:_ARGUMENT_ => :LayoutControl, 
                      :width => options[:width],
                      :height => @style_config[:line_height],
                      :float_mode => :bottom}, 
                      inner_options])
  end

  #############################################################################
  #ルビ関連コマンド
  #############################################################################
=begin
  #rubi_charコマンド
  #ルビを出力する
  #オフセットがあればそのＸ座標から、なければ文字の中心から計算して出力する
  def command_rubi_char(options, inner_options)

    #ルビ文字列を取得
    texts = options[:char].to_s
    #ルビの文字数を取得
    length = texts.length
    #ルビが構成するwidthを取得
    width = @rubi_font.get_width(texts)

    #開始相対x座標を取得。設定されてない場合はベース文字/2からwidth/2を引いた値
    x = options[:offset] ?
        options[:offset].to_i :
        @font_config[:size]/2 - width/2

    #一文字ごとに処理
    texts.each_char do |ch|
      #文字レンダラオブジェクトを生成し、描画チェインに連結する
      #TODO:RAG2015版への移行作業まだ
      @control_list.push(CharControl.new(
                    @next_char_x + x + @margin_x,
                    @next_char_y + @margin_y - @rubi_font.size - @font_config[:rubi_pitch],
                    ch,
                    @rubi_font,
                    @font_config,
                    @skip_mode,
                    :normal,
                    @char_renderer_commands
                    ))
      #相対Ｘ座標を次に進める
      x += @font_config[:rubi_size]
    end
  end
=end
=begin
  #rubiコマンド
  #ルビを出力する（rubi_charの補助メソッド）
  #char:ルビ文字列
  #text:ルビを割り当てるベースの文字列
  #align: expand（デフォルト）/center/left/rightから選ぶ
  def command_rubi(options, inner_options)
    raise #旧仕様なので機能しない
    #ルビ文字列を取得
    rubi_texts = options[:char]
    #ルビの文字数を取得
    rubi_length = rubi_texts.length
    #ルビが構成するwidthを取得
    rubi_width = @rubi_font.get_width(rubi_texts)

    #ベース文字列を取得
    base_texts = options[:text]
    #ベース文字列の文字数を取得
    base_length = base_texts.length
    #ベース文字列が構成するwidthを取得（間に入る文字ピッチ分を考慮）
    base_width = @font.get_width(base_texts) + 
                 @style_config[:charactor_pitch] * (base_length - 1)

    #align指定を取得（設定がなければ:expandとする）
    align = options[:align] ? options[:align].to_sym : :expand

    #開始相対ｘ座標とルビ文字の間隔を算出
    case align
    when :expand #均等割り付け
      #ベース文字列幅（頭を揃える為に文字ピッチを加算している）をルビ文字数で均等に割った値をピッチとする
      pitch = (base_width + @style_config[:charactor_pitch])/rubi_length
      #ベース文字列の中心座標から、ルビ文字列幅の半分を引いた座標を基点とする
      x = base_width/2 - ((rubi_length-1) * pitch + @font_config[:rubi_size])/2
    when :center #中央揃え
      pitch = @font_config[:rubi_size]
      #ベース文字列の中心座標からルビ文字列幅の半分を引いた座標を基点とする
      x = base_width/2 - rubi_width/2
    when :left #左揃え
      pitch = @font_config[:rubi_size]
      #ベース文字列の左端を基点とする
      x = 0 
    when :right #右揃え
      pitch = @font_config[:rubi_size]
      #ベース文字列の右端から、ルビ文字列の横幅を引いた座標を基点とする
      x = base_width - rubi_width
    else
      #使用されていないハッシュ。エラー。
      puts "オプション#{align}は未定義です"
      return
    end

    rubi_counter = 0
    commands = Array.new
    base_offset = 0
    base_counter = 0

    #ベース文字列を１文字ごとに処理
    base_texts.each_char do |ch|
      loop do
        #ルビ文字を最後まで処理したならループを抜ける
        break if rubi_counter == rubi_length

        #対象のルビ文字の座標を算出
        rubi_offset = x + pitch * rubi_counter
        
        #対象ルビが次のベース文字に対応しており、かつ、これが最後のベース文字の出力でないならループを抜ける
        break if rubi_offset > base_offset and base_counter + 1 != base_length

        #ルビ文字をスタックする
        commands.push([:rubi_char, {:char => rubi_texts[rubi_counter],
                                    :offset => rubi_offset - base_offset
                                    }])

        #ルビ文字カウンタインクリメント
        rubi_counter += 1
      end

      #ベース文字のcharコマンドをスタックする
      commands.push([:char, {:_ARGUMENT_ => ch}])

      #ベース文字カウンタインクリメント
      base_counter += 1

      #ベース文字列のオフセット値を更新
      base_offset += @font.get_width(ch) + @style_config[:charactor_pitch]
    end

    #生成したコマンド群をスタックに追加
    #todo @command_listは廃止予定
    #@command_list = commands + @command_list
  end
=end
  #############################################################################
  #フォント操作関連コマンド
  #############################################################################

  #reset_font_configタグ
  #文字属性をデフォルトに戻す
  def command_reset_font_config(options, inner_options)
    #fontの設定をデフォルト設定で上書きする
    @font_config = @default_font_config.clone

    #fontオブジェクトを再生成する
    reset_font()
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
  #描画タイミング制御
  #############################################################################

  #描画速度指定
  #TODO：このコマンドの存在自体に問題がある
  def command_delay(options, inner_options)
    #デフォルト速度、現在速度を更新
    @style_config[:wait_frame] = @default_style_config[:wait_frame] = options[:_ARGUMENT_]
  end

  #############################################################################
  #内部メソッド
  #############################################################################

  #fontオブジェクトを再生成する
  def reset_font()
    #フォントリソースを解放
    @font.dispose if @font != nil 
    #イメージフォント使用中の場合
    @font = @font_config[:use_image_font] ?
            #イメージフォントオブジェクト生成
            Image_font.new(@font_config[:image_face]) :
            #フォントオブジェクト生成
            @font = Font.new(@font_config[:size], 
                             @font_config[:fontname],
                            {:weight => @font_config[:bold],
                             :italic => @font_config[:italic]})

    #ルビフォントリソースを解放
    @rubi_font.dispose if @rubi_font != nil 
    #ルビフォントオブジェクト生成
    @rubi_font = Font.new( @font_config[:rubi_size], 
                           @font_config[:fontname],
                          {:weight => @font_config[:bold],
                           :italic => @font_config[:italic]})
                           
  end
end

