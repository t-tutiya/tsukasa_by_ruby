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
  include Resource

  def initialize(argument, &block)
    @option = {}
    @option_stack = []
    @key_name = :commands
    @yield_block = nil

    if argument[:script_path]
      #評価対象がスクリプトファイルの場合の場合
      eval( File.read(argument[:script_path], encoding: "UTF-8"), 
            binding, 
            File.expand_path(argument[:script_path]))
    else
      raise if !block

      #yieldブロックが設定されている場合
      @yield_block = argument[:yield_block]

      self.instance_exec(**argument, &block)
    end
    @script_storage = @option[@key_name] || []
  end

  def impl(command_name, default_class, target, option, sub_options = {}, &block)
    #キー名無しオプションがある場合はコマンド名をキーに設定する
    sub_options[command_name] = option if option != nil

    sub_options[:block] = block if block

    #存在していないキーの場合は配列として初期化する
    @option[@key_name] ||= []

    #コマンドを登録する
    @option[@key_name].push([ command_name,
                              sub_options, 
                              {:target_id => target,
                               :default_class => default_class,
                               :yield_block => @yield_block},
                              ])
  end

  #コマンドに対応するメソッドを生成する。
  def self.impl_define(command_name, 
                       default_class = :Anonymous, 
                       args_format)
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
        raise if !args_format.index(:option_hash) and !option_hash.empty?
        #ブロックが定義されておらず、かつ呼び出し時に設定されている場合例外
        raise if !args_format.index(:block)       and block
      end
      impl(command_name, default_class, target, option, option_hash, &block)
    end
  end

  #プロシージャー登録されたコマンドが宣言された場合にここで受ける
  def method_missing(command_name, option = nil, target = nil, **options, &block)
    options[command_name] = option
    #TODO：存在しないメソッドが実行される問題について要検討
    impl(:call_function, :Anonymous, target, command_name, options, &block)
  end

  #次フレームに送る
  impl_define :next_frame,                []
  #キー入力待ち
  impl_define :pause,                     []

  impl_define :wait_wake,                 []

  impl_define :wait_input_key,            []

  #ボタン制御コマンド群
  #TODO:これは無くても動いて欲しいが、現状だとscript_compilerを通す為に必要
  impl_define :normal,                    []

  impl_define :wait_child_controls_idle,  []

  impl_define :check_key_push,            []

  impl_define :wait_key_push_with_idle,   []
  impl_define :wait_idle,                 []

  #単一オプションを持つコマンド
  #特定コマンドの終了を待つ
  impl_define :wait_command,                [:option]
  #特定フラグの更新を待つ（現状では予めnilが入ってないと機能しない）
  impl_define :wait_flag,                   [:option]

  impl_define :wait_command_with_key_push,  [:option]

  #スリープモードの更新
  impl_define :sleep_mode,                  [:option]
  #スキップモードの更新
  impl_define :skip_mode,                   [:option]

  #指定フレーム待つ
  impl_define :wait,                        [:option]

  #次に読み込むスクリプトファイルの指定
  impl_define :next_scenario, :LayoutContainer, [:option]
  impl_define :load_script,   :LayoutContainer, [:option]

  #コントロールの削除
  impl_define :dispose,       :LayoutContainer, [:option]

  impl_define :wake,                      [:option_hash]
  #移動
  impl_define :move,                      [:option_hash]
  impl_define :move_line,                 [:option_hash]
  impl_define :move_line_with_skip,       [:option_hash]
  #フラグ設定
  impl_define :flag,                      [:option_hash]

  #フェードトランジション
  impl_define :transition_fade,           [:option_hash]
  impl_define :transition_fade_with_skip, [:option_hash]

  impl_define :change_default_target, [:all]

  #コントロールの生成
  impl_define :create,                [:all]
  #コントロール単位でイベント駆動するコマンド群を格納する
  impl_define :event,                 [:all]

  #画像の差し替え
  impl_define :image_change, :ImageControl, [:all]

  #文字レンダラの指定
  #TODO:これはtext_layer内に動作を限定できないか？
  impl_define :char_renderer,         :CharContainer, [:block]
  #文字
  impl_define :char,                  :CharContainer, [:option]
  #文字列
  impl_define :text,                  :CharContainer, [:option]
  #インデント設定
  impl_define :indent,                :CharContainer, [:option]
  #文字描画速度の設定
  impl_define :delay,                 :CharContainer, [:option]
  #改行
  impl_define :line_feed,             :CharContainer, []
  #改ページ
  impl_define :flash,                 :CharContainer, []
  #画像スタック
  impl_define :graph,                 :CharContainer, [:all]
  #ルビ文字の出力
  impl_define :rubi_char,             :CharContainer, [:all]
  #複数ルビ文字列の割り付け
  impl_define :rubi,                  :CharContainer, [:all]
  #デフォルト
  impl_define :default_font_config,   :CharContainer, [:all]
  #現在値
  impl_define :font_config,           :CharContainer, [:all]
  #現在値をリセット
  impl_define :reset_font_config,     :CharContainer, [:all]
  #デフォルト
  impl_define :default_style_config,  :CharContainer, [:all]
  #現在値
  impl_define :style_config,          :CharContainer, [:all]
  #現在値をリセット
  impl_define :reset_style_config,    :CharContainer, [:all]
  #レンダリング済みフォントの登録
  impl_define :map_image_font,        :CharContainer, [:all]

  #制御構文 if系
  impl_define :IF,    [:option, :block]
  impl_define :THEN,  [:block]
  impl_define :ELSE,  [:block]
  impl_define :ELSIF, [:option, :block]

  #case-when文
  #TODO：現状では受け取れる式は１個のみとする
  #TODO：複数取れるべきだが、現仕様では他のコマンドと整合しない
  impl_define :CASE,  [:option, :block]
  impl_define :WHEN,  [:option, :block]

  #while文
  impl_define :WHILE, [:option, :block]

  impl_define :EXP,   [:block]

  #コマンド列のブロック化
  impl_define :about, [:block]

  impl_define :visible, [:option]

  impl_define :se_play, [:option]
  impl_define :se_stop, [:option]

  impl_define :sleep_mode_all, [:option]
  impl_define :skip_mode_all, [:option]

  #target変更は受け付けない(Controlクラスに登録)
  def define(command_name, &block)
    impl(:define, :Anonymous, nil, command_name, &block)
  end

  def _YIELD_(target = nil, **options)
    options[:yield_block] = @yield_block
    impl(:YIELD, :Anonymous, nil, nil, **options)
  end

  #eval（予約語の為メソッド名差し替え）
  def EVAL(option, target = nil)
    impl(:eval,  :Anonymous, target, option)
  end

  #ヘルパーメソッド群
  def commands()
    return @script_storage
  end
end
