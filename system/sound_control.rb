#! ruby -E utf-8

require 'dxruby'
require 'ayame'

###############################################################################
#TSUKASA for DXRuby ver1.2(2016/3/1)
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


#Soundコントロール
class SoundControl  < Control
  attr_reader :file_path
  def file_path=(args)
    #音源ファイルを読み込んで初期化する
    @entity = Ayame.new(args)
  end

  def initialize(options, yield_block_stack, root_control, &block)
    super
    if options[:file_path]
      self.file_path = options[:file_path]
    end
  end

  def update
    Ayame.update
    super
  end

  def serialize(control_name = :SoundControl, **options)
    
    options.update({
      :file_path  => @file_path,
    })

    return super(control_name, options)
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
  def _PLAY_(argument, options, yield_block_stack, &block)
    raise unless @entity
    @entity.play( argument || 1, #ループ回数（０なら無限）
                  options[:fadetime].to_f || 0)
  end

  #停止
  def _STOP_(argument, options, yield_block_stack, &block)
    raise unless @entity
    @entity.stop(options[:fadetime].to_f || 0)
  end

  #一時停止
  def _PAUSE_(argument, options, yield_block_stack, &block)
    raise unless @entity
    @entity.pause(options[:fadetime].to_f || 0)
  end

  #再開
  def _RESUME_(argument, options, yield_block_stack, &block)
    raise unless @entity
    @entity.resume(options[:fadetime].to_f || 0)
  end

  #音量
  def _VOLUME_(argument, options, yield_block_stack, &block)
    raise unless @entity
    @entity.set_volume( argument || 90,
                        options[:fadetime].to_f || 0)
  end

  #パン
  def _PAN_(argument, options, yield_block_stack, &block)
    raise unless @entity
    @entity.set_pan( argument || 0, #-100～100
                     options[:fadetime].to_f || 0)
  end
end
