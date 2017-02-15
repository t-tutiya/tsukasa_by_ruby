#! ruby -E utf-8

#TODO将来的にはプリミティブライブラリへの依存を解消したい

puts ENV["APPVEYOR_BUILD"]

unless ENV["APPVEYOR_BUILD"] == "true"
  require_relative './ayame.so'
end

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

require_relative './Control.rb'

module Tsukasa

#Soundコントロール
class Sound  < Control
  attr_reader :path
  def path=(arg)
    unless arg
      raise(Tsukasa::TsukasaError.new("Soundのpathが設定されていません")) 
    end
    @path = arg
    #音源ファイルを読み込んで初期化する
    @entity = Ayame.new(arg)
  end

  def initialize(system, options, &block)
    super
    
    #音声ファイルを読み込む
    self.path = options[:path]
  end

  def update(mouse_pos_x, mouse_pos_y)
    Ayame.update
    super
  end

  #サウンドリソースを解放します
  def dispose
    if @entity
      @entity.dispose
      @entity = nil
    end
    super
  end
  
  #再生
  def _PLAY_(_ARGUMENT_: 1, fadetime: 0.0)
    @entity.play( _ARGUMENT_, #ループ回数（０なら無限）
                  fadetime.to_f)
  end

  #停止
  def _STOP_(fadetime: 0.0)
    @entity.stop(fadetime)
  end

  #一時停止
  def _PAUSE_(fadetime: 0.0)
    @entity.pause(fadetime)
  end

  #再開
  def _RESUME_(fadetime: 0.0)
    @entity.resume(fadetime)
  end

  #音量
  def _VOLUME_(_ARGUMENT_: 90, fadetime: 0.0)
    @entity.set_volume( _ARGUMENT_ 90,
                        fadetime)
  end

  #パン
  def _PAN_(_ARGUMENT_: 10, fadetime: 0.0)
    @entity.set_pan( _ARGUMENT_, #-100～100
                     fadetime)
  end
end

end
