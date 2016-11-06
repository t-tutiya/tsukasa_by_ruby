#! ruby -E utf-8

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

class Data < Control

  def initialize(options, yield_stack, root_control, parent_control, &block)
    @datastore = {}
    super
  end

  def method_missing(command_name, argument = nil)
    #ゲッター／セッター判定
    if command_name.to_s[-1] == '='
      #セッターの場合
      @datastore[command_name.to_s.chop!.to_sym] = argument
    else
      #pp "in data"
      #pp command_name
      #pp @datastore
      #pp @datastore[command_name]
      #ゲッターの場合
      return @datastore[command_name]
    end
  end

end

end
