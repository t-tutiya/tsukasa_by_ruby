#! ruby -E utf-8
# coding: utf-8

#$VERBOSE = true

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

require_relative './ClickableLayout.rb'

module Tsukasa

class Window < ClickableLayout
  attr_accessor :auto_close #「閉じる」ボタンが押下された際に自動的に終了する

  def mouse_x()
    return DXRuby::Input.mouse_x
  end
  def mouse_x=(arg)
    DXRuby::Input.set_mouse_pos(arg, DXRuby::Input.mouse_y)
  end

  def mouse_y()
    return DXRuby::Input.mouse_y
  end
  def mouse_y=(arg)
    DXRuby::Input.set_mouse_pos(DXRuby::Input.mouse_x, arg)
  end

  def mouse_enable()
    @mouse_enable
  end
  def mouse_enable=(arg)
    @mouse_enable = arg
    DXRuby::Input.mouse_enable = @mouse_enable
  end

  def initialize( options = {}, 
                  yield_stack = nil, 
                  root_control = nil, 
                  parent_control = nil)
    #アプリ終了フラグ
    @close = false
    #マウスカーソル可視フラグ
    @mouse_enable = true
    #「閉じる」ボタンが押下された場合自動終了する
    @auto_close = true
    super
  end

  def update(mouse_pos_x, mouse_pos_y, index)
    #「閉じる」ボタンが押下された
    if DXRuby::Input.requested_close? and @auto_close
      @root_control.exit = true
    end

    super

    #カーソルが画面外に出た時／戻った時にカーソル可視状態を復帰する
    #※ウィンドウ枠に出た時に標準カーソルを表示させるために必要
    if @on_inner_control
      DXRuby::Input.mouse_enable = false unless @mouse_enable
    else
      DXRuby::Input.mouse_enable = true unless @mouse_enable
    end
  end

  #ウィンドウの閉じるボタンが押されたかどうかの判定
  def _CHECK_REQUESTED_CLOSE_(yield_stack, options = nil, &block)
    #「閉じる」ボタンが押下された
    if DXRuby::Input.requested_close?
      parse_block(nil, yield_stack, &block)
    end
  end

  def _RESIZE_(yield_stack, width:, height:)
    DXRuby::Window.resize(width, height)
    super
  end
end

end
