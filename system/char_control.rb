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

#構造体クラスの生成（レンダリング済み文字アーカイブの再構築のために必要）
ImageFontData = Struct.new(:width, :ox, :binary)
ImageFontSaveData = Struct.new(:data_hash, :height, :ver)

class Char < Drawable
  @@fonts_file_cache = {} #レンダリング済み文字ファイルのキャッシュ
  @@fonts_image_cache = {} #グリフ化済み文字のイメージキャッシュ

  def Char.install(path)
    begin
      #エントリを追加
      DXRuby::Font.install(path)
    rescue DXRuby::DXRubyError
      raise(TsukasaLoadError.new(path))
    end
  end

  #レンダリング済み文字ファイルを、フォント名をキーにハッシュに保存する
  def Char.install_prerender(font_name, path)
    #ファイルキャッシュにデータが格納されていない場合
    unless @@fonts_file_cache.key?(font_name)
      #ファイルをオープン
      open(path, "rb") do |fh|
        #マーシャルで展開しキャッシュに格納する
        @@fonts_file_cache[font_name] = Marshal.load(fh.read)
      end
    end
  end

  #フォント名が登録されているかどうかを返す
  def Char.regist_prerender?(font_name)
    return @@fonts_file_cache.key?(font_name)
  end

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
  attr_reader :char    
  def char=(arg)
    @char = arg.to_s
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
    self.size = options[:size] || 24 

    self.font_name = options[:font_name] || "ＭＳ 明朝" #フォント名

    self.char = options[:char] || nil #描画文字

    self.weight = options[:weight] || false #太字
    self.italic = options[:italic] || false  #イタリック

    self.color = options[:color] || [255,255,255] #色
    self.aa = options[:aa] == false ? false : true #アンチエイリアスのオンオフ

    self.edge = (options[:edge] != false) #縁文字
    self.shadow = (options[:shadow] != false) #影

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
    #更新フラグが立っていないなら終了
    return super unless @option_update

    #更新フラグをリセット
    @option_update = false

    #文字が設定されていない場合
    unless @char
      @entity.dispose if @entity and !(@entity.disposed?)
      return super 
    end

    width = height = offset_x = offset_y = 0

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
      width  += @font_draw_option[:edge_width] * 2
      height += @font_draw_option[:edge_width] * 2
      offset_x = offset_y = @font_draw_option[:edge_width]
    end

    #プリレンダフォントデータが登録されているか
    if @@fonts_file_cache[@font_name]
      #プリレンダ文字の描画
      draw_prerender_character(width, height, offset_x, offset_y)
    else
      #通常文字の描画
      draw_character(width, height, offset_x, offset_y)
    end

    return super
  end

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private
  
  #通常文字の描画
  def draw_character(width, height, offset_x, offset_y)
    #フォントオブジェクトの初期化
    @font_obj = DXRuby::Font.new( @size, 
                          @font_name, 
                          { :weight=>@weight, 
                            :italic=>@italic,
                            :auto_fitting=>true })

    #現状での縦幅、横幅を取得
    @width = width
    @width += @font_obj.get_width(@char)
    @width = 1 if @width == 0
    @height = height + @size

    #文字用のimageを作成
    @entity.dispose if @entity and !(@entity.disposed?)
    @entity = DXRuby::Image.new(@width, @height, [0, 0, 0, 0]) 

    #フォントを描画
    @entity.draw_font_ex( offset_x, 
                          offset_y, 
                          @char, 
                          @font_obj, 
                          @font_draw_option)
  end

  #プリレンダ文字の描画
  def draw_prerender_character(width, height, offset_x, offset_y)
    #キャッシュからデータを読み込む
    @font_data = @@fonts_file_cache[@font_name].data_hash

    #現状での縦幅、横幅を取得
    @width = width
    @char.each_char do |char|
      #文字のデータ構造体を取得
      font = @font_data[char.encode("windows-31j")]
      #Ｘ座標更新
      @width += font.width - font.ox
    end
    @width = 1 if @width == 0
    @height = height + @@fonts_file_cache[@font_name].height

    #文字用のimageを作成
    @entity.dispose if @entity and !(@entity.disposed?)
    @entity = DXRuby::Image.new(@width, @height, [0, 0, 0, 0])

    # イメージキャッシュにエントリが無ければ初期化
    unless @@fonts_image_cache.key?(@font_name)
      @@fonts_image_cache[@font_name] = {} 
    end
    # イメージキャッシュを取得
    @font_image = @@fonts_image_cache[@font_name]

    #全ての文字を描画する
    @char.each_char do |char|
      #文字のデータ構造体を取得
      font = @font_data[char.encode("windows-31j")]

      #キャッシュにその文字が登録されていない場合
      unless @font_image.has_key?(char)
        #文字をバイナリからイメージ化してキャッシュに格納する
        @font_image[char] = DXRuby::Image.load_from_file_in_memory(font.binary)
      end

      #文字をグリフ化してImageに書き込む
      @entity.draw( offset_x + font.ox, 
                    offset_y, 
                    @font_image[char].effect_image_font(@font_draw_option))

      #Ｘ座標更新
      offset_x += font.width - font.ox
    end
  end
  
  def _CLEAR_(argument, options, yield_block_stack)
    @char = nil
    @option_update = true
  end
end
