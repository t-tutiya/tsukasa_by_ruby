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

class Control #公開インターフェイス
  #プロパティ
  attr_accessor  :skip_mode #スキップモード
  attr_accessor  :sleep_mode #スリープモード
  attr_accessor  :idle_mode #アイドルモード
  attr_reader  :system_property
  attr_reader  :user_data

  attr_accessor  :id

  def initialize(options, inner_options, root_control = nil)
    if root_control
      @root_control = root_control
    else
      @root_control = self
      @system_property = {
        #functionのリスト（procで保存される）
        :function_list => {},
      }
      @user_data = {}
    end

    @script_compiler = ScriptCompiler.new

    #コントロールのID(省略時は自身のクラス名とする)
    @id = options[:id] || ("Anonymous_" + self.class.name).to_sym

    @command_list         = [] #コマンドリスト
    @next_frame_commands  = [] #一時コマンドリスト

    @control_list         = [] #コントロールリスト

    @child_update = true #updateを子コントロールに伝搬するか
    @child_render = true #renderを子コントロールに伝搬するか

    @skip_mode = false         #スキップモードの初期化
    @idle_mode = true          #待機モードの初期化
    @sleep_mode = :wake        #スリープの初期状態を設定する

    @delete_flag = false       #削除フラグの初期化
=begin
    #コマンドに設定されているデフォルトの送信先クラスのIDディスパッチテーブル
    @control_default = {
      :TextPageControl   => :default_char_container,
      :RenderTargetContainer => :default_RenderTarget_container,
      :Anonymous       => :anonymous,
    }
=end
    #デフォルトスクリプトの読み込み
    #TODO：将来的にここで読み込まずにINCLUDEコマンドを使いたい
    if options[:default_script_path]
      @command_list += @script_compiler.commands({:script_path => options[:default_script_path]})
    end

    #スクリプトパスが設定されているなら読み込んで登録する
    #TODO：将来的にここで読み込まずにINCLUDEコマンドを使いたい
    if options[:script_path]
      @command_list += @script_compiler.commands({:script_path => options[:script_path]})
    end

    #ブロックが付与されているなら読み込んで登録する
    if inner_options[:block]
      @command_list = @script_compiler.commands(
                          options,
                          inner_options[:block_stack],
                          &inner_options[:block])
    end

    #コマンドセットがあるなら登録する
    eval_commands(options[:commands]) 
  end

  #コマンドをスタックに格納する
  def push_command(command)
    #コマンドをスタックの末端に挿入する
    @command_list.push(command)
  end

  #コマンドをスタックに格納する
  def interrupt_command(command)
    #コマンドをスタックの先頭に挿入する
    @command_list.unshift(command)
  end

  def push_command_to_next_frame(command, options, inner_options)
    @next_frame_commands.push([command, options, inner_options])
  end

  def update
    #次フレコマンド列クリア
    @next_frame_commands = []
    #待機モードを初期化
    @idle_mode = true

    #コマンドリストが空になるまで走査し、コマンドを実行する
    until @command_list.empty?
      #コマンドリストの先頭要素を取得
      command = @command_list.shift
      #コマンドを１時的に展開
      command_name, options, inner_options = command

      #今フレーム処理終了判定
      break if command_name == :end_frame

      #コマンドを実行する
      send("command_" + command_name.to_s, options, inner_options)
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

  def find_control(id)
    #自身が指定されたidか、allが指定されている場合
    if id == @id or id == :all
      #自身をスタックした配列を生成
      controls = [self] 
    else
      #空の配列を生成する
      controls = [] 
    end

    #所持しているコントロールを探査
    @control_list.each do |control|
      child = control.find_control(id)
      controls += child unless child.empty?
    end

    return controls
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

class Control #内部メソッド

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
  def eval_block(options, block_stack = nil, &block)
    return unless block

    eval_commands(@script_compiler.commands(options, 
                                            block_stack, 
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
  
  def check_imple(conditions, options)
    conditions.each do |condition|
      case condition
      when :wake
        return true if @sleep_mode == :wake

      when :idol
        return true if all_controls_idle?

      when :count
        #残りwaitフレーム数が０より大きい場合
        return true if options[:count] <= 0

      when :command
        #コマンドがリスト上に存在しなければ
        unless @next_frame_commands.index{|command|
          command[0]==options[:command]}
          return true 
        end

      when :key_push
        #キー押下があれば
        return true if Input.key_push?(K_SPACE)

      when :skip
        #スキップモードであれば
        return true if @skip_mode

      #ユーザデータ確認系

      when :equal
        #指定されたデータと値がイコールかどうか
        return true if @root_control.user_data[options[:key]] == options[:val]

      when :not_equal
        #指定されたデータと値がイコールでない場合
        return true if @root_control.user_data[options[:key]] != options[:val]

      when :nil
        #指定されたデータがnilの場合
        return true if @root_control.user_data[options[:key]] == nil

      when :not_nil
        #指定されたデータがnilで無い場合
        return true if @root_control.user_data[options[:key]] != nil
      end
    end
    
    return false
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
  def command__CREATE_(options, inner_options)
    #スキップモードの指定
    #TODO：ここで入れるのは相当イマイチ。方法を考える
    options[:skip_mode] = @skip_mode

    #コントロールを生成して子要素として登録する
    @control_list.push(Module.const_get(options[:_ARGUMENT_]).new( options, 
                                                               inner_options, 
                                                               @root_control))
    #付与ブロックを実行する
    @control_list.last.update()
  end

  #disposeコマンド
  #コントロールを削除する
  def command__DELETE_(options, inner_options)
    #削除フラグを立てる
    dispose()
  end

  #コントロールのプロパティを更新する
  def command__SET_(options, inner_options)
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

  #ユーザーデータ領域に値を保存する
  def command__SET_DATA_(options, inner_options)
    @root_control.user_data[options[:key]] = options[:val]
  end

  #コマンドを下位コントロールに送信する
  def command__SEND_(options, inner_options)
    if options[:root]
      base_control = @root_control
    else
      base_control = self
    end

    unless options[:_ARGUMENT_]
      if options[:interrupt]
        base_control.interrupt_command([:_CALL_, {:_ARGUMENT_ => :scope}, inner_options])
      else
        base_control.push_command([:_CALL_, {:_ARGUMENT_ => :scope}, inner_options])
      end

      return
    end

    case options[:_ARGUMENT_]
    when :all
      controls = base_control.find_control(:all)
    when :last
      #TODO*ここの実装が歪んでいる。しかしどうしたものか。
      controls = [@control_list.last]
    else
      controls = base_control.find_control(options[:_ARGUMENT_])
    end

    controls.each do |control|
      if options[:interrupt]
        control.interrupt_command([:_CALL_, {:_ARGUMENT_ => :scope}, inner_options])
      else
        control.push_command([:_CALL_, {:_ARGUMENT_ => :scope}, inner_options])
      end
    end
  end

  #############################################################################
  #タイミング制御コマンド
  #############################################################################

  def command__WAIT_(options, inner_options)
    #待ちフレーム値が設定されていない場合はコンフィグから初期値を取得する
    #TODO:@style_config[:wait_frame]はchar特有のプロパティ
    if options[:count] and (options[:count] == :unset_wait_frame)
      options[:count] = @style_config[:wait_frame]
    end

    #チェック条件を満たしたら終了する
    return if check_imple(options[:_ARGUMENT_], options)

    if options[:count]
      options[:count] = options[:count] - 1
    end

    #フレーム終了疑似コマンドをスタックする
    eval_commands([[:end_frame, {}, {}]])

    #waitにブロックが付与されているならそれを実行する
    eval_block(options, &inner_options[:block])

    push_command_to_next_frame(:_WAIT_, options, inner_options)
  end

  def command__CHECK_(options, inner_options)
    #チェック条件を満たさない場合
    unless check_imple(options[:_ARGUMENT_], options)
      #指定があればコマンドを再スタックする
      if options[:keep]
        push_command_to_next_frame(:_CHECK_, options, inner_options)
      end
      return
    end

    #checkにブロックが付与されているならそれを実行する
    eval_block(options, &inner_options[:block])
  end

  #繰り返し
  def command__WHILE_(options, inner_options)
    #条件式が非成立であれば繰り返し構文を終了する
    return if !eval_lambda(options[:_ARGUMENT_], options) #アイドル

    interrupt_command([:_END_SCOPE_, options, inner_options])

    #while文全体をスクリプトストレージにスタック
    eval_commands([[:_WHILE_, options, inner_options]])
    #ブロックを実行時評価しコマンド列を生成する。
    eval_block(options, &inner_options[:block])
  end

  def command__BREAK_(options, inner_options)
    #_END_SCOPE_タグが見つかるまで@command_listからコマンドを取り除く
    #_END_SCOPE_タグが見つからない場合は@command_listを空にする
    until @command_list.empty? do
      command, end_scope_options = @command_list.shift
      break if command == :_END_SCOPE_
    end
  end
end

#############################################################################
#***コマンド
#############################################################################

class Control #ユーザー定義関数操作

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #スクリプトファイルを挿入する
  def command__INCLUDE_(options, inner_options)
    eval_commands(@script_compiler.commands({:script_path => options[:_ARGUMENT_]}))
  end

  #ユーザー定義コマンドを定義する
  def command__DEFINE_(options, inner_options)
    @root_control.system_property[:function_list][options[:_ARGUMENT_]] = inner_options[:block]
  end

  #関数呼び出し
  def command__CALL_(options, inner_options)
    #定義されていないfunctionが呼びだされたら例外を送出
    raise NameError, "undefined local variable or command or function `#{options[:_ARGUMENT_]}' for #{inner_options}" unless @root_control.system_property[:function_list].key?(options[:_ARGUMENT_])

    #伝搬されているブロックがある場合
    if inner_options[:block_stack]
      block_stack = inner_options[:block_stack]
      if inner_options[:block]
        block_stack.push(inner_options[:block]) 
      end
    #付与ブロックがある場合
    elsif inner_options[:block]
      block_stack = [inner_options[:block]]
    else
      block_stack = nil
    end

    #関数名に対応する関数ブロックを取得する
    function_block = @root_control.system_property[:function_list][options[:_ARGUMENT_]]
    
    if options[:_FUNCTION_ARGUMENT_]
      options[:_ARGUMENT_] = options[:_FUNCTION_ARGUMENT_] 
      #下位伝搬を防ぐ為に要素を削除
      options.delete(:_FUNCTION_ARGUMENT_)
    else
      options.delete(:_ARGUMENT_)
    end

    #functionを実行時評価しコマンド列を生成する。
    eval_block(options, block_stack, &function_block)
  end

  #関数ブロックを実行する
  def command__YIELD_(options, inner_options)
    return unless inner_options[:block_stack]

    block = inner_options[:block_stack].pop
    block_stack = inner_options[:block_stack].empty? ? nil : inner_options[:block_stack]

    eval_block(options, block_stack, &block)
  end

  #文字列を評価する（デバッグ用）
  def command__EVAL_(options, inner_options)
    eval(options[:_ARGUMENT_])
  end
end

class Control #廃止できないか検討中

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #コマンド送信先ターゲットのデフォルトを変更する
  def command_change_default_target(options, inner_options) #廃止できないか検討中
    raise
    @control_default[options[:_ARGUMENT_]] = options[:id]
  end
end


#############################################################################
#制御構文コマンド
#############################################################################

class Control #制御構文：廃止予定

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #ifコマンド
  def command__IF_(options, inner_options) #廃止予定
    #条件式を評価し、結果をoptionsに再格納する
    if eval_lambda(options[:_ARGUMENT_], options)
      result = :then
    else
      result = :else
    end

    #if文の中身を実行する
    eval_block(options, &inner_options[:block])

    push_command_to_next_frame(:exp_result, {:result => result}, inner_options)
  end

  #thenコマンド
  def command__THEN_(options, inner_options) #廃止予定
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }
    
    #結果がthenの場合
    if result and @next_frame_commands[result][1][:result] == :then
      #コマンドブロックを実行する
      eval_block(options, &inner_options[:block])
    end
  end

  #elseコマンド
  def command__ELSIF_(options, inner_options) #廃止予定
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }

    #結果がelseの場合
    if result and @next_frame_commands[result][1][:result] == :else
      #ラムダ式が真の場合
      if eval_lambda(options[:_ARGUMENT_], options)
        #コマンドブロックを実行する
        eval_block(options, &inner_options[:block])
        #処理がこれ以上伝搬しないように評価結果をクリアする
        #TODO：コマンド自体を削除した方が確実
        @next_frame_commands[result][1][:result] = nil
      end
    end
  end

  #elseコマンド
  def command__ELSE_(options, inner_options) #廃止予定
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }

    #結果がelseの場合
    if result and @next_frame_commands[result][1][:result] == :else
      #コマンドブロックを実行する
      eval_block(options, &inner_options[:block])
    end
  end

  def command__CASE_(options, inner_options) #廃止予定
    #比較元のオブジェクトを評価する
    value = eval_lambda(options[:_ARGUMENT_], options)

    #case文の中身を実行する
    eval_block(options, &inner_options[:block])

    push_command_to_next_frame(:exp_result, 
                              { :result => :else, :case_value => value}, 
                              nil)
  end

  def command__WHEN_(options, inner_options) #廃止予定
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }

    #評価結果が存在しなければ処理を終了する
    return unless result

    exp_result = @next_frame_commands[result][1]

    if exp_result[:case_value] == eval_lambda(options[:_ARGUMENT_], options)
      #コマンドブロックを実行する
      eval_block(options, &inner_options[:block])
    end
  end
end

class Control #内部コマンド群

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #１フレ分のみifの結果をコマンドリスト上に格納する
  def command_exp_result(options, inner_options)
  end

  #１フレ分のみifの結果をコマンドリスト上に格納する
  def command__END_SCOPE_(options, inner_options)
  end
end