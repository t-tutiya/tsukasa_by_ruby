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

module Tsukasa

class Window < Layout
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

  def close
    @close = true
  end

  def close?
    @close
  end

  def initialize( options = {}, 
                  yield_stack = nil, 
                  root_control = nil, 
                  parent_control = nil)
    #アプリ終了フラグ
    @close = false
    #マウスカーソル可視フラグ
    @mouse_enable = true
    super
  end

    super
  end

  def _SCRIPT_PARSER_(yield_stack, path:, ext_name:, parser:)
    require_relative path
    @script_parser[ext_name] = [
      Module.const_get(parser).new,
      Module.const_get(parser)::Replacer.new]
  end

  #ネイティブコードを読み込む
  def _LOAD_NATIVE_(yield_stack, _ARGUMENT_:)
    require _ARGUMENT_
  end

  #マウスカーソルの可視状態を設定する
  def _MOUSE_ENABLE_(yield_stack, _ARGUMENT_:)
    self.mouse_enable = _ARGUMENT_
  end

  #ウィンドウの閉じるボタンが押されたかどうかの判定
  def _CHECK_REQUESTED_CLOSE_(yield_stack, options = nil, &block)
    #「閉じる」ボタンが押下された
    if DXRuby::Input.requested_close?
      parse_block(nil, yield_stack, &block)
    end
  end
end

end
