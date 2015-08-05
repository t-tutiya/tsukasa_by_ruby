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
  def commands(argument, system_options = {}, system_property = {}, &block)
    @option = []
    @yield_block = nil

    @system_property = system_property
    @global_flag = @system_property[:global_flag]

    if argument[:script_path]
      #評価対象がスクリプトファイルの場合の場合
      eval( File.read(argument[:script_path], encoding: "UTF-8"), 
            binding, 
            File.expand_path(argument[:script_path]))
    else
      raise if !block

      #yieldブロックが設定されている場合
      @block_stack = system_options[:block_stack]

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
                                    target = nil,
                                    **option_hash, 
                                    &block|
      #引数のチェック。:allならチェックしない
      if !args_format.index(:all)
        #無名引数が定義されておらず、かつ呼び出し時に設定されている場合
        if !args_format.index(:option) and option
          #ターゲットも設定されている場合は書式エラーとして例外
          raise if target
          
          #構文上のミスなので中身をスライドさせる
          #TODO：もうちょっと上手い実装は無いものか
          target = option
          option = nil
        end

        #ハッシュが定義されておらず、かつ呼び出し時に設定されている場合例外
        #TODO：この処理自体を再検討
        if !args_format.index(:option_hash) and !option_hash.empty?
          if option_hash[:all] or option_hash[:interrupt]
            #nop
          else
            raise 
          end
        end
        #ブロックが定義されておらず、かつ呼び出し時に設定されている場合例外
        raise if !args_format.index(:block)       and block
      end
      impl(command_name, default_class, option, option_hash, &block)
    end
  end

  #プロシージャー登録されたコマンドが宣言された場合にここで受ける
  def method_missing(command_name, option = nil, **options, &block)
    options[command_name] = option
    #TODO：存在しないメソッドが実行される問題について要検討
    impl(:call_function, :Anonymous, command_name, options, &block)
  end

  #今フレームを終了する
  impl_define :end_frame,                []

  #ＳＥの再生と停止（暫定）
  impl_define :se_play, []
  impl_define :se_stop, []

  #次に読み込むスクリプトファイルの指定
  impl_define :next_scenario, :RenderTargetContainer, [:option]
  impl_define :load_script,   :RenderTargetContainer, [:option]

  impl_define :wake,                      [:option_hash]

  #移動
  impl_define :move,                      [:option_hash]
  impl_define :move_line,                 [:option_hash]
  impl_define :move_line_with_skip,       [:option_hash]
  #フラグ設定
  impl_define :flag,                      [:option_hash]

  #フェードトランジション
  impl_define :transition_fade,           [:option_hash]

  impl_define :change_default_target, [:all]

  impl_define :set,                [:option_hash]

  #コントロールの生成
  impl_define :create,  [:all]
  #コントロールの削除
  impl_define :delete, []

  #コントロール単位でイベント駆動するコマンド群を格納する
  impl_define :event,                 [:all]

  #各種ウェイト処理
  impl_define :wait,                  [:all]
  impl_define :check,            [:option, :block]

  impl_define :EXP,   [:block]

  #これブロックが継承されないかも
  impl_define :call_function,                  [:all]
  impl_define :call_builtin_command,                  [:all]

  #制御構文 if系
  impl_define :_IF_,    [:option, :block]
  impl_define :_THEN_,  [:block]
  impl_define :_ELSE_,  [:block]
  impl_define :_ELSIF_, [:option, :block]

  #case-when文
  #TODO：現状では受け取れる式は１個のみとする
  #TODO：複数取れるべきだが、現仕様では他のコマンドと整合しない
  impl_define :_CASE_,  [:option, :block]
  impl_define :_WHEN_,  [:option, :block]

  #while文
  impl_define :_WHILE_, [:option, :block]

  #コマンド名の再定義
  impl_define :_ALIAS_,   [:option, :option_hash]
  #コルーチン呼び出し
  impl_define :_YIELD_, [:option_hash]

  #実行時評価
  impl_define :_EVAL_, [:option]
  #ユーザー定義コマンドの宣言
  impl_define :define, [:option, :block]
end
