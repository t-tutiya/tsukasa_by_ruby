#! ruby -E utf-8

#TODO将来的にはプリミティブライブラリへの依存を解消したい
require 'ayame'

###############################################################################
#TSUKASA for DXRuby ver2.1(2016/12/23)
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

  def initialize(options, yield_stack, root_control, parent_control, &block)
    super
    
    #音声ファイルを読み込む
    self.path = options[:path]
  end

  def update(mouse_pos_x, mouse_pos_y, index)
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
  def _PLAY_(yield_stack, options, &block)
    @entity.play( options[:_ARGUMENT_] || 1, #ループ回数（０なら無限）
                  options[:fadetime].to_f || 0)
  end

  #停止
  def _STOP_(yield_stack, options, &block)
    @entity.stop(options[:fadetime].to_f || 0)
  end

  #一時停止
  def _PAUSE_(yield_stack, options, &block)
    @entity.pause(options[:fadetime].to_f || 0)
  end

  #再開
  def _RESUME_(yield_stack, options, &block)
    @entity.resume(options[:fadetime].to_f || 0)
  end

  #音量
  def _VOLUME_(yield_stack, options, &block)
    @entity.set_volume( options[:_ARGUMENT_] || 90,
                        options[:fadetime].to_f || 0)
  end

  #パン
  def _PAN_(yield_stack, options, &block)
    @entity.set_pan( options[:_ARGUMENT_] || 0, #-100～100
                     options[:fadetime].to_f || 0)
  end
end

end
