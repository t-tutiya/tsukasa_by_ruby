#! ruby -E utf-8

require 'dxruby'

require_relative "./tks_parser.rb"

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

class ScriptCompiler

  @@parser = TKSParser.new
  @@replacer = TKSParser::Replacer.new

  def initialize(control, root_control)
    @control = control
    @root_control = root_control
  end

  #ヘルパーメソッド群
  def commands(argument, block_stack = nil, &block)
    @command_list = []
    @yield_block = nil

    if argument[:script_path]
      if File.extname(argument[:script_path]) == ".tks"
        #評価対象がｔｋｓファイルの場合の場合
        eval( @@replacer.apply(@@parser.parse(File.read(argument[:script_path], encoding: "UTF-8"))).flatten.join("\n").encode("Windows-31J"), 
              nil, 
              File.expand_path(argument[:script_path]))
      else
        #評価対象がスクリプトファイルの場合の場合
        eval( File.read(argument[:script_path], encoding: "UTF-8"), 
              nil, 
              File.expand_path(argument[:script_path]))
      end
    else
      raise unless block

      #yieldブロックが設定されている場合
      @block_stack = block_stack

      self.instance_exec(**argument, &block)
    end
    return  @command_list
  end

  def method_missing(command_name, option = nil, **options, &block)

    if @control.respond_to?("command_" + command_name.to_s, true)
      # 組み込みコマンドがある場合はそのまま呼ぶ
      options[:_ARGUMENT_] = option if option
    else
      # 組み込みコマンドが無い場合は_CALL_に差し替える
      options[:_FUNCTION_ARGUMENT_] = option if option
      options[:_ARGUMENT_] = command_name
      command_name = :_CALL_
    end

    inner_options = {}
    inner_options[:block_stack] = @block_stack
    inner_options[:block] = block if block

    #コマンドを登録する
    @command_list.push([command_name, options, inner_options])
  end
end
