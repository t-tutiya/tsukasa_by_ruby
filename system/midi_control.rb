#! ruby -E utf-8

require 'dxruby'

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
class MidiControl  < Control

  #開始位置
  attr_reader :start
  def start=(start)
    @start = start
    @entity.start = start
  end

  #ループスタート位置
  attr_reader :loop_start
  def loop_start=(loop_start)
    @loop_start = loop_start
    @entity.loop_start = loop_start
  end

  #ループ終了位置
  attr_reader :loop_end
  def loop_end=(loop_end)
    @loop_end = loop_end
    @entity.loop_end = loop_end
  end

  #リピート回数
  attr_reader :loop_count
  def loop_count=(loop_count)
    @loop_count = loop_count
    @entity.loop_count = loop_count
  end

#音量
  attr_reader :volume
  def volume=(volume)
    @volume = volume
    @entity.set_volume(@volume * 255 / 100, 0)
  end

  #周波数
  attr_reader :frequency
  def frequency=(args)
    @frequency = args
    @entity.frequency = args
  end

  #パン
  attr_reader :pan
  def pan=(args)
    @pan = args
    @entity.pan = @pan * 100
  end

  #再生／停止
  attr_reader :play
  def play=(args)
    @play = args
    @entity.play(@loop_count)
  end

  attr_reader :file_path
  def file_path=(file_path)
    @file_path = file_path
    #DXRuby::Soundでコントロールを初期化
    @entity = Sound.new(@file_path)
  end

  def initialize(options, inner_options, root_control)
    super
    self.file_path = options[:file_path]

    #開始位置
    self.start = options[:start] || 0

    #ループ開始位置
    self.loop_start = options[:loop_start] || 0
    #ループ終了位置
    self.loop_end = options[:loop_end] || 0

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
