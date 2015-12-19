#! ruby -E utf-8

require 'dxruby'

require_relative "./tks_parser.rb"

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

  @@parser = TKSParser.new
  @@replacer = TKSParser::Replacer.new

  def initialize(control, root_control)
    @control = control
    @root_control = root_control
  end

  #ヘルパーメソッド群
  def commands(argument, options, block_stack, yield_block_stack, control, &block)
    @command_list = []
    @yield_block_stack = yield_block_stack
    @block_stack = block_stack

    if options[:script_file_path]
      if File.extname(options[:script_file_path]) == ".tks"
        #評価対象がｔｋｓファイルの場合の場合
        eval( @@replacer.apply(@@parser.parse(File.read(options[:script_file_path], encoding: "UTF-8"))).flatten.join("\n"), 
              nil, 
              File.expand_path(options[:script_file_path]))
      else
        #評価対象がスクリプトファイルの場合の場合
        eval( File.read(options[:script_file_path], encoding: "UTF-8"), 
              nil, 
              File.expand_path(options[:script_file_path]))
      end
    else
      raise unless block

      self.instance_exec(argument, options, control, &block)
    end
    return  @command_list
  end

  def method_missing(command_name, argument = nil, **options, &block)
    if [:_END_FUNCTION_].index(command_name)
      pp "#{command_name}コマンドは使用できません"
      raise
    end

    unless @control.respond_to?("command_" + command_name.to_s, true)
      # 組み込みコマンドが無い場合は_CALL_に差し替える
      options[:_FUNCTION_ARGUMENT_] = argument if argument
      argument = command_name
      command_name = :_CALL_
    end

    inner_options = {}
    inner_options[:yield_block_stack] = @yield_block_stack
    inner_options[:block_stack] = @block_stack
    inner_options[:block] = block if block

    #コマンドを登録する
    @command_list.push([command_name, argument, options, inner_options])
  end
end
