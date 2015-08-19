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
  attr_reader  :user_data
  attr_reader  :global_data
  attr_reader  :function_list

  attr_accessor  :id

  def initialize(options, inner_options, root_control = nil)
    if root_control
      @root_control = root_control
      @user_data = @root_control.user_data
      @global_data = @root_control.global_data
    else
      @root_control = self
      @user_data = {}
      @global_data = {}
    end

    # ユーザ定義関数
    @function_list = options[:function_list] || {} 
    #コントロールのID(省略時は自身のクラス名とする)
    @id = options[:id] || ("Anonymous_" + self.class.name).to_sym
    #コマンドリスト
    @command_list         = options[:command_list] || [] 
    #一時コマンドリスト
    #TODO：これがシリアライズ対象になっているのはおかしいのかもしれない
    @next_frame_commands  = options[:next_frame_commands] || [] 

    @skip_mode = false         #スキップモードの初期化
    @idle_mode = true          #待機モードの初期化
    @sleep_mode = :wake        #スリープの初期状態を設定する

    @script_compiler = ScriptCompiler.new(self, @root_control)
    @control_list         = [] #コントロールリスト
    @delete_flag = false       #削除フラグの初期化

=begin
    #コマンドに設定されているデフォルトの送信先クラスのIDディスパッチテーブル
    @control_default = {
      :TextPageControl   => :default_char_container,
      :RenderTargetContainer => :default_RenderTarget_container,
      :Anonymous       => :anonymous,
    }
=end

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

  #シリアライズ
  #各派生クラスでは、ハッシュに自分を再構築するのに必要なオプションを代入し、superを呼ぶ。
  #TODO:Procをダンプする方法が無いため現在実装ペンディング中
  def siriarize(options = {})

    command_list = []

    #子コントロールのシリアライズコマンドを取得
    @control_list.each do |control|
      command_list.push(control.siriarize)
    end

    #子コントロールのシリアライズコマンドとこのコントロールがスタックしている
    command_list = command_list + @command_list
  
    options.update({
                :_ARGUMENT_ => self.class.name.to_sym,
                :function_list => @function_list,
                :id => @id,
                :command_list => command_list,
                :next_frame_commands => @next_frame_commands
                  })
  
    #オプションを生成
    command = [:_CREATE_, options]

    return command
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

  def check_imple(conditions, options)
    conditions.each do |condition|
      case condition
      when :wake
        return true if @sleep_mode == :wake

      when :idle
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
        key_code = options[:key_code] ? options[:key_code] : K_SPACE
        #キー押下があれば
        return true if Input.key_push?(key_code)

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

      when :true
        #必ず真を返す
        return true

      when :false
        #必ず偽を返す
        return false
      end
    end
    
    return false
  end
end

class Control #コントロールの生成／破棄

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

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
end

class Control #セッター／ゲッター

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #コントロールのプロパティを更新する
  #TODO：複数の変数を一回で設定できるようにしてあるが、１個に限定すべきかもしれない。
  def command__SET_(options, inner_options)
    if options[:_ARGUMENT_]
      variable = options[:_ARGUMENT_]
      options.delete(:_ARGUMENT_)
    else
      variable = nil
    end

    #オプション全探査
    options.each do |key, val|
      if variable
        instance_variable_get("@" + variable.to_s)[key] = val
      else
        if instance_variable_defined?("@" + key.to_s)
          instance_variable_set("@" + key.to_s, val)
        else
          pp "クラス[" + self.class.to_s + "]：変数[" + "@" + key.to_s + "]は存在しません"
        end
      end
    end
  end

  #キーで指定したユーザーデータ領域に値で設定したコントロールの変数をコピーする
  #TODO:微妙に_SET_と直行性が低い
  def command__GET_(options, inner_options)
    #オプション全探査
    options.each do |key, val|
      if instance_variable_defined?("@" + val.to_s)
        @user_data[key] = instance_variable_get("@" + val.to_s)
      else
        pp "クラス[" + self.class.to_s + "]：変数[" + "@" + val.to_s + "]は存在しません"
      end
    end
  end
end

class Control #制御構文

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

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
    #チェック条件を満たさないなら終了する
    return unless check_imple(options[:_ARGUMENT_], options)

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

class Control #ユーザー定義関数操作

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #ユーザー定義コマンドを定義する
  def command__DEFINE_(options, inner_options)
    @function_list[options[:_ARGUMENT_]] = inner_options[:block]
  end

  #関数呼び出し
  def command__CALL_(options, inner_options)
    #関数名に対応する関数ブロックを取得する
    function_block = @function_list[options[:_ARGUMENT_]] || @root_control.function_list[options[:_ARGUMENT_]]
      
    #定義されていないfunctionが呼びだされたら例外を送出
    raise NameError, "undefined local variable or command or function `#{options[:_ARGUMENT_]}' for #{inner_options}" unless function_block
    
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
end

class Control #スクリプト制御

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

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

  #スクリプトファイルを挿入する
  def command__INCLUDE_(options, inner_options)
    eval_commands(@script_compiler.commands({:script_path => options[:_ARGUMENT_]}))
  end

  #文字列を評価する（デバッグ用）
  def command__EVAL_(options, inner_options)
    eval(options[:_ARGUMENT_])
  end
end

class Control #セーブデータ制御

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  def command__SAVE_(options, inner_options)
  end

  def command__LOAD_(options, inner_options)
  end

  #TODO：ProcをMarshal.dumpできない為、このアプローチでのクイックセーブは実現できない。一旦これらの機能開発はペンディングとする
  def command__QUICK_SAVE_(options, inner_options)
    pp siriarize()
    str = Marshal.dump(siriarize()) #コマンドにProcへの参照が含まれる場合ここでエラーになる
    p Marshal.load(str)
    raise
  end

  #TODO：ProcをMarshal.dumpできない為、このアプローチでのクイックセーブは実現できない。一旦これらの機能開発はペンディングとする
  def command__QUICK_LOAD_(options, inner_options)
    raise
  end
end

class Control #内部コマンド

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #１フレ分のみifの結果をコマンドリスト上に格納する
  def command__END_SCOPE_(options, inner_options)
  end
end
