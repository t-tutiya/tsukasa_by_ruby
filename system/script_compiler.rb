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

module Tsukasa

class ScriptCompiler

  def initialize(argument, &block)
    @option = {}
    @option_stack = []
    @key_name = :commands
    @key_name_stack = []
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

  #オプション無し
  def self.impl_non_option(command_name, default_class = :Anonymous)
    define_method(command_name) do |target = nil|
      impl(command_name, default_class, target, nil, {})
    end
  end

  #名前なしオプション（１個）
  def self.impl_one_option(command_name, default_class = :Anonymous)
    define_method(command_name) do |option, target = nil|
      impl(command_name, default_class, target, option, {})
    end
  end

  #名前付きオプション群
  def self.impl_options(command_name, default_class = :Anonymous)
    define_method(command_name) do |target = nil, **options |
      impl(command_name, default_class, target, nil, options)
    end
  end

  #ブロック
  def self.impl_block(command_name, default_class = :Anonymous)
    define_method(command_name) do |target = nil,&block|
      impl(command_name, default_class, target, nil, &block)
    end
  end

  #名前無しオプション（１個）＆名前付オプション群＆ブロック
  def self.impl_option_options_block(command_name, default_class = :Anonymous)
    define_method(command_name) do |option , target = nil,**options, &block|
      impl(command_name, default_class, target, option, options, &block )
    end
  end

  #プロシージャー登録されたコマンドが宣言された場合にここで受ける
  def method_missing(command_name, target = nil, **options, &block)
    #TODO：存在しないメソッドが実行される問題について要検討
    impl(:call_function, :Anonymous, target, command_name, options, &block)
  end

  #次フレームに送る
  impl_non_option :next_frame
  #キー入力待ち
  impl_non_option :pause

  impl_non_option :wait_wake

  impl_options :wake
  impl_non_option :wait_input_key

  #改行
  impl_non_option :line_feed,  :CharContainer
  #改ページ
  impl_non_option :flash,      :CharContainer

  #ボタン制御コマンド群
  #TODO:これは無くても動いて欲しいが、現状だとscript_compilerを通す為に必要
  impl_non_option :normal

  #単一オプションを持つコマンド
  #特定コマンドの終了を待つ
  impl_one_option :wait_command
  #特定フラグの更新を待つ（現状では予めnilが入ってないと機能しない）
  impl_one_option :wait_flag

  #次に読み込むスクリプトファイルの指定
  impl_one_option :next_scenario, :LayoutContainer
  impl_one_option :load_script, :LayoutContainer

  #コントロールの削除
  impl_one_option :dispose,       :LayoutContainer

  impl_non_option :wait_child_controls_idle

  impl_non_option :check_key_push
  impl_one_option :wait_command_with_key_push

  #スリープモードの更新
  impl_one_option :sleep_mode
  #スキップモードの更新
  impl_one_option :skip_mode

  #文字
  impl_one_option :char,         :CharContainer
  #指定フレーム待つ
  impl_one_option :wait
  #インデント設定
  impl_one_option :indent,       :CharContainer
  #文字描画速度の設定
  impl_one_option :delay,        :CharContainer

  #移動
  impl_options :move
  impl_options :move_line
  impl_options :move_line_with_skip

  #フェードトランジション
  impl_options :transition_fade
  impl_options :transition_fade_with_skip
  #フラグ設定
  impl_options :flag
  #ブロックを持つコマンド

  #文字レンダラの指定
  #TODO:これはtext_layer内に動作を限定できないか？
  impl_block :char_renderer,     :CharContainer

  #コマンド列のブロック化
  impl_block :about

  #オプション／サブオプション（省略可）／ブロックを持つコマンド

  #文字列
  impl_one_option :text,         :CharContainer

  impl_option_options_block :change_default_target

  #コントロールの生成
  impl_option_options_block :create
  #コントロール単位でイベント駆動するコマンド群を格納する
  impl_option_options_block :event

  #画像スタック
  impl_option_options_block :graph,               :CharContainer
  #ルビ文字の出力
  impl_option_options_block :rubi_char,           :CharContainer
  #複数ルビ文字列の割り付け
  impl_option_options_block :rubi,                :CharContainer
  #デフォルト
  impl_option_options_block :default_font_config, :CharContainer
  #現在値
  impl_option_options_block :font_config,         :CharContainer
  #現在値をリセット
  impl_option_options_block :reset_font_config,   :CharContainer
  #デフォルト
  impl_option_options_block :default_style_config,:CharContainer
  #現在値
  impl_option_options_block :style_config,        :CharContainer
  #現在値をリセット
  impl_option_options_block :reset_style_config,  :CharContainer
  #レンダリング済みフォントの登録
  impl_option_options_block :map_image_font,      :CharContainer

  #画像の差し替え
  impl_option_options_block :image_change, :ImageControl

  #制御構文 if系
  impl_option_options_block :IF
  impl_block :EXP
  impl_block :THEN
  impl_block :ELSE
  impl_option_options_block :ELSIF

  impl_one_option :visible
  impl_non_option :se_play
  impl_non_option :se_stop

  #target変更は受け付けない(Controlクラスに登録)
  def define(command_name, &block)
    impl(:define, :Anonymous, nil, command_name, &block)
  end

  def _YIELD_(target = nil, **options)
    options[:yield_block] = @yield_block
    impl(:YIELD, :Anonymous, nil, nil, **options)
  end

  #case（予約語の為メソッド名差し替え）
  def CASE(option, target = nil)
    impl(:case, :Anonymous, target, option) do
      @key_name = :after_case
      yield
    end
  end

  #when（予約語の為メソッド名差し替え）
  def WHEN(*option)
    raise if @key_name != :after_case
    @key_name = :when
    impl(:when, :Anonymous, nil, option) do
      @key_name = :block
      yield
    end
    @key_name = :after_case
  end

  #while（予約語の為メソッド名差し替え）
  def WHILE(option, target = nil, **sub_options, &block)
    impl(:while, :Anonymous, target, option, sub_options, &block)
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
end
