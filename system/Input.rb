#! ruby -E utf-8
# coding: utf-8

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

#入力系ラッパーコントロール
class Input < Control
  attr_accessor :pad_number

  #パッドのＸ方向キー増分[-1,0,1]
  def x()
    DXRuby::Input.x(@pad_number)
  end

  #パッドのＹ方向キー増分[-1,0,1]
  def y()
    DXRuby::Input.y(@pad_number)
  end

  def initialize(system, pad_number: 0, **options, &block)
    @pad_number = pad_number
    super
  end

  def check_imple(condition, value)
    case condition
    #キーが押下された
    when :key_push
      Array(value).any?{|key_code| DXRuby::Input.key_push?(key_code)}
    #キーが押下されていない
    when :not_key_push
      !(Array(value).any?{|key_code| DXRuby::Input.key_push?(key_code)})
    #キーが継続押下されている
    when :key_down
      Array(value).any?{|key_code| DXRuby::Input.key_down?(key_code)}
    #キーが継続押下されていない
    when :not_key_down
      !(Array(value).any?{|key_code| DXRuby::Input.key_down?(key_code)})
    #キーが解除された
    when :key_up
      Array(value).any?{|key_code| DXRuby::Input.key_release?(key_code)}
    #キーが解除されていない
    when :not_key_up
      !(Array(value).any?{|key_code|DXRuby::Input.key_release?(key_code)})
    #パッドボタンが押された
    when :pad_down
      Array(value).any?{|pad_code| DXRuby::Input.pad_down?(pad_code, @pad_number)}
    #パッドボタンが継続押下されている
    when :pad_push
      Array(value).any?{|pad_code| DXRuby::Input.pad_push?(pad_code, @pad_number)}
    #パッドボタンが解除された
    when :pad_release
      Array(value).any?{|pad_code| DXRuby::Input.pad_release?(pad_code, @pad_number)}
    #マウス処理系
    when :mouse
      Array(value).any? do |key|
        case key
        when :push
          DXRuby::Input.mouse_push?( M_LBUTTON )
        when :down
          DXRuby::Input.mouse_down?( M_LBUTTON )
        when :up
          DXRuby::Input.mouse_release?( M_LBUTTON )
        when :right_down
          DXRuby::Input.mouse_down?( M_RBUTTON )
        when :right_push
          DXRuby::Input.mouse_push?( M_RBUTTON )
        when :right_up
          DXRuby::Input.mouse_release?( M_RBUTTON )
        end
      end
    else
      super
    end
  end
end

end