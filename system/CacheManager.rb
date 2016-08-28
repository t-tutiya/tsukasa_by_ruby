#! ruby -E utf-8

###############################################################################
#TSUKASA for DXRuby ver2.0(2016/8/28)
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

module Tsukasa

#キャッシュ機構のベースクラス
class CacheManager

  def initialize(&block)
    #キャッシュの保存先
    @cache = Hash.new # {id: [entity, counter, parmanent_flag]}
    #リソースを生成するProcを保存する
    @create = block
  end

  #リソースの取得
  def load(id)
    #リソースファイルがキャッシュされている場合
    if @cache[id]
      #永続化指定されていなければカウンタを加算
      @cache[id][1] += 1 unless @cache[id][2]
    else
      #リソースの登録
      regist(id, false)
    end
    #リソースデータを返す
    return @cache[id][0]
  end

  #リソースの登録
  def regist(id, parmanent)
    begin
      #エントリを追加
      @cache[id] = [@create.call(id), 0, parmanent]
    rescue DXRuby::DXRubyError
      raise(Tsukasa::TsukasaLoadError.new(id))
    end
  end

  #リソースの解放
  def dispose(id)
    #永続化指定されている場合は解放しない
    return if @cache[id][2]

    #参照カウンタがゼロの場合
    if @cache[id][1] == 0
      #キャッシュを解放する
      force_dispose(id)
    else
      #カウンタ減算
      @cache[id][1] -= 1
    end
  end

  #リソースの強制的な解放
  def force_dispose(id)
    #リソース解放
    @cache[id][0].dispose()
    #キャッシュからエントリを削除
    @cache.delete(id)
  end
end

end