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

  @@control_default = {
    :CharContainer => :default_text_layer,
    :LayoutContainer => :default_layout_container,
    :Rag => :default_layout_container,
    :ButtonControl => :button1,
    :Anonymous => :anonymous
  }

  def initialize(file_path)
    @option = {}
    @option_stack = []
    @key_name = :commands
    @key_name_stack = []
    
    @ailias_list = []
    
    @script_storage = eval(File.open(file_path, "r:UTF-8").read)
  end

  def impl(command_name, default_control, option, sub_options = {}, &block)

    #キー名無しオプションがある場合はコマンド名をキーに設定する
    sub_options[command_name] = option if option != nil

    #送信先コントロールのデフォルトを設定する
    if !sub_options[:target_control]
      sub_options[:target_control] = @@control_default[default_control]
    end

    #ブロックが存在する場合、ブロックを１オプションとして登録する
    if block
      #ネスト用のスタックプッシュ
      @option_stack.push(@option)
      @key_name_stack.push(@key_name)

      #ネスト用の初期化
      @option = {}

      yield

      #ここまでに@optionに:command/:then/:elseなどのハッシュが戻って来ている
      #ex. {:command => [[:text,nil]]}

      #ブロックオプションをオプションリストに追加する
      sub_options.update(@option)

      #スタックポップ
      @key_name = @key_name_stack.pop #ブロックのオプション名
      @option = @option_stack.pop #オプション
    end

    #存在していないキーの場合は配列として初期化する
    @option[@key_name] = [] if !@option[@key_name]
    #コマンドを登録する
    @option[@key_name].push([command_name, sub_options])
  end

  #オプション無し
  def self.impl_non_option(command_name, default_control)
    define_method(command_name) do
      impl(command_name, default_control, nil)
    end
  end

  #名前なしオプション（１個）
  def self.impl_one_option(command_name, default_control)
    define_method(command_name) do |option|
      impl(command_name, default_control, option)
    end
  end

  #名前付きオプション群
  def self.impl_options(command_name, default_control)
    define_method(command_name) do |sub_options|
      impl(command_name, default_control, nil, sub_options)
    end
  end

  #ブロック
  def self.impl_block(command_name, default_control)
    define_method(command_name) do |&block|
      impl(command_name, default_control, nil) do
        @key_name = :commands; block.call ;
      end
    end
  end

  #名前無しオプション（１個）＆名前付オプション群＆ブロック
  def self.impl_option_options_block(command_name, default_control)
    define_method(command_name) do |option, sub = {}, &block|
      impl(command_name, default_control, option, sub )do
        if block; @key_name = :commands; block.call ; end
      end
    end
  end

  #プロシージャー登録されたコマンドが宣言された場合にここで受ける
  def method_missing(method, *args)
    #メソッド名が識別子リストに登録されていない場合
    #親クラスに伝搬し、syntax errorとする
    return super if !@ailias_list.include?(method)
    #コマンドとして登録する
    @option[@key_name].push([method, args[0]])
  end

  #次フレームに送る
  impl_non_option :next_frame, :Anonymous
  #キー入力待ち
  impl_non_option :pause,      :Anonymous

  impl_non_option :wait_wake,      :Anonymous

  impl_options :wake,      :Anonymous
  impl_non_option :wait_input_key,      :Anonymous

  #改行
  impl_non_option :line_feed,  :CharContainer
  #改ページ
  impl_non_option :flash,      :CharContainer

  #ボタン制御コマンド群
  #TODOこれホントに必要？
  impl_non_option :normal,      :ButtonControl

  impl_non_option :check_key_push_to_skip,      :Anonymous

  #単一オプションを持つコマンド
  #特定コマンドの終了を待つ
  impl_one_option :wait_command,  :Anonymous
  #特定フラグの更新を待つ（現状では予めnilが入ってないと機能しない）
  impl_one_option :wait_flag,     :Anonymous
  impl_one_option :wait_flag_with_skip,     :Anonymous
  #次に読み込むスクリプトファイルの指定
  impl_one_option :next_scenario, :LayoutContainer
  #コントロールの削除
  impl_one_option :dispose,       :LayoutContainer

  impl_non_option :wait_child_controls_idol,  :Anonymous

  impl_non_option :check_key_push,  :Anonymous
  impl_one_option :wait_command_with_key_push,  :Anonymous

  impl_non_option :test1,            :Anonymous

  #スリープモードの更新
  impl_one_option :sleep_mode,  :Anonymous
  #スキップモードの更新
  impl_one_option :skip_mode,  :Anonymous

  #文字列
  impl_one_option :text,         :CharContainer
  #文字
  impl_one_option :char,         :CharContainer
  #指定フレーム待つ
  impl_one_option :wait,         :Anonymous
  #インデント設定
  impl_one_option :indent,       :CharContainer
  #文字描画速度の設定
  impl_one_option :delay,        :CharContainer

  #移動
  impl_options :move,            :Anonymous
  impl_options :move_line,       :Anonymous

  impl_options :move_line_with_skip,      :Anonymous

  #フェードトランジション
  impl_options :transition_fade, :Anonymous
  impl_options :transition_fade_with_skip, :Anonymous
  #フラグ設定
  impl_options :flag,            :Anonymous

  #ブロックを持つコマンド

  #文字レンダラの指定
  #TODO:これはtext_layer内に動作を限定できないか？
  impl_block :char_renderer,     :CharContainer

  #オプション／サブオプション（省略可）／ブロックを持つコマンド

  #コントロールの生成
  impl_option_options_block :create,              :Anonymous
  #コントロール単位でイベント駆動するコマンド群を格納する
  impl_option_options_block :event,               :Anonymous

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

  #プロシージャー宣言
  #TODOプロシージャーリストへの追加処理を足す
  def procedure(command_name, sub)
    impl(:procedure, :LayoutContainer, command_name, sub)
    @ailias_list.push(command_name)
  end

  #コマンド群に別名を設定する
  def ailias(command_name, &block)
    impl(:ailias, :LayoutContainer, command_name)do
      if block; @key_name = :commands; block.call; end
    end
    @ailias_list.push(command_name)
  end

  #制御構造関連
  #if（予約語の為メソッド名差し替え）
  def IF(option)
    impl(:if, :LayoutContainer, option) do
      yield
    end
  end

  #then（予約語の為メソッド名差し替え）
  def THEN() 
    @key_name = :then
    yield
  end

  #else（予約語の為メソッド名差し替え）
  def ELSE()
    @key_name = :else
    yield
  end

  #while（予約語の為メソッド名差し替え）
  def WHILE(option, sub_options)
    impl(:while, :LayoutContainer, option, sub_options) do
      yield
    end
  end

  #eval（予約語の為メソッド名差し替え）
  def EVAL(option)
    impl(:eval,  :Anonymous, option)
  end

  #sleep（予約語の為メソッド名差し替え）
  def sleep_frame
    impl(:sleep, :Anonymous, nil)
  end

  #ヘルパーメソッド群

  def shift()
    return @script_storage.shift
  end
  
  def empty?
    return @script_storage.empty?
  end
end
end
