#! ruby -E utf-8

require 'dxruby'

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

###############################################################################
#シーンクラス
###############################################################################

class SceneControl < Control

  attr_accessor  :update_sleep  #更新スリープフラグ
  attr_accessor  :render_sleep  #描画スリープフラグ

  def initialize(options, yield_block_stack, root_control, &block)
    @update_sleep = false
    @render_sleep = false

    super
  end

  def update(mouse_pos_x, mouse_pos_y)
    #更新スリープフラグが立っていないなら通常通りの処理を進める
    unless @update_sleep
      return super
    end

    #更新スリープフラグが立っているなら本コントロールのみ処理する

    #コマンドリストが空になるまで走査し、コマンドを実行する
    until @command_list.empty?
      #コマンドリストの先頭要素を取得
      command_name, argument, options, yield_block_stack, block = @command_list.shift

      #今フレーム処理終了判定
      break if command_name == :_END_FRAME_

      #コマンドがメソッドとして存在する場合
      if self.respond_to?(command_name, true)
        #コマンドを実行する
        send(command_name, argument, options, yield_block_stack, &block)
      else
        #ユーザー定義コマンドとみなして実行する
        call_user_command(command_name, argument, options, yield_block_stack,&block)
      end
    end

    return 0, 0
  end

  #描画
  def render(offset_x, offset_y, target, 
              parent_control_width, parent_control_height)
    #描画スリープフラグが立っていないなら通常通りの処理を進める
    unless @render_sleep
      return super
    end

    #描画スリープフラグが立っているならなにもせず終了する
    return 0, 0
  end
end
