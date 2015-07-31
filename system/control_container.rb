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

class Control
  #プロパティ
  attr_accessor  :skip_mode #スキップモード
  attr_accessor  :sleep_mode #スリープモード
  attr_accessor  :idle_mode #アイドルモード
  attr_reader  :system_property

  attr_accessor  :id

  def initialize(options, inner_options, root_control = nil)
    if root_control
      @root_control = root_control
    else
      @root_control = self
      @system_property = {
        #functionのリスト（procで保存される）
        :function_list => {},
        :global_flag => {},
      }
    end

    @script_compiler = ScriptCompiler.new

    #コントロールのID(省略時は自身のクラス名とする)
    @id = options[:id] || ("Anonymous_" + self.class.name).to_sym

    @command_list         = [] #コマンドリスト

    @control_list         = [] #コントロールリスト

    @event_list           = {} #イベントリスト

    @next_frame_commands  = [] #一時コマンドリスト
    
    @child_update = true #updateを子コントロールに伝搬するか
    @child_render = true #renderを子コントロールに伝搬するか

    @skip_mode = false         #スキップモードの初期化
    @idle_mode = true          #待機モードの初期化

    @sleep_mode = :wake        #スリープの初期状態を設定する

    @delete_flag = false       #削除フラグの初期化

    #コマンドに設定されているデフォルトの送信先クラスのIDディスパッチテーブル
    @control_default = {
      :TextPageControl   => :default_char_container,
      :RenderTargetContainer => :default_RenderTarget_container,
      :Anonymous       => :anonymous,
    }

    if options[:default_script_path]
      #デフォルトスクリプトの読み込み
      @command_list += @script_compiler.commands(
                          {:script_path => options[:default_script_path]}, 
                          inner_options, 
                          @root_control.system_property)
    end

    #スクリプトパスが設定されているなら読み込んで登録する
    if options[:script_path]
      #シナリオファイルの読み込み
      @command_list += @script_compiler.commands(
                          {:script_path => options[:script_path]}, 
                          inner_options, 
                          @root_control.system_property)
    end

    #ブロックが付与されているなら読み込んで登録する
    if inner_options[:block]
      @command_list = @script_compiler.commands(
                          options, 
                          inner_options, 
                          @root_control.system_property, 
                          &inner_options[:block])
    end

    #コマンドセットがあるなら登録する
    eval_commands(options[:commands]) 
  end

  #コマンドをスタックに格納する
  def send_script(command, options, inner_options)
    #自身が送信対象として指定されている場合
    if [@id, :anonymous].include?(inner_options[:target_id])
      #コマンドをスタックの末端に挿入する
      @command_list.push([command, options, inner_options])
      return true #コマンドをスタックした
    end

    #子要素に処理を伝搬する
    @control_list.each do |control|
      #子要素がコマンドをスタックした時点でループを抜ける
      return true if control.send_script(command, options, inner_options)
    end

    return false #コマンドをスタックしなかった
  end

  #コマンドをスタックに格納する
  def interrupt_command(command, options, inner_options)
    #自身が送信対象として指定されている場合
    if [@id, :anonymous].include?(inner_options[:target_id])
      #コマンドをスタックの先頭に挿入する
      @command_list.unshift([command, options, inner_options])
      return true #コマンドをスタックした
    end

    #子要素に処理を伝搬する
    @control_list.each do |control|
      #子要素がコマンドをスタックした時点でループを抜ける
      return true if control.interrupt_command(command, options, inner_options)
    end

    return false #コマンドをスタックしなかった
  end

  def push_command_to_next_frame(command, options, inner_options)
    @next_frame_commands.push([command, options, inner_options])
    return true
  end

  #強制的に全てのコントロールにコマンドを設定する
  def send_script_to_all(command, options, inner_options)
    #コマンドをスタックの末端に挿入する
    @command_list.push([command, options, inner_options])

    #子要素に処理を伝搬する
    @control_list.each do |control|
      control.send_script_to_all(command, options, inner_options)
    end
  end

  #強制的に全てのコントロールにコマンドを設定する
  def interrupt_command_to_all(command, options, inner_options)
    #コマンドをスタックの先頭に挿入する
    @command_list.unshift([command, options, inner_options])

    #子要素に処理を伝搬する
    @control_list.each do |control|
      control.interrupt_command_to_all(command, options, inner_options)
    end
  end

  def update
    #次フレコマンド列クリア
    @next_frame_commands = []

    #待機モードを初期化
    @idle_mode = true

=begin
    #TODO：スクリプトの追加読み込みについては仕様検討中
    #トークンの取得対象であるスクリプトストレージが空の場合
    if @command_list.empty?
      #次に読み込むスクリプトファイルが指定されている場合
      if @next_script_file_path
        #指定されたスクリプトファイルを読み込む
        @command_list = @script_compiler.commands(@next_script_file_path)
        #予約スクリプトファイルパスの初期化
        @next_script_file_path = nil
      end
    end
=end
    #コマンドリストが空になるまで走査し、コマンドを実行する
    while !@command_list.empty?
      #コマンドリストの先頭要素を取得
      command, options, inner_options = @command_list.shift

      #今フレーム処理終了判定
      break if command == :end_frame

      #送信先ターゲットIDが設定されていない場合
      unless inner_options[:target_id]
        #デフォルトクラス名からIDを取得する
        inner_options[:target_id] = @control_default[inner_options[:default_class]]
        raise unless inner_options[:target_id]
      end

      #ルートコントロールが送信対象として指定されている場合
      if inner_options[:root]
        #対象コントロール名を差し替える
        inner_options[:root] = false
        #コマンドの送信
        target = @root_control
      else
        target = self
      end

      if inner_options[:all]
        inner_options.delete(:all)
        if inner_options[:interrupt]
          #コマンドの優先送信
          target.interrupt_command_to_all( command, options, inner_options)
        else
          #コマンドのスタック送信
          target.send_script_to_all( command, options, inner_options)
        end
        next
      end

      #送信対象として自身が指定されている場合
      unless [@id, :anonymous].include?(inner_options[:target_id])
        if inner_options[:interrupt]
          #コマンドの優先送信
          result = target.interrupt_command( command, options, inner_options)
        else
          #コマンドのスタック送信
          result = target.send_script( command, options, inner_options)
        end
        unless result
            pp "error"
            pp command.to_s + "コマンドは伝搬先が見つかりませんでした"
            pp @id
            pp options
            pp inner_options
            raise
        end
        next
      end

      #コマンドを実行する
      target.send("command_" + command.to_s, options, inner_options)
    end

    #一時的にスタックしていたコマンドをコマンドリストに移す
    @command_list = @next_frame_commands + @command_list

    #子コントロール伝搬しないなら終了する
    return unless @child_update

    #子コントロールを巡回してupdateを実行
    @control_list.each do |control|
      control.update
    end

    #削除フラグが立っているコントロールをリストから削除する
    @control_list.delete_if do |control|
      control.delete?
    end
  end

  #下位コントロールを描画する
  def render(offset_x, offset_y, target)
    #子コントロール伝搬しないなら終了する
    return offset_x, offset_y unless @child_render

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
end

class Control

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #リソースを解放する
  #継承先で必要に応じてオーバーライドする
  def dispose
    @delete_flag = true
  end

  #配列のコマンド列をスクリプトストレージに積む
  def eval_commands(commands)
    return unless commands
    #コマンドをリストにスタックする
    @command_list = commands +  @command_list
  end

  #rubyブロックのコマンド列を配列化してスクリプトストレージに積む
  def eval_block(options, inner_options = {}, block)
    return unless block
    eval_commands(@script_compiler.commands(options, 
                                            inner_options, 
                                            @root_control.system_property, 
                                            &block))
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
  def command_create(options, inner_options)
    #スキップモードの指定
    #TODO：ここで入れるのは相当イマイチ。方法を考える
    options[:skip_mode] = @skip_mode

    #コントロールを生成して子要素として登録する
    @control_list.push(Module.const_get(options[:create]).new( options, 
                                                               inner_options, 
                                                               @root_control))
    #付与ブロックを実行する
    @control_list.last.update()
  end

  #disposeコマンド
  #コントロールを削除する
  def command_delete(options, inner_options)
    #削除フラグを立てる
    dispose()
  end

  #コントロールのプロパティを更新する
  def command_set(options, inner_options)
    #オプション全探査
    options.each do |key, val|
      method_name = key.to_s + "="
      if self.class.method_defined?(method_name)
        send(method_name, val)
      else
        pp "クラス[" + self.class.to_s + "]：メソッド[" + method_name + "]は存在しません"
      end
    end
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

  def command_wait(options, inner_options)
    options[:wait].each do |condition|
      case condition
      when :wake
        return if @sleep_mode != :sleep

      when :idol
        return if all_controls_idle?

      when :count
        #待ちフレーム数を取得。
        #設定されていない場合はコンフィグから初期値を取得する
        #TODO:@style_config[:wait_frame]はchar特有のプロパティ
        wait_frame =  options[:count] == :unset_wait_frame ?
                      @style_config[:wait_frame] :
                      options[:count]
        #残りwaitフレーム数が０より大きい場合
        return if wait_frame <= 0
        options[:count] = wait_frame - 1

      when :command
        #コマンドがリスト上に存在しなければ終了
        unless @next_frame_commands.index{|command|
          command[0]==options[:command]}
          return
        end
      when :flag
        unless @root_control.system_property[:global_flag][("user_" + options[:flag].to_s).to_sym]
          return
        end

      when :key_push
        #キー押下があれば終了
        if Input.key_push?(K_SPACE)
          return
        end

      when :skip
        #スキップモードであれば終了
        return if @skip_mode
      end
    end

    #フレーム終了疑似コマンドをスタックする
    eval_commands([[:end_frame, {}, {:target_id => @id}]])

    #waitにブロックが付与されているならそれを実行する
    eval_block(options, inner_options, inner_options[:block])

    push_command_to_next_frame(:wait, options, inner_options)
  end

  def command_check_key_push(options, inner_options)
    #TODO:checkは内部的にはwaitと同じ処理になる筈
    #キーが押された場合
    if Input.key_push?(K_SPACE)
      #waitにブロックが付与されているならそれを実行する
      eval_block(options, inner_options, inner_options[:block])
    end
  end
end

class Control

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #イベントコマンドの登録
  def command_event(options, inner_options)
    @event_list[options[:event]] = inner_options[:block]
  end

  #イベントの実行
  def command_fire(options, inner_options)
    #キーが登録されていないなら終了
    return if !@event_list[options[:fire]]

    eval_block(options, @event_list[options[:fire]])
  end

  #############################################################################
  #スタック操作関連
  #############################################################################

  #ユーザー定義コマンドを定義する
  def command_define(options, inner_options)
    @root_control.system_property[:function_list][options[:define]] = inner_options[:block]
  end

  #関数呼び出し
  def command_call_function(options, inner_options)
    #定義されていないfunctionが呼びだされたら例外を送出
    raise NameError, "undefined local variable or command or function `#{options[:call_function]}' for #{inner_options}" unless @root_control.system_property[:function_list].key?(options[:call_function])

    inner_options[:block_stack] = Array.new unless inner_options[:block_stack]
    #関数ブロックを引数に登録する
    inner_options[:block_stack].push(inner_options[:block])
    #下位伝搬を防ぐ為に要素を削除
    inner_options.delete(:block)

    #関数名に対応する関数ブロックを取得する
    function_block = @root_control.system_property[:function_list][options[:call_function]]
    #下位伝搬を防ぐ為に要素を削除
    options.delete(:call_function)

    #functionを実行時評価しコマンド列を生成する。
    eval_block(options, inner_options, function_block)
  end

  def command_call_builtin_command(options, inner_options)
    command_name = options[:call_builtin_command]
    options.delete(:call_builtin_command) #削除
    send("command_" + command_name.to_s, options, inner_options)
  end

  #ブロック内のコマンド列を実行する
  def command_about(options, inner_options)
    #コマンドリストをスタックする
    eval_block(options, inner_options[:block])
  end

  #############################################################################
  #分類未決定
  #############################################################################

  #フラグを設定する
  def command_flag(options, inner_options)
    #ユーザー定義フラグを更新する
    @root_control.system_property[:global_flag][("user_" + options[:key].to_s).to_sym] = options[:data]
  end

  #コマンド送信先ターゲットのデフォルトを変更する
  def command_change_default_target(options, inner_options)
    @control_default[options[:change_default_target]] = options[:id]
  end

  #次に読み込むスクリプトファイルのパスを設定する
  def command_next_scenario(options, inner_options)
    @next_script_file_path = options[:next_scenario]
  end
  
  #スクリプトファイルの読み込み
  def command_load_script(options, inner_options)
    #指定されたスクリプトファイルを直接読み込む
    #TODO：@command_listに上書きするのか、追記するのかはオプションで指定できた方が良いか？　その
    @command_list = @script_compiler.commands({:script_path => options[:load_script]})
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
  def command__IF_(options, inner_options)
    #条件式を評価し、結果をoptionsに再格納する
    if eval_lambda(options[:_IF_], options)
      result = :then
    else
      result = :else
    end

    #if文の中身を実行する
    eval_block(options, inner_options[:block])

    push_command_to_next_frame(:exp_result, {:result => result}, inner_options)
  end

  #thenコマンド
  def command__THEN_(options, inner_options)
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }
    
    #結果がthenの場合
    if result and @next_frame_commands[result][1][:result] == :then
      #コマンドブロックを実行する
      eval_block(options, inner_options[:block])
    end
  end

  #elseコマンド
  def command__ELSIF_(options, inner_options)
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }

    #結果がelseの場合
    if result and @next_frame_commands[result][1][:result] == :else
      #ラムダ式が真の場合
      if eval_lambda(options[:_ELSIF_], options)
        #コマンドブロックを実行する
        eval_block(options, inner_options[:block])
        #処理がこれ以上伝搬しないように評価結果をクリアする
        #TODO：コマンド自体を削除した方が確実
        @next_frame_commands[result][1][:result] = nil
      end
    end
  end

  #elseコマンド
  def command__ELSE_(options, inner_options)
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }

    #結果がelseの場合
    if result and @next_frame_commands[result][1][:result] == :else
      #コマンドブロックを実行する
      eval_block(options, inner_options[:block])
    end
  end

  #繰り返し
  def command__WHILE_(options, inner_options)
    #条件式が非成立であれば繰り返し構文を終了する
    return if !eval_lambda(options[:_WHILE_], options) #アイドル

    #while文全体をスクリプトストレージにスタック
    eval_commands([[:_WHILE_, options, inner_options]])
    #ブロックを実行時評価しコマンド列を生成する。
    eval_block(options, inner_options[:block])
  end

  def command__CASE_(options, inner_options)
    #比較元のオブジェクトを評価する
    value = eval_lambda(options[:_CASE_], options)

    #case文の中身を実行する
    eval_block(options, inner_options[:block])

    push_command_to_next_frame(:exp_result, 
                              { :result => :else, :case_value => value}, 
                              nil)
  end

  def command__WHEN_(options, inner_options)
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }

    #評価結果が存在しなければ処理を終了する
    return unless result

    exp_result = @next_frame_commands[result][1]

    if exp_result[:case_value] == eval_lambda(options[:_WHEN_], options)
      #コマンドブロックを実行する
      eval_block(options, inner_options[:block])
    end
  end

  #関数ブロックを実行する
  def command__YIELD_(options, inner_options)
    return unless inner_options[:block_stack]
    
    eval_block(options, inner_options, inner_options[:block_stack].pop)
  end

  #コマンドを再定義する
  def command__ALIAS_(options, inner_options)
    #元コマンドが組み込みコマンドの場合
    if @script_compiler.builtin_command_list.include?(options[:command_name])
      #元コマンドをcall_builtin_commandで呼びだすブロックを設定する
      @root_control.system_property[:function_list][options[:_ALIAS_]] = Proc.new{|command_options|
        call_builtin_command(options[:command_name], command_options)
      }

      #コマンドを組み込みコマンドリストから削除する
      @script_compiler.builtin_command_list.delete_if{ |command_name|
        command_name == options[:command_name]
      }
    else
      #新しいコマンド名に元のコマンドのブロックを設定する
      @root_control.system_property[:function_list][options[:_ALIAS_]] = @root_control.system_property[:function_list][options[:command_name]]
    end
  end

  #文字列を評価する（デバッグ用）
  def command__EVAL_(options, inner_options)
    eval(options[:_EVAL_])
  end

  #１フレ分のみifの結果をコマンドリスト上に格納する
  def command_exp_result(options, inner_options)
  end
end
