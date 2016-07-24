#! ruby -E utf-8

require "tmpdir"
require 'pp'

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

###############################################################################
# レンダリング済みフォントを作るクラス
###############################################################################

class ConvertFont

  #コンストラクタ
  def initialize(size, font_name, mode = nil)

    #初期化
    @font = Font.new(size, font_name, {:auto_fitting=>false})
    @char_info = {}

    unless font_name.encode("UTF-8") == @font.name.encode("UTF-8")
      puts font_name
      puts @font.name.encode("UTF-8")
      puts "フォント名[#{font_name.encode("UTF-8")}]はシステムに登録されていません。名称を確認してください"
      raise
    end

    #全文字取得モードでなければ戻る
    return if mode != :all

    #Shift_JISに含まれる全ての文字を取得する
    encoding = "windows-31j"
    #ASCIIコード取得
    add_data(char_encode_2byte(encoding, (0x20..0x7e), [0]))
    #半角カタカナ取得
    add_data(char_encode_2byte(encoding, (0xa1..0xdf), [0]))
    #0x81～0x9fエリア取得
    add_data(char_encode_2byte(encoding, (0x40..0x7e), (0x81..0x9f)))
    add_data(char_encode_2byte(encoding, (0x80..0xfc), (0x81..0x9f)))
    #0xe0～0xefエリア取得（ただし0xeb40以降は無視）
    add_data(char_encode_2byte(encoding, (0x40..0x7e), (0xe0..0xea)))
    add_data(char_encode_2byte(encoding, (0x80..0xfc), (0xe0..0xea)))
  end

  #レンダリング済みデータを出力する
  def output(file_name)
    data_hash = {}

    #一時ディレクトリを作りその中で作業
    Dir.mktmpdir do |dir|
      max = @char_info.keys.count
      
      #キー毎に回す
      @char_info.keys.each_with_index do |char, index|
        print  "\r#{index + 1}/#{max}"
        # 必要な画像サイズを調べる
        # 計算がややこしいことになってるのはfやjなど左右にはみ出す特殊な文字の対応
        #Font#infoを取得
        info = @char_info[char]

        #Ｘ座標オフセット値を取得（プロポーショナルフォントで利用）
        ox = info.gmpt_glyphorigin_x < 0 ? - info.gmpt_glyphorigin_x : 0
        #文字画像の幅を決定
        cx = info.gm_cellinc_x + ox
        #文字画像の高さを決定
        height = info.tm_ascent + info.tm_descent
        #サイズが確定した時点で、そのサイズのImageを生成
        image = Image.new(cx, height, C_BLACK)
        #文字を書き込む
        image.draw_font(ox, 0, char, @font)
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
        data_hash[char] = [cx, ox, binary]
      end
    end

    #セーブ用データの生成
    imagefont = [data_hash, @font.size, "v1.0"]

    #ハッシュをマーシャルダンプして保存
    open(file_name, "wb") do |fh|
      fh.write(Marshal.dump(imagefont))
    end
    puts
  end

  private

  #レンダリングする文字列を受け取る
  def add_data(sjis_chars)
    #１文字単位で取得
    sjis_chars.each_char do |char|
      #utf-8に変換出来ない２バイト文字を飛ばす
      char.encode("utf-8") rescue next
      #その文字をキーに、フォント情報を格納する
      @char_info[char] = @font.info(char)
    end
  end

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

