#! ruby -E utf-8

require 'dxruby'

#require_relative "./tks_parser.rb"

###############################################################################
#TSUKASA for DXRuby ver1.0(2015/12/24)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
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

class ScriptCompiler

  attr_reader :_TEMP_
  attr_reader :_LOCAL_
  attr_reader :_SYSTEM_

  alias :_T :_TEMP_
  alias :_L :_LOCAL_
  alias :_S :_SYSTEM_

  def initialize(root_control)
    @_TEMP_ = root_control._TEMP_
    @_LOCAL_ = root_control._LOCAL_
    @_SYSTEM_ = root_control._SYSTEM_

    @command_list = []
  end

  def eval_commands(script, fname = "(eval)", 
                    block_stack, yield_block_stack, control, command_list, &block)
    @control = control

    @yield_block_stack = yield_block_stack
    @block_stack = block_stack


    eval(script, nil, fname)

    @command_list, command_list = command_list, @command_list
    command_list.concat(@command_list)
    @command_list.clear

    return command_list
  end

  def eval_block( argument, options, 
                  block_stack, yield_block_stack, control, command_list, &block)
    @control = control

    @yield_block_stack = yield_block_stack
    @block_stack = block_stack

    raise unless block

    self.instance_exec(argument, options, control, &block)

    @command_list, command_list = command_list, @command_list
    command_list.concat(@command_list)
    @command_list.clear

    return command_list
  end

  def method_missing(command_name, argument = nil, **options, &block)
    if [:_END_FUNCTION_].index(command_name)
      pp "#{command_name}コマンドは使用できません"
      raise
    end

    if @control.respond_to?(command_name, true)
      #コマンドを登録する
      @command_list.push([
        command_name, 
        argument, 
        options, 
        @block_stack,
        @yield_block_stack,
        block || nil ,
      ])
    else
      # 組み込みコマンドが無い場合は_CALL_に差し替える
      @command_list.push([
        :_CALL_, 
        command_name, 
        options.update({:_FUNCTION_ARGUMENT_ => argument || nil}), 
        @block_stack,
        @yield_block_stack,
        block || nil ,
      ])
    end
  end
end
