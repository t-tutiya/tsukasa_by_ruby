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
#TODO：ほとんどテストできていません。ひとまずDXRuby::Soundの機能を全てラップしました
#TODO：DirectSoundの仕様上、一つ目の初期化時に時間がかかるようです。
class SoundControl  < Control

  attr_reader :start
  def start=(start)
    @start = start
    @entity.start = start
  end

  attr_reader :loop_start
  def loop_start=(loop_start)
    @loop_start = loop_start
    @entity.loop_start = loop_start if @midi
  end

  attr_reader :loop_end
  def loop_end=(loop_end)
    @loop_end = loop_end
    @entity.loop_end = loop_end if @midi
  end

  attr_reader :loop_count
  def loop_count=(loop_count)
    @loop_count = loop_count
    @entity.loop_count = loop_count
  end

  attr_reader :volume
  def volume=(volume)
    @volume = volume
    @entity.set_volume(@volume, 0)
  end

  attr_reader :frequency
  def frequency=(args)
    @frequency = args
    @entity.frequency = args
  end

  attr_reader :pan
  def pan=(args)
    @pan = args
    @entity.pan = args
  end

  attr_reader :play
  def play=(args)
    @play = args
    if @play
      @entity.play
    else
      @entity.stop
    end
  end

  attr_reader :file_path
  def file_path=(file_path)
    @file_path = file_path
    @entity = Sound.new(@file_path)
    @midi = true if File.extname(@file_path) == ".mid"
  end

  def initialize(options, inner_options, root_control)
    super
    self.file_path = options[:file_path]

    #開始位置
    #TODO:これがwavでエラーにならないのはなんでだ？
    self.start = options[:start] || 0

    #ループ開始位置
    self.loop_start = options[:loop_start] || 0
    #ループ終了位置
    self.loop_end = options[:loop_end] || 0

    #ループ回数（－１なら無限ループ）
    self.loop_count = options[:loop_count] || 1

    #ボリューム／フェード指定
    self.volume = options[:volume] || 230
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
    @entity.dispose
    super
  end
end
