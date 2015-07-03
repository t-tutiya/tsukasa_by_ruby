#! ruby -E utf-8

require 'dxruby'
require_relative './module_movable.rb'
require_relative './module_drawable.rb'

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

module Resource
  @@global_flag = {}   #グローバルフラグ
  @@builtin_command_list = Array.new #組み込みコマンドリスト
end

class Control
  include Resource
  @@function_list = {} #functionのリスト（procで保存される）
  @@root = nil

  #プロパティ
  attr_accessor  :skip_mode #スキップモード

  def initialize(options, system_options)
    @@root = self if !@@root #ルートコントロールを登録

    #コントロールのID(省略時は自身のクラス名とする)
    @id = options[:id] || ("Anonymous_" + self.class.name).to_sym

    @script_storage       = [] #スクリプトストレージ
    @script_storage_stack = [] #コールスタック

    @command_list         = [] #コマンドリスト

    @control_list         = [] #コントロールリスト

    @event_list           = {} #イベントリスト

    @next_frame_commands  = [] #一時コマンドリスト

    @skip_mode = false         #スキップモードの初期化
    @idle_mode = true          #待機モードの初期化

    @sleep_mode = :wake        #スリープの初期状態を設定する

    @delete_flag = false       #削除フラグの初期化

    #コマンドに設定されているデフォルトの送信先クラスのIDディスパッチテーブル
    @control_default = {
      :CharContainer   => :default_char_container,
      :LayoutContainer => :default_layout_container,
      :Anonymous       => :anonymous,
    }

    if options[:default_script_path]
      #デフォルトスクリプトの読み込み
      @script_storage += ScriptCompiler.new({:script_path => options[:default_script_path]}, system_options).commands
    end

    #スクリプトパスが設定されているなら読み込んで登録する
    if options[:script_path]
      #シナリオファイルの読み込み
      @script_storage += ScriptCompiler.new({:script_path => options[:script_path]}, system_options).commands
    end

    #ブロックが付与されているなら読み込んで登録する
    if system_options[:block]
      @script_storage = ScriptCompiler.new(options, system_options, &system_options[:block]).commands
    end

    #コマンドセットがあるなら登録する
    eval_commands(options[:commands]) 

    @command_list.push([:token, nil, {}])

    #初期ブロックを実行する
    update()
  end

  #コマンドをスタックに格納する
  def send_command(command, options, system_options = {:target_id => @id})
    #自身が送信対象として指定されている場合
    if @id == system_options[:target_id] or system_options[:target_id] == :anonymous
      #コマンドをスタックの末端に挿入する
      @script_storage.push([command, options, system_options])
      return true #コマンドをスタックした
    end

    #子要素に処理を伝搬する
    @control_list.each do |control|
      #子要素がコマンドをスタックした時点でループを抜ける
      return true if control.send_command(command, options, system_options)
    end

    return false #コマンドをスタックしなかった
  end

  #コマンドをスタックに格納する
  def send_command_interrupt(command, options, system_options = {:target_id => @id})
    #自身が送信対象として指定されている場合
    #TODO：or以降がアリなのか（これがないと子コントロール化にブロックを送信できない）
    if @id == system_options[:target_id] or system_options[:target_id] == :anonymous
      #コマンドをスタックの先頭に挿入する
      @command_list.unshift([command, options, system_options])
      return true #コマンドをスタックした
    end

    #子要素に処理を伝搬する
    @control_list.each do |control|
      #子要素がコマンドをスタックした時点でループを抜ける
      return true if control.send_command_interrupt(command, options, system_options)
    end

    return false #コマンドをスタックしなかった
  end

  #強制的に全てのコントロールにコマンドを設定する
  def send_command_to_all(command, options)
    #自身のidを設定してコマンドを送信する
    send_command(command, options)

    #子要素に処理を伝搬する
    @control_list.each do |control|
      control.send_command_to_all(command, options)
    end
  end

  #強制的に全てのコントロールにコマンドを設定する
  def send_command_interrupt_to_all(command, options)
    #自身のidを設定してコマンドを送信する
    send_command_interrupt(command, options)

    #子要素に処理を伝搬する
    @control_list.each do |control|
      control.send_command_interrupt_to_all(command, options)
    end
  end

  #毎フレームコントロール更新処理
  def update
    #次フレコマンド列クリア
    @next_frame_commands = []

    #待機モードを初期化
    @idle_mode = true

    #コマンドリストが空になるまで走査し、コマンドを実行する
    while !@command_list.empty?
      #コマンドリストの先頭要素を取得
      command, options, system_options = @command_list.shift
      
      #システムオプションが空であれば初期化
      #TODO：必ず初期化されている物としたい
      system_options = {} unless system_options

      #コマンドを実行
      end_parse, command = send("command_" + command.to_s, options, system_options)

      #次フレームに実行するコマンドがある場合、一時的にスタックする
      @next_frame_commands.push(command) if command

      #現在のフレームを終了するかどうかを識別する
      #フレーム終了指示がなくても、command_list/script_storage共に空なら終了する
      case end_parse
      when :end_frame
        break
      when :continue
        next
      else
        pp end_parse
        raise
      end
    end

    #一時的にスタックしていたコマンドをコマンドリストに移す
    @command_list = @next_frame_commands + @command_list

    @control_list.each do |control|
      #各コントロールを更新し、待機モードかどうかの真偽値をANDで集計する
      control.update
    end

    #削除フラグが立っているコントロールをリストから削除する
    @control_list.delete_if do |control|
      control.delete?
    end
  end

  #下位コントロールを描画する
  def render(offset_x, offset_y, target)
      #下位コントロール巡回
      @control_list.each do |child_control|
        #下位コントロールを上位ターゲットに直接描画
        offset_x, offset_y = child_control.render(offset_x, offset_y, target)
      end
      #オフセット値を返す
      return offset_x, offset_y
  end

  def get_child(id)
    #自身が送信対象として指定されている場合
    return self if @id == id

    #子要素に処理を伝搬する
    @control_list.each do |control|
      result = control.get_child(id)
      return result if result
    end

    return nil
  end

  #全てのコントロールが待機モードになっているかを返す。
  #TODO：現状毎フレここで実行しているのだけど、コストが高すぎるので本当はupdateの戻り値の集計ですませたい。なんとかできないか考える。
  def all_controls_idle?
    @idle_mode &&= @control_list.all?(&:all_controls_idle?)

    return @idle_mode
  end

  #コントロールを削除して良いかどうか
  def delete?
    return @delete_flag
  end

  #リソースを解放する
  #継承先で必要に応じてオーバーライドする
  def dispose
    @delete_flag = true

    #子要素に処理を伝搬する
    @control_list.each do |control|
      control.dispose
    end
  end

end

class Control

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #配列のコマンド列をスクリプトストレージに積む
  def eval_commands(commands)
    return unless commands
    
    #現在のスクリプトストレージをコールスタックにプッシュ
    @script_storage_stack.push(@script_storage) if !@script_storage.empty?
    #コマンドリストをクリアする
    @script_storage = commands.dup
  end

  #rubyブロックのコマンド列を配列化してスクリプトストレージに積む
  def eval_block(options, system_options = {}, block)
    return unless block
    eval_commands(ScriptCompiler.new(options, system_options, &block).commands)
  end

  #IFやWHILEなどで渡されたlambdaを実行する
  def eval_lambda(lambda, options)
    if lambda.arity == 0
      return lambda.call
    else
      return lambda.call(options)
    end
  end
end

class Control

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #############################################################################
  #スクリプト処理コマンド
  #############################################################################

  #コントロールをリストに登録する
  def command_create(options, system_options)
    #コントロールを生成して子要素として登録する
    @control_list.push(
      Module.const_get(options[:create]).new( options, 
                                              system_options, 
                                              &system_options[:block]))

    return :continue
  end

  #disposeコマンド
  #コントロールを削除する
  def command_dispose(options, system_options)
    #自身が指定されたコントロールの場合
    if options[:dispose] == @id
      #削除フラグを立てる
      dispose()
    else
      #子コントロールにdisposeコマンドを送信
      send_command_interrupt(:dispose, options, options[:dispose])
    end
    return :continue
  end

  #コントロールのプロパティを更新する
  def command_set(options, system_options)
    #オプション全探査
    options.each do |key, val|
      method_name = key.to_s + "="
      if self.class.method_defined?(method_name)
        send(method_name, val)
      else
        pp "クラス[" + self.class.to_s + "]：メソッド[" + method_name + "]は存在しません"
      end
    end

    return :continue
  end

  #スクリプトストレージから取得したコマンドをコントロールツリーに送信する
  def command_token(options, system_options)
    #TODO:この部分もうちょっと見通し良くならない物か
    #トークンの取得対象であるスクリプトストレージが空の場合
    if @script_storage.empty?
      #スクリプトストレージのコールスタックが存在する場合
      if !@script_storage_stack.empty?
        #コールスタックからスクリプトストレージをポップする
        @script_storage = @script_storage_stack.pop
      #次に読み込むスクリプトファイルが指定されている場合
      elsif @next_script_file_path
        #指定されたスクリプトファイルを読み込む
        @script_storage = ScriptCompiler.new(@next_script_file_path).commands
        #予約スクリプトファイルパスの初期化
        @next_script_file_path = nil
      else 
        #ループを抜ける
        return :continue, [:token, nil]
      end
    end

    #コマンドを取り出す
    command, options, system_options = @script_storage.shift
=begin
    #TODO：付与ブロックが実行時評価になり、実質的に毎回複製されるため、下記のロジックが必要なくなった。エンバグが起きていないか判断できるまで、コメントアウトで残す。

    #コマンドを取り出す
    temp = @script_storage.shift
    command = temp[0]     #コマンド名（シンボル）

    #TODO：このdupが本当に必要なのか良く分からない
    options = temp[1].dup #オプション群。状態を持ちうるので複製する
    system_options = temp[2] #システムで使用するオプション群
=end
    #送信先ターゲットIDが設定されていない場合
    unless system_options[:target_id]
      #デフォルトクラス名からIDを取得する
      system_options[:target_id] = @control_default[system_options[:default_class]]
    end

    #自身が送信対象として指定されている場合
    if @id == system_options[:target_id] or system_options[:target_id] == :anonymous
      #コマンドtをスタックの末端に挿入する
      @command_list.push([command, options, system_options])
    elsif !send_command( command, 
                      options, 
                      system_options) then
      pp "error"
      pp command.to_s + "コマンドは伝搬先が見つかりませんでした"
      pp @id
      pp options
      pp system_options
      raise
    end

    @command_list.push([:token, nil, {}])
    return :continue
  end
end

class Control

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #############################################################################
  #タイミング制御コマンド
  #############################################################################

  #現在のフレームを終了する
  def command_end_frame(options, system_options)
    return :end_frame
  end

  #skip_modeコマンド
  #スキップモードの更新
  def command_skip_mode(options, system_options)
    #スキップモードの更新
    @skip_mode = options[:skip_mode]
    return :continue
  end

  def command_skip_mode_all(options, system_options)
    #スリープモードを解除する
    @@root.send_command_interrupt_to_all(:skip_mode, 
                                        {:skip_mode => options[:skip_mode_all]})
    return :continue
  end

  #sleep_modeコマンド
  #スリープモードの更新
  def command_sleep_mode(options, system_options)
    #スリープ状態を更新
    @sleep_mode = options[:sleep_mode] 
    return :continue
  end

  def command_sleep_mode_all(options, system_options)
    #スリープモードを解除する
    @@root.send_command_interrupt_to_all(:sleep_mode, 
                                        {:sleep_mode => options[:sleep_mode_all]})
    return :continue
  end

  def command_wait(options, system_options)
    options[:wait].each do |condition|
      case condition
      when :wake
        return :continue if @sleep_mode != :sleep

      when :idol
        return :continue if all_controls_idle?

      when :count
        #待ちフレーム数を取得。
        #設定されていない場合はコンフィグから初期値を取得する
        #TODO:@style_config[:wait_frame]はchar特有のプロパティ
        wait_frame =  options[:count] == :unset_wait_frame ?
                      @style_config[:wait_frame] :
                      options[:count]
        #残りwaitフレーム数が０より大きい場合
        return :continue if wait_frame <= 0
        options[:count] = wait_frame - 1

      when :command
        unless @next_frame_commands.index{|command|
          command[0]==options[:command]}
          return :continue
        end

      when :flag
        unless @@global_flag[("user_" + options[:flag].to_s).to_sym]
          return :continue
        end

      when :key_push
        #キー押下があれば終了
        if Input.key_push?(K_SPACE)
          @@root.send_command_interrupt_to_all(:skip_mode, {:skip_mode =>true})
          return :continue 
        end

      when :skip
        #スキップモードであれば終了
        return :continue if @skip_mode
      end
    end

    #waitにブロックが付与されているならそれを実行する
    eval_block(options, system_options[:block])

    return :end_frame, [:wait, options, system_options]
  end

  def command_check_key_push(options, system_options)
    #子要素のコントロールが全てアイドル状態の時にキーが押された場合
    if Input.key_push?(K_SPACE)
      return :continue
    else
      @idle_mode = false
      #ポーズ状態を続行する
      return :continue, [:check_key_push, options]
    end
  end
end

class Control

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #イベントコマンドの登録
  def command_event(options, system_options)
    @event_list[options[:event]] = system_options[:block]
    return :continue
  end

  #イベントの実行
  def command_fire(options, system_options)
    #キーが登録されていないなら終了
    return :continue if !@event_list[options[:fire]]

    eval_block(options, @event_list[options[:fire]])

    return :continue
  end

  #############################################################################
  #スタック操作関連
  #############################################################################

  #ユーザー定義コマンドを定義する
  def command_define(options, system_options)
    @@function_list[options[:define]] = system_options[:block]
    return :continue
  end

  #関数呼び出し
  def command_call_function(options, system_options)
    #定義されていないfunctionが呼びだされたら例外を送出
    raise NameError, "undefined local variable or command or function `#{options[:call_function]}' for #{system_options}" unless @@function_list.key?(options[:call_function])

    #関数ブロックを引数に登録する
    system_options[:yield_block] = system_options[:block]
    #下位伝搬を防ぐ為に要素を削除
    system_options.delete(:block)
    #関数名に対応する関数ブロックを取得する
    function_block = @@function_list[options[:call_function]]
    #下位伝搬を防ぐ為に要素を削除
    options.delete(:call_function)

    #functionを実行時評価しコマンド列を生成する。
    eval_block(options, system_options, function_block)

    return :continue
  end

  def command_call_builtin_command(options, system_options)
    command_name = options[:call_builtin_command]
    options.delete(:call_builtin_command) #削除
    return send("command_" + command_name.to_s, options, system_options)
  end

  #ブロック内のコマンド列を実行する
  def command_about(options, system_options)
    #コマンドリストをスタックする
    eval_block(options, system_options[:block])
    return :continue
  end

  #############################################################################
  #分類未決定
  #############################################################################

  #フラグを設定する
  def command_flag(options, system_options)
    #ユーザー定義フラグを更新する
    @@global_flag[("user_" + options[:key].to_s).to_sym] = options[:data]
    return :continue
  end

  #コマンド送信先ターゲットのデフォルトを変更する
  def command_change_default_target(options, system_options)
    @control_default[options[:change_default_target]] = options[:id]
    return :continue
  end


  #次に読み込むスクリプトファイルのパスを設定する
  def command_next_scenario(options, system_options)
    @next_script_file_path = options[:next_scenario]
    return :continue
  end
  
  #スクリプトファイルの読み込み
  def command_load_script(options, system_options)
    #指定されたスクリプトファイルを直接読み込む
    #TODO：@script_storageに上書きするのか、追記するのかはオプションで指定できた方が良いか？　その
    @script_storage = ScriptCompiler.new({:script_path => options[:load_script]}).commands
    return :continue
  end
  
end

#############################################################################
#制御構文コマンド
#############################################################################

class Control #制御構文

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #ifコマンド
  def command__IF_(options, system_options)
    #条件式を評価し、結果をoptionsに再格納する
    if eval_lambda(options[:_IF_], options)
      result = :then
    else
      result = :else
    end

    #if文の中身を実行する
    eval_block(options, system_options[:block])

    return :continue, [:exp_result, { :result => result}]
  end

  #thenコマンド
  def command__THEN_(options, system_options)
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }
    
    #結果がthenの場合
    if result and @next_frame_commands[result][1][:result] == :then
      #コマンドブロックを実行する
      eval_block(options, system_options[:block])
    end

    return :continue
  end

  #elseコマンド
  def command__ELSIF_(options, system_options)
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }

    #結果がelseの場合
    if result and @next_frame_commands[result][1][:result] == :else
      #ラムダ式が真の場合
      if eval_lambda(options[:_ELSIF_], options)
        #コマンドブロックを実行する
        eval_block(options, system_options[:block])
        #処理がこれ以上伝搬しないように評価結果をクリアする
        #TODO：コマンド自体を削除した方が確実
        @next_frame_commands[result][1][:result] = nil
      end
    end
    
    return :continue
  end

  #elseコマンド
  def command__ELSE_(options, system_options)
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }

    #結果がelseの場合
    if result and @next_frame_commands[result][1][:result] == :else
      #コマンドブロックを実行する
      eval_block(options, system_options[:block])
    end
    return :continue
  end

  #繰り返し
  def command__WHILE_(options, system_options)
    #条件式が非成立であれば繰り返し構文を終了する
    return :continue if !eval_lambda(options[:_WHILE_], options) #アイドル

    #while文全体をスクリプトストレージにスタック
    eval_commands([[:_WHILE_, options, system_options]])
    #ブロックを実行時評価しコマンド列を生成する。
    eval_block(options, system_options[:block])

    return :continue
  end

  def command__CASE_(options, system_options)
    #比較元のオブジェクトを評価する
    value = eval_lambda(options[:_CASE_], options)

    #case文の中身を実行する
    eval_block(options, system_options[:block])

    return :continue, [:exp_result, { :result => :else,
                                      :case_value => value}]
  end

  def command__WHEN_(options, system_options)
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }

    #評価結果が存在しなければ処理を終了する
    return :continue unless result

    exp_result = @next_frame_commands[result][1]

    if exp_result[:case_value] == eval_lambda(options[:_WHEN_], options)
      #コマンドブロックを実行する
      eval_block(options, system_options[:block])
    end

    return :continue
  end

  #関数ブロックを実行する
  def command__YIELD_(options, system_options)
    eval_block(options, system_options[:yield_block])
    return :continue
  end

  #コマンドを再定義する
  def command__ALIAS_(options, system_options)
    #元コマンドが組み込みコマンドの場合
    if @@builtin_command_list.include?(options[:command_name])
      #元コマンドをcall_builtin_commandで呼びだすブロックを設定する
      @@function_list[options[:_ALIAS_]] = Proc.new{|command_options|
        call_builtin_command(options[:command_name], command_options)
      }

      #コマンドを組み込みコマンドリストから削除する
      @@builtin_command_list.delete_if{ |command_name|
        command_name == options[:command_name]
      }
    else
      #新しいコマンド名に元のコマンドのブロックを設定する
      @@function_list[options[:_ALIAS_]] = @@function_list[options[:command_name]]
    end

    return :continue
  end

  #文字列を評価する（デバッグ用）
  def command__EVAL_(options, system_options)
    eval(options[:_EVAL_])
    return :continue
  end


  #１フレ分のみifの結果をコマンドリスト上に格納する
  def command_exp_result(options, system_options)
    return :continue
  end
end
