#! ruby -E utf-8

require 'dxruby'
require 'ayame'

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


#Soundコントロール
class SoundControl  < Control

  #リピート回数
  attr_reader :loop_count
  def loop_count=(loop_count)
    @loop_count = loop_count
    @entity.loop_count = [0, loop_count].max
  end

#音量
  attr_reader :volume
  def volume=(volume)
    @volume = volume
    @entity.set_volume(@volume, 0)
  end

  #パン
  attr_reader :pan
  def pan=(args)
    @pan = args
    @entity.set_pan(@pan, 0)
  end

  #再生／停止
  attr_reader :play
  def play=(args)
    @play = args
    if @play
      @entity.play(@loop_count)
    else
      @entity.stop
    end
  end

  attr_reader :file_path
  def file_path=(file_path)
    @file_path = file_path
    #ayameでコントロールを初期化
    @entity = Ayame.new(@file_path)
    #ストリーム駆動であれば処理を終える
    return if stream?
    #音源ファイルを先読みする
    if File.extname(@file_path) == ".ogg"
      @entity.predecode
    else
      @entity.prefetch
    end
  end

  attr_accessor :stream
  def stream?
    @stream
  end

  def initialize(options, inner_options, root_control)
    super
    self.stream = options[:stream] || true
    self.file_path = options[:file_path]

    #ループ回数（－１なら無限ループ）
    self.loop_count = options[:loop_count] || 1

    #ボリューム／フェード指定
    self.volume = options[:volume] || 90
  end

  def siriarize(options = {})

    options.update({
      :file_path => @file_path,
      :start => @start,
      :loop_start => @loop_start,
      :loop_end => @loop_end,
      :loop_count => @loop_count,
      :volume => @volume,
    })

    return  super(options)
  end

  #サウンドリソースを解放します
  def dispose
    if @entity
      @entity.dispose
      @entity = nil
    end
    super
  end
end
