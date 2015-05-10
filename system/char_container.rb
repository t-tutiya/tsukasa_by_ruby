#! ruby -E utf-8

require 'dxruby'

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
=begin
#コマンドと内部メソッドとの対応テーブル
@command_dispatch = {
  #テキスト関連
  :char => :command_char,                           #文字スタック
  :text => :command_text,                           #文字列スタック

  :graph => :command_graph,                         #画像スタック
  :wait => :command_wait,                           #フレーム待機
  :line_feed => :command_line_feed,                 #改行
  :flash => :command_flash,   #ページのリセット
  :locate => :command_locate, #次の文字の描画座標を直接指定する
  :indent => :command_indent, #インデントをＯＮ／ＯＦＦする

  #描画速度の制御
  :delay => :command_delay, #文字描画速度の設定

  #ルビ文字の制御
  :rubi_char => :command_rubi_char, #ルビ文字の出力
  :rubi => :command_rubi,           #複数ルビ文字列の割り付け

  #フォント設定の更新
  :default_font_config => :command_default_font_config, #デフォルト
  :font_config => :command_font_config,                 #現在値
  :reset_font_config => :command_reset_font_config,     #現在値をリセット

  #スタイル設定の更新
  :default_style_config => :command_default_style_config, #デフォルト
  :style_config => :command_style_config,                 #現在値
  :reset_style_config => :command_reset_style_config,     #現在値をリセット

  #その他制御系
  :char_renderer => :command_char_renderer,   #文字レンダラの設定
  :map_image_font => :command_map_image_font, #レンダリング済みフォントの登録
}
=end

class CharContainer < Control
  include Movable #移動関連モジュール
  include Drawable #描画関連モジュール

  def initialize(options, control = nil)
    @char_renderer_commands = {}

    @margin_x = options[:margin_x] || 0
    @margin_y = options[:margin_y] || 0

    font_config  = options[:font_config]  || {} #フォントコンフィグ
    style_config = options[:style_config] || {} #スタイルコンフィグ

    #フォントの初期設定
    @default_font_config = {
      :size => 24,                 #フォントサイズ
      :face => "ＭＳ 明朝",        #フォント名
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
    command_default_font_config(font_config, nil)
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
    command_default_style_config(style_config, nil)
    #style_configの初期化
    command_reset_style_config(nil, nil)

    #次に描画する文字のＸ座標とインデントＸ座標オフセットをリセット
    @next_char_x = @indent_offset = 0 
    #次に描画する文字の『下限』Ｙ座標をリセット
    @next_char_y = 0

    super(options)
  end

  def update
#    pp @command_list
    super
  end

  #############################################################################
  #公開インターフェイス
  #############################################################################

  def dispose()
    super
  end

  #TODO：多分いらない
  def width
    @next_char_x + @font_config[:size]
  end

  #TODO：多分いらない
  def height
    @next_char_y + @font_config[:size]
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
  def command_char(options, target)
    #レンダリング済みフォントを使用中か否かで分岐
    if !@font_config[:use_image_font]
      #文字レンダラオブジェクトを生成する
      #TODO:本来はcreate_childコマンドで生成されるべきか？
      control = CharControl.new(
                    {:x_pos => @next_char_x + @margin_x,
                     :y_pos => @next_char_y + @margin_y + @style_config[:line_height] - @font.size, #行の高さと文字の高さは一致していないかもしれないので、下端に合わせる
                     :char => options[:char].to_s,
                     :font => @font,
                     :font_config => @font_config,
                     :skip_mode =>  @skip_mode,
                     :graph => false,
                     :commands =>@char_renderer_commands}
                   )
    else
      #文字レンダラオブジェクトを生成する
      #TODO:本来はcreate_childコマンドで生成されるべきか？
      control = CharControl.new(
                    {:x_pos => @next_char_x + @margin_x,
                     :y_pos => @next_char_y + @margin_y + @style_config[:line_height] - @font.size, #行の高さと文字の高さは一致していないかもしれないので、下端に合わせる
                     :char => "",
                     :font => @font,
                     :font_config => @font_config,
                     :skip_mode =>  @skip_mode,
                     :graph => true,
                     :commands =>@char_renderer_commands},
                   @font.glyph(options[:char].to_s)
                   )
    end

    #描画チェインに連結する
    @control_list.push(control)

    #描画座標を１文字＋文字ピッチ分進める
    @next_char_x += @font.get_width(options[:char].to_s) + 
                    @style_config[:charactor_pitch]

    #:waitコマンドを追加でスタックする（待ち時間は遅延評価とする）
    send_command_interrupt(:wait, {:wait => :unset_wait_frame})

    return :continue #アイドル
  end

  #textコマンド
  #指定文字列を描画チェインに連結する
  def command_text(options, target)
    #必須属性値チェック
    raise if check_exist(options, :text)
    
    commands = Array.new
    
    #文字列を分解してcharコマンドに変換する
    options[:text].each_char do |ch|
      #コマンドを一時スタックする
      commands.push([:char, {:char => ch}])
    end

    #一時スタックしたコマンドをスタックの先頭に挿入する
    @command_list = commands + @command_list

    return :continue #フレーム続行
  end

  #graphコマンド
  #指定画像を描画チェインに連結する
  def command_graph(options, target)
    #必須属性値チェック
    raise if check_exist(options, :file_path)

    #:is_charが省略されている場合初期値を設定する
    options[:is_char] = true if !options.key?(:is_char)

    #指定された画像を読み込む
    image = Image.load(options[:file_path])

    #:color_keyオプションが設定されている場合
    if options.key?(:color_key)
      #抜き色を設定する
      image.set_color_key(hex_to_rgb(options[:color_key]))
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
                     :graph => object_to_boolean(options[:is_char])},
                    image
                  ))
    #描画座標を画像横幅＋文字ピッチ分進める
    @next_char_x += image.width + @style_config[:charactor_pitch]

    #:waitコマンドを追加でスタックする（待ち時間は遅延評価とする）
    send_command_interrupt(:wait, {:wait => :unset_wait_frame})

    return :continue#フレーム続行
  end

  #line_feedコマンド
  #改行処理（CR＋LF）
  def command_line_feed(options, target)
    #Ｘ座標をリセット（インデント設定があればその分を加算）
    @next_char_x = @indent_offset
    #行間サイズ＋行間ピッチ分Ｙ座標を送る
    @next_char_y += @style_config[:line_height] + @style_config[:line_spacing]
    @height = @next_char_y + @font_config[:size]

    #改行時のwaitを設定する
    send_command_interrupt(:wait, {:wait => @style_config[:line_feed_wait_frame]})

    return :continue #フレーム続行
  end

  #flashコマンド
  #メッセージレイヤの消去
  def command_flash(options, target)
    #文字列をクリア
    @control_list.clear

    #カーソル座標をインデン値でリセット
    @next_char_x = @indent_offset
    #Ｙ座標をリセット
    @next_char_y = 0 
    @height = @font_config[:size]

    return :continue #フレーム続行
  end

  #############################################################################
  #ルビ関連コマンド
  #############################################################################
=begin
  #rubi_charコマンド
  #ルビを出力する
  #オフセットがあればそのＸ座標から、なければ文字の中心から計算して出力する
  def command_rubi_char(options, target)
    #必須属性値チェック
    return false if check_exist(options, :char)

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

    return false #フレーム続行
  end
=end
  #rubiコマンド
  #ルビを出力する（rubi_charの補助メソッド）
  #char:ルビ文字列
  #text:ルビを割り当てるベースの文字列
  #align: expand（デフォルト）/center/left/rightから選ぶ
  def command_rubi(options, target)
    #必須属性値チェック
    return :continue if check_exist(options, :text, :char)

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
      return :continue #フレーム続行
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
      commands.push([:char, {:char => ch}])

      #ベース文字カウンタインクリメント
      base_counter += 1

      #ベース文字列のオフセット値を更新
      base_offset += @font.get_width(ch) + @style_config[:charactor_pitch]
    end

    #生成したコマンド群をスタックに追加
    @command_list = commands + @command_list

    return :continue #フレーム続行
  end

  #############################################################################
  #フォント操作関連コマンド
  #############################################################################

  #default_font_configコマンド
  #デフォルトの文字属性設定
  def command_default_font_config(options, target)
    options.each do |key, value|
      #コンフィグ設定を更新する
      update_font_config(@default_font_config, key, value)
    end

    #※ここではfontを再生成しない
    #変更を反映するにはreset_font_configを実行しなければならない

    return :continue #フレーム続行
  end

  #font_configコマンド
  #現在の文字属性設定
  def command_font_config(options, target)
    options.each do |key, value|
      #"default"が設定されていればvalueをdefault値で更新
      value = @default_font_config[key] if value == "default"
      #コンフィグ設定を更新する
      update_font_config(@font_config, key, value)
    end

    #fontオブジェクトを再生成する
    reset_font()

    return :continue #フレーム続行
  end

  #フォントのコンフィグ値を更新する
  def update_font_config(target, key, value)
    #値に応じた処理
    case key
    #基本情報
    when :size
      target[:size] = value.to_i
    when :face
      #指定されたフォント名が、レンダリング済みフォントとして登録されている場合
      if Image_font.regist?(value.to_s)
        #フォント名をイメージフォント名として設定
        target[:image_face] = value.to_s
        #イメージフォント使用中フラグを立てる
        target[:use_image_font] = true
      else
        #フォント名を設定
        target[:face] = value.to_s
        #イメージフォント使用中フラグをクリア
        target[:use_image_font] = false
      end
    when :color
      target[:color] = hex_to_rgb(value)

    #ルビ関連情報
    when :rubi_size
      target[:rubi_size] = value.to_i
    when :rubi_pitch
      target[:rubi_pitch] = value.to_i

    #太字／イタリック
    when :bold
      target[:bold] = object_to_boolean(value)
    when :italic
      target[:italic] = object_to_boolean(value)

    #袋文字関連
    when :edge  #袋文字を描画するかどうかをtrue/falseで指定します。
      target[:edge] = object_to_boolean(value)
    when :edge_color  #袋文字の枠色を指定します。配列で[R, G, B]それぞれ0～255
      target[:edge_color] = hex_to_rgb(value)
    when :edge_width  #袋文字の枠の幅を0～の数値で指定します。1で1ピクセル
      target[:edge_width] = value.to_i
    when :edge_level  #袋文字の枠の濃さを0～の数値で指定します。大きいほど濃くなりますが、幅が大きいほど薄くなります。値の制限はありませんが、目安としては一桁ぐらいが実用範囲でしょう。
      target[:edge_level] = value.to_i

    #影文字関連
    when :shadow  #影を描画するかどうかをtrue/falseで指定します
      target[:shadow] = object_to_boolean(value)
    when :shadow_edge #edgeがtrueの場合に、枠の部分に対して影を付けるかどうかをtrue/falseで指定します。trueで枠の影が描かれます
      target[:shadow_edge] = object_to_boolean(value)
    when :shadow_color  #影の色を指定します。配列で[R, G, B]、それぞれ0～255
      target[:shadow_color] = hex_to_rgb(value)
    when :shadow_x  #影の位置を相対座標で指定します。+1は1ピクセル右になります
      target[:shadow_x] = value.to_i
    when :shadow_y  #影の位置を相対座標で指定します。+1は1ピクセル下になります
      target[:shadow_y] = value.to_i

    #スケール変換関連
    #文字管理オブジェクトによっては機能しません。
    when :scalex  #横の拡大率
      target[:scalex] = value.to_f
    when :scaley  #縦の拡大率
      target[:scaley] = value.to_f
    when :centerx  #回転、拡大の中心点。省略すると一番左になります。
      target[:centerx] = value.to_i
    when :centery  #回転、拡大の中心点。省略すると一番上になります。
      target[:centery] = value.to_i
    when :alpha  #アルファ値(0～255)。省略すると255になります。
      target[:alpha] = value.to_i
    when :blend  #:alpha、:add、:add2、:sub、:sub2で合成方法を指定します。省略すると:alphaとなります。
                 #:addはソースにアルファ値を、
                 #:add2は背景に255-アルファ値を適用します。
                 #:subはアルファ値を全ての色の合成に、
                 #:sub2はRGBの色をそれぞれ別々に合成に適用します。
      target[:blend] = value.to_sym
    when :angle  #360度系で画像の回転角度を指定します。拡大率と同時に指定した場合は拡大率が先に適用されます。
      target[:angle] = value.to_f

    when :z  #描画順指定（※現状実装では考慮していません）
      target[:z] = value.to_i

    when :aa  #アンチエイリアスのオンオフ
      target[:aa] = object_to_boolean(value)

    else
      #使用されていないハッシュ。エラー。
      puts "オプション#{key}は未定義です"
    end
  end

  #reset_font_configタグ
  #文字属性をデフォルトに戻す
  def command_reset_font_config(options, target)
    #fontの設定をデフォルト設定で上書きする
    @font_config = @default_font_config.clone
    #fontオブジェクトを再生成する
    reset_font()

    return :continue #フレーム続行
  end

  #############################################################################
  #文字レンダラ設定コマンド
  #############################################################################

  #char_redererタグ
  #文字レンダラの設定
  def command_char_renderer(options, target)
    @char_renderer_commands = options[:commands].dup
    return :continue #フレーム続行
  end

  #############################################################################
  #レンダリング済みフォントデータファイル登録コマンド
  #############################################################################

  #レンダリング済みフォントデータファイルを登録する
  def command_map_image_font(options, target)
    #必須属性値チェック
    raise if check_exist(options, :font_name, :file_path)

    #レンダリング済みフォントデータファイルを任意フォント名で登録
    Image_font.regist(options[:font_name].to_s, options[:file_path].to_s)

    return :continue #フレーム続行
  end

  #############################################################################
  #スタイル操作関連コマンド
  #############################################################################

  #default_style_configタグ
  #デフォルトのスタイルの設定
  def command_default_style_config(options, target)
    options.each do |key, value|
     #コンフィグ設定を更新する
     update_style_config(@default_style_config, key, value)
    end

    return :continue #フレーム続行
  end

  #style_configタグ
  #スタイルの設定
  def command_style_config(options, target)
    options.each do |key, value|
      #"default"が設定されていればvalueをdefault値で更新
      value = @default_style_config[key] if value == "default"
      #コンフィグ設定を更新する
      update_style_config(@style_config, key, value)
    end

    return :continue #フレーム続行
  end

  #スタイルのコンフィグ値を更新する
  def update_style_config(target, key, value)
    #値に応じた処理
    case key
    when :line_spacing
      target[:line_spacing] = value.to_i
    when :charactor_pitch
      target[:charactor_pitch] =  value.to_i
    when :line_height
      target[:line_height] =  value.to_i
    when :wait_frame
      target[:wait_frame] =  value.to_i
    when :line_feed_wait_frame
      target[:line_feed_wait_frame] =  value.to_i
    else
      puts "オプション#{key}は未定義です"
    end
  end

  #reset_styleタグ
  #スタイルをデフォルトに戻す
  def command_reset_style_config(options, target)
    #styleの設定をデフォルト設定で上書きする
    @style_config = @default_style_config.clone

    return :continue #フレーム続行
  end

  #############################################################################
  #ＵＩ操作コマンド
  #############################################################################
  #indentタグ
  #インデントの設定/解除
  #インデントはネストしないので注意
  #TODO:微妙な仕様だな……
  def command_indent(options, target)
    #必須属性値チェック
    raise if check_exist(options, :indent)

    #インデント開始Ｘ座標を設定もしくはクリアする
    @indent_offset = object_to_boolean(options[:indent]) ? @next_char_x : 0

    return :continue #フレーム続行
  end

  #############################################################################
  #描画タイミング制御
  #############################################################################

  #描画速度指定
  def command_delay(options, target)
    #必須属性値チェック
    return :continue if check_exist(options, :delay)

    update_wait_frame(options[:delay].to_i)

    return :continue #フレーム続行
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
                             @font_config[:face],
                            {:weight => @font_config[:bold],
                             :italic => @font_config[:italic]})

    #ルビフォントリソースを解放
    @rubi_font.dispose if @rubi_font != nil 
    #ルビフォントオブジェクト生成
    @rubi_font = Font.new( @font_config[:rubi_size], 
                           @font_config[:face],
                          {:weight => @font_config[:bold],
                           :italic => @font_config[:italic]})
  end

  #文字描画ウェイトフレーム数を更新する
  def update_wait_frame(wait_frame)
    #デフォルト速度、現在速度を更新
    @style_config[:wait_frame] = @default_style_config[:wait_frame] = wait_frame
  end
end

