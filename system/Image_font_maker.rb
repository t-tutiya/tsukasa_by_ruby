#! ruby -E utf-8

require 'dxruby'
require "tmpdir"

###############################################################################
#TSUKASA for DXRuby ver1.0(2015/12/24)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#original by mirichi(http://d.hatena.ne.jp/mirichi/20130430/p2)
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
# レンダリング済みフォントデータファイルを作るクラス
###############################################################################
class ImageFontMaker
  #構造体クラスの生成
  ImageFontData = Struct.new(:width, :ox, :binary)
  ImageFontSaveData = Struct.new(:data_hash, :height)

  #コンストラクタ
  def initialize(size, font_name, mode = nil)

    #初期化
    @font = Font.new(size, font_name)
    @char_info = {}

    #全文字取得モードでなければ戻る
    return if mode != :all

    #Shift_JISに含まれる全ての文字を取得する
    encoding = "windows-31j"
    sjis_chars = 
      #ASCIIコード取得
      char_encode_2byte(encoding, (0x20..0x7e), [0]) +
      #半角カタカナ取得
      char_encode_2byte(encoding, (0xa1..0xdf), [0]) +
      #0x81～0x9fエリア取得
      char_encode_2byte(encoding, (0x40..0x7e), (0x81..0x9f)) +
      char_encode_2byte(encoding, (0x80..0xfc), (0x81..0x9f)) +
      #0xe0～0xefエリア取得（ただし0xeb40以降は無視）
      char_encode_2byte(encoding, (0x40..0x7e), (0xe0..0xea)) +
      char_encode_2byte(encoding, (0x80..0xfc), (0xe0..0xea))

    #Shift_JISに含まれる全ての文字を登録する
    add_data(sjis_chars)
  end

  #レンダリングする文字列を受け取る
  def add_data(chars)
    #１文字単位で取得
    chars.each_char do |c|
      #utf-8に変換出来ない２バイト文字を飛ばす
      c.encode("utf-8") rescue next
      #その文字をキーに、フォント情報を格納する
      @char_info[c] = @font.info(c)
    end
  end

  #レンダリング済みデータを出力する
  def output(file_name)
    data_hash = {}

    #一時ディレクトリを作りその中で作業
    Dir.mktmpdir do |dir|
      #キー毎に回す
      @char_info.keys.each do |k|
        # 必要な画像サイズを調べる
        # 計算がややこしいことになってるのはfやjなど左右にはみ出す特殊な文字の対応
        #Font#infoを取得
        v = @char_info[k]
        #Ｘ座標オフセット値を取得（※ただし、Image_fontでは未使用）
        ox = v.gmpt_glyphorigin_x < 0 ? -v.gmpt_glyphorigin_x : 0
        #文字画像の幅を決定
        cx = (v.gm_blackbox_x + v.gmpt_glyphorigin_x) > v.gm_cellinc_x + ox ? 
             (v.gm_blackbox_x + v.gmpt_glyphorigin_x) : 
              v.gm_cellinc_x + ox
        #文字画像の高さを決定
        height = v.tm_ascent + v.tm_descent
        #サイズが確定した時点で、そのサイズのImageを生成
        image = Image.new(cx, height, C_BLACK)
        #文字を書き込む
        image.draw_font(ox, 0, k, @font)
        #ファイル名のフルパスを作成
        temp_file_name = dir + "/temp.png"
        #画像をファイル保存
        image.save(temp_file_name)
        #画像リソースを破棄
        image.dispose
        #画像をバイナリとして読み出し
        binary = nil
        open(temp_file_name, "rb") do |fh|
          #data_hashに追加
          binary = fh.read
        end
        #その文字をキーに、ハッシュに各種座標を格納する
        data_hash[k] = ImageFontData.new(cx, ox, binary)
      end
    end

    #セーブ用データの生成
    imagefont = ImageFontSaveData.new(data_hash, @font.size)

    #ハッシュをマーシャルダンプして保存
    open(file_name, "wb") do |fh|
      fh.write(Marshal.dump(imagefont))
    end
  end

  private

  #上位下位の各rangeで指定された２バイトから、必要な文字コードを生成し、文字列を形成する。
  def char_encode_2byte(encoding, low, high)
    sjis_pool = String.new
    high.each do |h|
      low.each do |l|
        sjis_pool += (h * 2**8 + l).chr(encoding) 
      end
    end
    return sjis_pool
  end
end

###############################################################################
# レンダリング済みフォントデータファイルを使うクラス
###############################################################################
class Image_font
  attr_reader :size

  @@fonts_file_cache = {} #レンダリング済み文字ファイルのキャッシュ
  @@fonts_image_cache = {} #グリフ化済み文字のイメージキャッシュ

  #レンダリング済み文字ファイルを、フォント名をキーにハッシュに保存する
  def Image_font.regist(font_name, file_path)
    #ファイルキャッシュにデータが格納されていない場合
    if !@@fonts_file_cache.key?(font_name)
      #ファイルをオープン
      open(file_path, "rb") do |fh|
        #マーシャルで展開しキャッシュに格納する
        @@fonts_file_cache[font_name] = Marshal.load(fh.read)
      end
    end
  end

  #フォント名が登録されているかどうかを返す
  def Image_font.regist?(font_name)
    return @@fonts_file_cache.key?(font_name)
  end

  #フォント名は識別用なので任意
  def initialize(font_name, file_path = nil)
    #ファイルキャッシュにデータが格納されていない場合登録する。
    if !@@fonts_file_cache.key?(font_name)
      Image_font.regist(font_name, file_path)
    end

    # イメージキャッシュにエントリが無ければ初期化
    if !@@fonts_image_cache.key?(font_name)
      @@fonts_image_cache[font_name] = {} 
    end

    #キャッシュからデータを読み込む
    @font_data = @@fonts_file_cache[font_name].data_hash
    @size = @@fonts_file_cache[font_name].height
    @font_image = @@fonts_image_cache[font_name]
  end

  #文字幅を返す
  def get_width(chars)
    x = 0
    
    chars.each_char do |char|
      #文字のデータ構造体を取得
      font = @font_data[char.encode("windows-31j")]
      
      #Ｘ座標更新
      x += font.width
    end
    
    return x
  end

  #文字列描画
  #chars:描画する文字列（１文字以上）
  def glyph(chars)
    #必要なサイズのImageを生成する
    target = Image.new(get_width(chars), @size)

    x = 0
    
    #全ての文字を描画する
    chars.each_char do |char|
      #文字のデータ構造体を取得
      font = @font_data[char.encode("windows-31j")]

      #キャッシュにその文字が登録されていない場合
      if !@font_image.has_key?(char)
        #文字をバイナリからイメージ＆グリフ化して、キャッシュに格納する
        @font_image[char] = Image.load_from_file_in_memory(font.binary).effect_image_font({})
      end

      #グリフ化済みの文字を自前imageに書き込む
      target.draw(x, 0, @font_image[char])
      #Ｘ座標更新
      x += font.width
    end
    #描画を終えたimageを返す
    return target
  end

  #DXRuby::Fontとフォーマットを合わせる為のダミーメソッド。
  #これが実行されると、そのインスタンスはもう使用不可能になるので注意。
  def dispose
    @font_data = nil
    @size = nil
    @font_image = nil
  end
end
