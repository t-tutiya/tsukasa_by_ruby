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

class ScriptCompiler
  @@builtin_command_list = Array.new #組み込みコマンドリスト

  def builtin_command_list
    @@builtin_command_list
  end

  #ヘルパーメソッド群
  def commands(argument, block_stack = nil, &block)
    @command_list = []
    @yield_block = nil

    if argument[:script_path]
      #評価対象がスクリプトファイルの場合の場合
      eval( File.read(argument[:script_path], encoding: "UTF-8"), 
            binding, 
            File.expand_path(argument[:script_path]))
    else
      raise unless block

      #yieldブロックが設定されている場合
      @block_stack = block_stack

      self.instance_exec(**argument, &block)
    end
    return  @command_list || []
  end

  def impl(command_name, default_class, 
            option, 
#            target: nil,
#            all: false, 
#            interrupt: false, 
#            root: false,
            **sub_options, 
            &block)

    #キー名無しオプションがある場合はコマンド名をキーに設定する
    sub_options[command_name] = option if option != nil

    system_options ={#:target_id =>     target,
                     :default_class => default_class,
                     :block_stack =>   @block_stack,
#                     :all => all,
#                     :root => root,
#                     : => interrupt
                     }

    system_options[:block] = block if block

    #組み込みコマンドリストに含まれていない場合
    unless @@builtin_command_list.include?(command_name)
      #ALIASされているのでコマンドを差し替える
      sub_options[:call_builtin_command] = command_name
      command_name = :call_builtin_command
    end

    #コマンドを登録する
    @command_list.push([command_name,sub_options, system_options])
  end

  #コマンドに対応するメソッドを生成する。
  def self.impl_define(command_name, default_class = :Anonymous)
    #組み込みコマンド名としてリストに追加する
    @@builtin_command_list.push(command_name)

    define_method(command_name) do |option = nil, **option_hash, &block|
      impl(command_name, default_class, option, option_hash, &block)
    end
  end

  #プロシージャー登録されたコマンドが宣言された場合にここで受ける
  def method_missing(user_function_name, option = nil, **options, &block)
    #無名引数がある場合、関数名をキーに格納する
    options[user_function_name.to_sym] = option if option
    #TODO：存在しないメソッドが実行される問題について要検討
    impl(:_CALL_, :Anonymous, user_function_name, options, &block)
  end

  #今フレームを終了する
  impl_define :end_frame

  #ＳＥの再生と停止（暫定）
  impl_define :se_play
  impl_define :se_stop

  #移動
  impl_define :move
  impl_define :move_line
  impl_define :move_line_with_skip
  #フラグ設定
  impl_define :flag

  #フェードトランジション
  impl_define :transition_fade

  impl_define :change_default_target

  impl_define :_SET_
  impl_define :_SET_DATA_
  impl_define :_SEND_

  #スクリプトファイルの挿入
  impl_define :_INCLUDE_

  #コントロールの生成
  impl_define :_CREATE_
  #コントロールの削除
  impl_define :_DELETE_

  #コントロール単位でイベント駆動するコマンド群を格納する
  impl_define :event

  #各種ウェイト処理
  impl_define :_WAIT_
  impl_define :_CHECK_

  impl_define :EXP

  #これブロックが継承されないかも
  impl_define :_CALL_
  impl_define :call_builtin_command

  #制御構文 if系
  impl_define :_IF_
  impl_define :_THEN_
  impl_define :_ELSE_
  impl_define :_ELSIF_

  #case-when文
  #TODO：現状では受け取れる式は１個のみとする
  #TODO：複数取れるべきだが、現仕様では他のコマンドと整合しない
  impl_define :_CASE_
  impl_define :_WHEN_

  #while文
  impl_define :_WHILE_
  impl_define :_BREAK_

  #コマンド名の再定義
  impl_define :_ALIAS_
  #コルーチン呼び出し
  impl_define :_YIELD_
  impl_define :_END_SCOPE_

  #実行時評価
  impl_define :_EVAL_
  #ユーザー定義コマンドの宣言
  impl_define :_DEFINE_
end
