#! ruby -E utf-8

require 'dxruby'
require "tmpdir"
require 'pp'
require_relative './ConvertFont.rb'

###############################################################################
#TSUKASA for DXRuby ver2.2(2017/2/14)
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
# レンダリング済みフォントを使うクラス
###############################################################################
class ImageFont
  attr_reader :size

  @@fonts_file_cache = {} #レンダリング済み文字ファイルのキャッシュ
  @@fonts_image_cache = {} #グリフ化済み文字のイメージキャッシュ

  #レンダリング済み文字ファイルを、フォント名をキーにハッシュに保存する
  def ImageFont.regist(font_name, file_path)
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
  def ImageFont.regist?(font_name)
    return @@fonts_file_cache.key?(font_name)
  end

  #フォント名は識別用なので任意
  def initialize(font_name, file_path = nil)
    #ファイルキャッシュにデータが格納されていない場合登録する。
    if !@@fonts_file_cache.key?(font_name)
      ImageFont.regist(font_name, file_path)
    end

    # イメージキャッシュにエントリが無ければ初期化
    @@fonts_image_cache[font_name] = {} if !@@fonts_image_cache.key?(font_name)

    #キャッシュからデータを読み込む
    @font_data = @@fonts_file_cache[font_name][0]
    @size = @@fonts_file_cache[font_name][1]
    @font_image = @@fonts_image_cache[font_name]
  end

  #文字幅を返す
  def get_width(chars)
    x = 0
    chars.each_char do |char|
      #文字のデータ構造体を取得
      font = @font_data[char.encode("windows-31j")]
      #Ｘ座標更新
      x += font[0] - font[1]
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
        @font_image[char] = Image.load_from_file_in_memory(font[2]).effect_image_font({})
      end

      #グリフ化済みの文字を自前imageに書き込む
      target.draw(x - font[1], 0, @font_image[char])

      #Ｘ座標更新
      x += font[0] - font[1]
    end
    #描画を終えたimageを返す
    return target
  end
end

###############################################################################
# バッチスクリプト
###############################################################################

Window.bgcolor = [100,100,100]

size = ARGV[0] || 32
font_name = ARGV[1] || "ＭＳ Ｐゴシック"
file_path = ARGV[2] || "FontData01.dat"

size = size.to_i

puts "FontDataMaker fo Tsukasa Engine v1.0"
puts "サイズ：#{size.to_s}"
puts "フォント：#{font_name.encode("utf-8")}"
puts "出力ファイルパス：#{file_path}"
puts "コンバートを開始します。コンバート後のデータの再配布については、コンバート元のフォントのライセンスに従ってください"

# レンダリング済みフォント作成
imagefontmaker = ConvertFont.new(size,font_name,:all).output(file_path)

#初期化時にフォント名とファイルパスを渡すパターン
imagefont1 = ImageFont.new("test", file_path)

image0 = imagefont1.glyph("コンバートが完了しました").effect_image_font({:shadow=>false, :edge=>false, :edge_color=>C_CYAN, :edge_width =>2})

image1 = imagefont1.glyph("abcdefghijklmnopqrstuvwxyz").effect_image_font({:shadow=>false, :edge=>false, :edge_color=>C_CYAN})

image2 = imagefont1.glyph("ウィンドウを閉じると終了します").effect_image_font({:shadow=>false, :edge=>false, :edge_color=>C_CYAN})

Window.loop do
  Window.draw(0, 50, image0)
  Window.draw(0, 50 + size, image1)
  Window.draw(0, 50 + size + 50 + size, image2)
end
