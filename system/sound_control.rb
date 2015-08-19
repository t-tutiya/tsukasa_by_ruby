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
  def initialize(options, inner_options, root_control)
    super
    command_load_sound(options, inner_options)
  end

  #サウンドリソースを解放します
  def dispose
    @entity.dispose
    super
  end

  #音を再生します
  def command_load_sound(options, inner_options)
    @entity = Sound.new(options[:file_path])

    #開始位置
    @entity.start = options[:start] || 0

    #ループ開始位置
    @entity.loop_start = options[:loop_start] || 0
    #ループ終了位置
    @entity.loop_end = options[:loop_end] || 0
    #ループ回数（－１なら無限ループ）
    @entity.loop_count = options[:loop_count] || 1

    #ボリューム／フェード指定
    fade_time = options[:fade_time] || 0
    volume = options[:volume] || 230
    @entity.set_volume(volume, fade_time)
  end

  #音を再生します
  def command_play(options, inner_options)
    @entity.play
  end

  #ＳＥの停止
  def command_stop(options, inner_options)
    @entity.stop
  end

  #再生開始位置を設定します
  def command_start(options, inner_options)
    @entity.start = options[:_ARGUMENT_]
  end

  #ループ時の開始位置
  def command_loop_start(options, inner_options)
    @entity.loop_start = options[:_ARGUMENT_]
  end

  #ループ時の終了位置
  def command_loop_end(options, inner_options)
    @entity.loop_end = options[:_ARGUMENT_]
  end

  #ループ回数
  def command_loop_count(options, inner_options)
    @entity.loop_count = options[:_ARGUMENT_]
  end

  #ボリュームを設定します（timeでフェード設定）
  def command_set_volume(options, inner_options)
    fade_time = options[:fade_time] || 0
    @entity.set_volume(options[:volume], fade_time)
  end
end
