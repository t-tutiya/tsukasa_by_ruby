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

  def start=(start)
    @entity.start = start
  end

  def loop_start=(loop_start)
    @entity.loop_start = loop_start if @midi
  end

  def loop_end=(loop_end)
    @entity.loop_end = loop_end if @midi
  end

  def loop_count=(loop_count)
    @entity.loop_count = loop_count
  end

  def volume=(volume)
    @volume = volume
    @entity.set_volume(@volume, 0)
  end

  def initialize(options, inner_options, root_control)
    super
    command_load_sound(options, inner_options)
  end

  def siriarize(options = {})

    options.update({
      #未実装
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

  #音を再生します
  def command_load_sound(options, inner_options)
    @entity = Sound.new(options[:file_path])

    @midi = true if File.extname(options[:file_path]) == ".mid"

    #開始位置
    #TODO:これがwavでエラーにならないのはなんでだ？
    @entity.start = options[:start] || 0

    if @midi
      #ループ開始位置
      @entity.loop_start = options[:loop_start] || 0
      #ループ終了位置
      @entity.loop_end = options[:loop_end] || 0
    end

    #ループ回数（－１なら無限ループ）
    @entity.loop_count = options[:loop_count] || 1

    #ボリューム／フェード指定
    fade_time = options[:fade_ms] || 0
    @volume = options[:volume] || 230
    @entity.set_volume(@volume, fade_time)
  end

  #音を再生します
  def command_play(options, inner_options)
    @entity.play
  end

  #ＳＥの停止
  def command_stop(options, inner_options)
    @entity.stop
  end

  #フェード
  #TODO;上手く動いてないが理由が分からない
  def command_fade(options, inner_options)
    @entity.set_volume(options[:start] || @volume, 0)
    @entity.set_volume(options[:last]  || 0, options[:fade_ms] || 0)
  end
end
