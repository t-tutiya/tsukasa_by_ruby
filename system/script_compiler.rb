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
    :Rag => :default_layout_container
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
    sub_options[command_name] = option if option

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

  def self.imple_non_option_command(command_name, default_control)
    define_method(command_name) do
      impl(command_name, default_control, nil)
    end
  end

  def self.impl_with_one_option_command(command_name, default_control)
    define_method(command_name) do |option|
      impl(command_name, default_control, option)
    end
  end

  def self.impl_with_option_command(command_name, default_control)
    define_method(command_name) do |sub_options|
      impl(command_name, default_control, nil, sub_options)
    end
  end

  def self.impl_with_block(command_name, default_control)
    define_method(command_name) do |option, sub, &block|
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

  imple_non_option_command :next_frame, :Rag

  #オプションを持たないコマンド
  imple_non_option_command :halt,       :LayoutContainer

  imple_non_option_command :pause,      :CharContainer
  imple_non_option_command :line_feed,  :CharContainer
  imple_non_option_command :flash,      :CharContainer
  imple_non_option_command :pause,      :CharContainer

  #特定コマンドの終了を待つ
  impl_with_one_option_command :wait_command, :LayoutContainer

  #単一オプションを持つコマンド
  impl_with_one_option_command :text,         :CharContainer
  impl_with_one_option_command :char,         :CharContainer
  impl_with_one_option_command :wait,         :CharContainer
  impl_with_one_option_command :indent,       :CharContainer
  #文字描画速度の設定
  impl_with_one_option_command :delay,        :CharContainer

  #次に読み込むスクリプトファイルの指定
  impl_with_one_option_command :next_scenario,         :LayoutContainer

  #サブオプションを持つコマンド
  impl_with_block :create,              :LayoutContainer

  #画像スタック
  impl_with_block :graph,               :CharContainer
  #ルビ文字の出力
  impl_with_block :rubi_char,           :CharContainer
  #複数ルビ文字列の割り付け
  impl_with_block :rubi,                :CharContainer
  #デフォルト
  impl_with_block :default_font_config, :CharContainer
  #現在値
  impl_with_block :font_config,         :CharContainer
  #現在値をリセット
  impl_with_block :reset_font_config,   :CharContainer
  #デフォルト
  impl_with_block :default_style_config,:CharContainer
  #現在値
  impl_with_block :style_config,        :CharContainer
  #現在値をリセット
  impl_with_block :reset_style_config,  :CharContainer
  #文字レンダラの設定
  impl_with_block :char_renderer,       :CharContainer
  #レンダリング済みフォントの登録
  impl_with_block :map_image_font,      :CharContainer

  #移動
  impl_with_option_command :move,            :LayoutContainer
  impl_with_option_command :move_line,            :LayoutContainer
  #移動
  impl_with_option_command :transition_fade, :LayoutContainer
  #フラグ設定（未実装）
  impl_with_option_command :flag,            :LayoutContainer

  def char_renderer(&block)
      impl(:char_renderer, :LayoutContainer, nil)do
        if block; @key_name = :commands; block.call; end
      end
  end

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
  def IF(option)
    impl(:if, :LayoutContainer, option) do
      yield
    end
  end

  def THEN() 
    @key_name = :then
    yield
  end

  def ELSE()
    @key_name = :else
    yield
  end

  def WHILE(option, sub_options)
    impl(:while2, :LayoutContainer, option, sub_options) do
      yield
    end
  end

  def EVAL(option)
    impl(:eval,  :Rag, option)
  end

  def sleep_frame
    impl(:sleep, :Rag, nil)
  end

  def shift()
    return @script_storage.shift
  end
  
  def empty?
    return @script_storage.empty?
  end
end
end
