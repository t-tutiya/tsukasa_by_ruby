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

class ScriptCompiler

  def initialize()
    @command_list = []
  end

  def eval_commands(script, fname = "(eval)", yield_block_stack)
    @yield_block_stack = yield_block_stack
    @command_list.clear

    eval(script, nil, fname)

    return @command_list
  end

  def eval_block( argument, options, yield_block_stack, &block)
    raise unless block

    @yield_block_stack = yield_block_stack
    @command_list.clear

    self.instance_exec(argument, options, &block)

    return @command_list
  end

  def method_missing(command_name, argument = nil, **options, &block)
    if [:_END_FUNCTION_].index(command_name)
      pp "#{command_name}コマンドは使用できません"
      raise
    end

    #コマンドを登録する
    @command_list.push([
      command_name, argument, options, @yield_block_stack, block || nil,
    ])
  end
end
