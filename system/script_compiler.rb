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
    @option = []
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
    return  @option || []
  end

  def impl(command_name, default_class, 
            option, 
            target: nil,
            all: false, 
            interrupt: false, 
            root: false,
            **sub_options, 
            &block)

    #キー名無しオプションがある場合はコマンド名をキーに設定する
    sub_options[command_name] = option if option != nil

    system_options ={:target_id =>     target,
                     :default_class => default_class,
                     :block_stack =>   @block_stack,
                     :all => all,
                     :root => root,
                     :interrupt => interrupt}

    system_options[:block] = block if block

    #組み込みコマンドリストに含まれていない場合
    unless @@builtin_command_list.include?(command_name)
      #ALIASされているのでコマンドを差し替える
      sub_options[:call_builtin_command] = command_name
      command_name = :call_builtin_command
    end

    #コマンドを登録する
    @option.push([command_name,
                  sub_options, 
                  system_options,
                  ])
  end

  #コマンドに対応するメソッドを生成する。
  def self.impl_define(command_name, 
                       default_class = :Anonymous, 
                       args_format)
    #組み込みコマンド名としてリストに追加する
    @@builtin_command_list.push(command_name)

    define_method(command_name) do |option = nil, 
                                    **option_hash, 
                                    &block|
                                    

      case args_format
      when :target_id #無名引数＝送信先ＩＤ（省略可）
        if option
          option_hash[:target] = option 
          option = nil
        end
      when :option #無名引数必須
        raise unless option
      when :nop #無名引数禁止
        raise if option
      else
        raise
      end

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
  impl_define :end_frame,                :nop

  #ＳＥの再生と停止（暫定）
  impl_define :se_play, :nop
  impl_define :se_stop, :nop

  #移動
  impl_define :move,                      :nop
  impl_define :move_line,                 :nop
  impl_define :move_line_with_skip,       :nop
  #フラグ設定
  impl_define :flag,                      :nop

  #フェードトランジション
  impl_define :transition_fade,           :nop

  impl_define :change_default_target, :option

  impl_define :set,                :target_id

  #コントロールの生成
  impl_define :create,  :option
  #コントロールの削除
  impl_define :delete, :target_id

  #コントロール単位でイベント駆動するコマンド群を格納する
  impl_define :event,                 :option

  #各種ウェイト処理
  impl_define :wait,                 :option
  impl_define :check,            :option

  impl_define :EXP,   :nop

  #これブロックが継承されないかも
  impl_define :_CALL_,                  :option
  impl_define :call_builtin_command,           :option

  #制御構文 if系
  impl_define :_IF_,    :option
  impl_define :_THEN_,  :nop
  impl_define :_ELSE_,  :nop
  impl_define :_ELSIF_, :option

  #case-when文
  #TODO：現状では受け取れる式は１個のみとする
  #TODO：複数取れるべきだが、現仕様では他のコマンドと整合しない
  impl_define :_CASE_,  :option
  impl_define :_WHEN_,  :option

  #while文
  impl_define :_WHILE_, :option
  impl_define :_BREAK_, :nop

  #コマンド名の再定義
  impl_define :_ALIAS_, :option
  #コルーチン呼び出し
  impl_define :_YIELD_, :nop

  #実行時評価
  impl_define :_EVAL_, :option
  #ユーザー定義コマンドの宣言
  impl_define :define, :option
end
