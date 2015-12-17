#! ruby -E utf-8

require 'dxruby'
require 'pstore'

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
  #システム全体で共有されるデータ群。保存対象。
  def _SYSTEM_
    @root_control._SYSTEM_
  end
  #個別のセーブデータを表すデータ群。保存対象。
  def _LOCAL_
    @root_control._LOCAL_
  end
  #一時的に管理するデータ群。保存対象ではない。
  def _TEMP_
    @root_control._TEMP_
  end

  attr_accessor  :id
  attr_accessor  :sleep
end

class Control #内部メソッド

  def initialize(argument, options, inner_options, root_control)
    #rootコントロールの保存
    @root_control = root_control
    # ユーザ定義関数
    @function_list = {} 
    #コントロールのID(省略時は自身のクラス名とする)
    @id = options[:id] || ("Anonymous_" + self.class.name).to_sym
    #コマンドリスト
    @command_list = [] 
    #一時コマンドリスト
    @next_frame_commands = [] 
    #スリープモード
    @sleep_mode = false

    @script_compiler = ScriptCompiler.new(self, @root_control)
    @control_list = [] #コントロールリスト
    @delete_flag = false       #削除フラグの初期化

    #ブロックが付与されているなら読み込んで登録する
    if inner_options[:block]
      inner_options[:block_stack] = [] unless inner_options[:block_stack]
      inner_options[:yield_block_stack] = [] unless inner_options[:yield_block_stack]
      
      eval_block( argument,
                  options, 
                  inner_options[:block_stack], 
                  inner_options[:yield_block_stack], 
                  &inner_options[:block])
    end

    #コマンドセットがあるなら登録する
    if options[:command_list]
      eval_commands(options[:command_list]) 
    end

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

  def push_command_to_next_frame(command, argument, options, inner_options)
    @next_frame_commands.push([command, argument, options, inner_options])
  end

  def update
    #スリープモード中であれば処理しない
    return if @sleep_mode

    #次フレコマンド列クリア
    @next_frame_commands = []

    #コマンドリストが空になるまで走査し、コマンドを実行する
    until @command_list.empty?
      #コマンドリストの先頭要素を取得
      command = @command_list.shift
      #コマンドを１時的に展開
      command_name, argument, options, inner_options = command

      #今フレーム処理終了判定
      break if command_name == :_END_FRAME_

      #コマンドを実行する
      send("command_" + command_name.to_s, argument, options, inner_options)
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
  def render(offset_x, offset_y, target, parent)
    #スリープモード中であれば処理しない
    #return if @sleep_mode

    #下位コントロール巡回
    @control_list.each do |child_control|
      #下位コントロールを上位ターゲットに直接描画
      width, height = child_control.render( offset_x, 
                                            offset_y, 
                                            target, 
                                            parent)
      #次のコントロールの描画座標原点を設定する
      offset_x += width
      offset_y += height
      #マウス座標のオフセットを更新する
      parent[:mouse_pos_x] -= width
      parent[:mouse_pos_y] -= height
    end

    #オフセット値を返す
    return offset_x, offset_y
  end

  def find_control(id)

    case id
    #自身のidもしくは省略されている場合は自身を帰す
    when @id, nil
      return [self]

    #子コントロールの最終要素を返す
    when :last
      return [@control_list.last]
    end

    #整数であれば、子要素を添え字検索する
    if id.instance_of?(Fixnum)
      return [@control_list[id]]
    end

    controls = []
    #子コントロールを探査
    @control_list.each do |control|
      child = control.find_control(id)
      controls += child unless child.empty?
    end
    return controls
  end

  #コントロールを削除して良いかどうか
  def delete?
    return @delete_flag
  end

  def sleep_mode(mode)
    @sleep_mode = mode
  end
  def sleep_mode?
    @sleep_mode
  end
=begin
  def siriarize(options = {})

    command_list = []

    #子コントロールのシリアライズコマンドを取得
    @control_list.each do |control|
      command_list.push(control.siriarize)
    end

    options.update({
      :id => @id,
      :script_file_path => @script_file_path,
      :command_list => command_list,
    })

    #オプションを生成
    command = [:_CREATE_, options, {}]

    return command
  end
=end
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
  def eval_block(argument, options, block_stack, yield_block_stack, &block)
    raise unless block
    raise unless block_stack
    raise unless yield_block_stack

    eval_commands(@script_compiler.commands(argument,
                                            options, 
                                            block_stack, 
                                            yield_block_stack, 
                                            self,
                                            &block))
  end

  def check_imple(argument, options)
    #条件の強制的な成立
    return true if argument === true
    #条件の強制的な不成立
    return false if argument === false

    #演算対象のデータ領域を設定
    data_strore = argument ? argument : :_TEMP_

    options.each do |key, value|
      case key

      when :count
        #残りwaitフレーム数が０より大きい場合
        return true if value <= 0

      #継続条件：コマンドがリスト上に存在している
      when :command
        unless @next_frame_commands.index{|command|
          command[0] == value}
          return true 
        end

      #継続条件：指定ＩＤの子要素が存在する
      when :child
        return unless value
        return true if find_control(value).count == 0

      #キーが押下されている
      when :key_push
        #対象キーが配列で渡されていない場合配列に変換する
        value = [value] unless value.instance_of?(Array)
        #キーの入力チェック
        value.each do |key_code|
          return true if Input.key_push?(key_code)
        end

      #キーが押下されていない
      when :not_key_push
        #対象キーが配列で渡されていない場合配列に変換する
        value = [value] unless value.instance_of?(Array)
        #キーの入力チェック
        value.each do |key_code|
          return true unless Input.key_push?(key_code)
        end

      #キーが押下されている（前回との比較付き）
      when :key_down
        #対象キーが配列で渡されていない場合配列に変換する
        value = [value] unless value.instance_of?(Array)
        #キーの入力チェック
        value.each do |key_code|
          return true if Input.key_down?(key_code)
        end

      #キーが押下されていない（前回との比較付き）
      when :not_key_down
        #対象キーが配列で渡されていない場合配列に変換する
        value = [value] unless value.instance_of?(Array)
        #キーの入力チェック
        value.each do |key_code|
          return true unless Input.key_down?(key_code)
        end

      #キーが解除された
      when :key_up
        #対象キーが配列で渡されていない場合配列に変換する
        value = [value] unless value.instance_of?(Array)
        #キーの入力チェック
        value.each do |key_code|
          return true if Input.key_release?(key_code)
        end

      #キーが解除されていない
      when :not_key_up
        #対象キーが配列で渡されていない場合配列に変換する
        value = [value] unless value.instance_of?(Array)
        #キーの入力チェック
        value.each do |key_code|
          return true unless Input.key_release?(key_code)
        end

      #ユーザデータ確認系

      when :equal
        return unless value
        #指定されたデータと値がイコールかどうか
        value.each do |key, val|
          return true if @root_control.send(data_strore)[key] == val
        end

      when :not_equal
        return unless value
        #指定されたデータと値がイコールでない場合
        value.each do |key, val|
          return true if @root_control.send(data_strore)[key] != val
        end

      when :null
        return unless value
        value = [value] unless value.instance_of?(Array)
        #指定されたデータがnilの場合
        value.each do |key|
          return true if @root_control.send(data_strore)[key] == nil
        end

      when :not_null
        return unless value
        value = [value] unless value.instance_of?(Array)
        #指定されたデータがnilで無い場合
        value.each do |key|
          return true if @root_control.send(data_strore)[key] != nil
        end

      #ウィンドウの閉じるボタンが押下された場合
      when :requested_close
        return true if Input.requested_close? == value

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
  def command__CREATE_(argument, options, inner_options)
    #コントロールを生成して子要素として登録する
    @control_list.push(Module.const_get(argument).new( argument,
                                                       options, 
                                                       inner_options, 
                                                       @root_control))
    #付与ブロックを実行する
    @control_list.last.update()
  end

  #disposeコマンド
  #コントロールを削除する
  def command__DELETE_(argument, options, inner_options)
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
  def command__SET_(argument, options, inner_options)
    #オプション全探査
    options.each do |key, val|
      if argument
        #ハッシュに値を代入する
        send(argument.to_s)[key] = val
      else
        #セッターが用意されている場合
        if  respond_to?(key.to_s + "=")
          send(key.to_s + "=", val)
        #どちらも無い場合はwarningを出して処理を続行する
        else
          pp "クラス[" + self.class.to_s + "]：変数[" + "@" + key.to_s + "]は存在しません"
        end
      end
    end
  end

  #キーで指定したユーザーデータ領域に値で設定したコントロールの変数をコピーする
  #キーに:_RESULT_が指定された場合、内部変数@_RESULT_に格納され、再帰的に中身を読み出せる。
  ##  ex.
  ##  @test = {:n1 => {:nn1 => 4,:nn2 => 50}, :n2 => [1,20,300]}
  ##  上記ハッシュに対して以下のコマンドを実行した場合
  ##  _GET_ :test, u1: :n1, _RESULT_: :n2
  ##  _GET_ :_RESULT_,  u3: 0, u4: 2
  ##  ユーザーデータ領域には以下のように格納される（u1はこれ以上中が読めない）
  ##  @user_data = {:u1=>{:nn1=>4, :nn2=>50}, :u3=>1, :u4=>300}
  def command__GET_(argument, options, inner_options)
    #オプション全探査
    options.each do |key, val|
      if argument
        if key == :_RESULT_
          @_RESULT_ = send(argument.to_s)[val]
        else
          @root_control._TEMP_[key] = send(variable.to_s)[val]
        end
      else
        if respond_to?(val.to_s)
          @root_control._TEMP_[key] = send(val.to_s)
        else
          pp "クラス[" + self.class.to_s + "]：変数[" + "@" + val.to_s + "]は存在しません"
        end
      end
    end
  end
end

class Control #制御構文

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  def command__WAIT_(argument, options, inner_options)

    #チェック条件を満たしたら終了する
    return if check_imple(argument, options)

    if options[:count]
      options[:count] = options[:count] - 1
    end

    #フレーム終了疑似コマンドをスタックする
    eval_commands([[:_END_FRAME_, nil, {}, {}]])

    if inner_options[:block]
      #waitにブロックが付与されているならそれを実行する
      eval_block( argument, 
                  options, 
                  inner_options[:block_stack], 
                  inner_options[:yield_block_stack], 
                  &inner_options[:block])
    end

    push_command_to_next_frame(:_WAIT_, argument, options, inner_options)
  end

  def command__CHECK_(argument, options, inner_options)
    #チェック条件を満たさない場合
    if check_imple(argument, options)
      #checkにブロックが付与されているならそれを実行する
      eval_block( argument, 
                  options, 
                  [], 
                  inner_options[:yield_block_stack], 
                  &inner_options[:block])
      return
    end
  end

  #繰り返し
  def command__LOOP_(argument, options, inner_options) 
    unless options.empty?
      #チェック条件を満たしたら終了する
      return if check_imple(argument, options)
    end

    #カウンタを減算
    if options[:count]
      options[:count] = options[:count] - 1
    end

    #継続フラグが立っているならフレーム区切りを入れない
    unless options[:continuation]
      #while文全体をスクリプトストレージにスタック
      push_command([:_END_FRAME_, argument, {}, {}])
    end
    
    if options[:interrupt]
      #リストの先端に自分自身を追加する
      interrupt_command([:_LOOP_, argument, options, inner_options])
    else
      #リストの末端に自分自身を追加する
      push_command([:_LOOP_, argument, options, inner_options])
    end

    #ブロックを実行時評価しコマンド列を生成する。
    eval_block( argument, 
                options, 
                [], 
                inner_options[:yield_block_stack], 
                &inner_options[:block])
  end

  def command__BREAK_(argument, options, inner_options)
    #_LOOP_タグが見つかるまで@command_listからコマンドを取り除く
    #_LOOP_タグが見つからない場合は@command_listを空にする
    until @command_list.empty? do
      break if @command_list.shift[0] == :_LOOP_
    end
  end

  def command__RETURN_(argument, options, inner_options)
    #_END_FUNCTION_タグが見つかるまで@command_listからコマンドを取り除く
    #_END_FUNCTION_タグが見つからない場合は@command_listを空にする
    until @command_list.empty? do
      break if @command_list.shift[0] == :_END_FUNCTION_
    end
  end
end

class Control #ユーザー定義関数操作

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #ユーザー定義コマンドを定義する
  def command__DEFINE_(argument, options, inner_options)
    @function_list[argument] = inner_options[:block]
  end

  #関数呼び出し
  def command__CALL_(argument, options, inner_options)
    #関数名に対応する関数ブロックを取得する
    function_block =  @function_list[argument] || 
                      @root_control.function_list[argument]

    #指定されたコマンドが定義されていない場合
    unless function_block
      #下位コントロールへの_SEND_であるとみなす
      command__SEND_(argument, options, inner_options)
      return
    end

    #参照渡し汚染が起きないようにディープコピーで取得
    block_stack = inner_options[:block_stack].dup
    yield_block_stack = inner_options[:yield_block_stack].dup
    #スタックプッシュ
    yield_block_stack.push(inner_options[:block])

    if options[:_FUNCTION_ARGUMENT_]
      argument = options[:_FUNCTION_ARGUMENT_] 
      #下位伝搬を防ぐ為に要素を削除
      options.delete(:_FUNCTION_ARGUMENT_)
    end

    interrupt_command([:_END_FUNCTION_, argument, options, inner_options])

    #functionを実行時評価しコマンド列を生成する。
    eval_block(argument, options, block_stack, yield_block_stack, &function_block)
  end

  #関数ブロックを実行する
  def command__YIELD_(argument, options, inner_options)
    #ブロックスタックをディープコピーで取得
    block_stack = inner_options[:block_stack].dup
    yield_block_stack = inner_options[:yield_block_stack].dup

    block = yield_block_stack.pop
    return unless block

    eval_block( argument, 
                options, 
                block_stack, 
                yield_block_stack, 
                &block)
  end
end

class Control #スリープ

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #コントロールをスリープ状態にする
  def command__SLEEP_(argument, options, inner_options)
    unless argument
      @sleep_mode = true
      #フレーム終了疑似コマンドをスタックする
      eval_commands([[:_END_FRAME_, {}, {}]])
      return
    end

    #ルートコントロールをベースに探索
    @root_control.find_control(argument).each do |control|
      control.sleep_mode(true)
    end

  end

  #コントロールをスリープ状態から復帰させる
  def command__WAKE_(argument, options, inner_options)
    unless argument
      @sleep_mode = false
      return
    end

    #ルートコントロールをベースに探索
    @root_control.find_control(argument).each do |control|
      control.sleep_mode(false)
    end
  end
end

class Control #スクリプト制御

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #コントロールにコマンドブロックを送信する
  def command__SEND_(argument, options, inner_options)
    #デフォルト指定があるならターゲットのコントロールを差し替える
    if options[:default]
      raise unless @root_control.default_control[options[:default]]
      argument = @root_control.default_control[options[:default]]
    end

    controls = find_control(argument)

    if controls.empty?
      pp argument.to_s + "は無効な識別子です"
      return
    end

    #獲得した全てのコントロールにブロックを送信する
    controls.each do |control|
      control.push_command([:_SCOPE_, nil, {}, inner_options])
    end
  end

  #ルートコントロールにコマンドブロックを送信する
  def command__SEND_ROOT_(argument, options, inner_options)
    @root_control.interrupt_command([:_SCOPE_, argument, {}, inner_options])
  end

  #スクリプトファイルを挿入する
  def command__INCLUDE_(argument, options, inner_options)
    #オプションが設定していなければ例外送出
    raise unless argument

    #文字列が直接指定されていればそれをファイルパスとする
    if argument
      @script_file_path = argument
    else
      #キーで指定されたデータストアのデータをファイルパスとする
      options.each do |key, value|
        @script_file_path = @root_control.send(key)[value]
      end
    end

    @command_list =  
      @script_compiler.commands(nil,
                                {:script_file_path => @script_file_path}, 
                                inner_options[:block_stack], 
                                inner_options[:yield_block_stack], 
                                self) + 
                                 @command_list
  end

  #アプリを終了する
  def command__EXIT_(argument, options, inner_options)
    @root_control.close = true
  end

  #文字列を評価する（デバッグ用）
  def command__EVAL_(argument, options, inner_options)
    eval(argument)
  end

  #文字列をコマンドラインに出力する（デバッグ用）
  def command__PUTS_(argument, options, inner_options)
    #第１引数を出力する
    pp argument if argument 
    #ハッシュを出力する
    pp options unless options.empty?
  end
end

class Control #セーブデータ制御

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #データセーブ
  #TODO：保存先パスや名称は将来的には外部から与えるようにしたい
  def command__SAVE_(argument, options, inner_options)
    raise unless argument.kind_of?(Numeric)
    #グローバルデータ
    if argument == 0
      db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + 
                      @_SYSTEM_[:_SYSTEM_FILENAME_])
      db.transaction do
        db["key"] = @root_control._SYSTEM_
      end
    #ユーザーデータ
    #任意の接尾字を指定する
    elsif argument
      db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + 
                      argument.to_s +
                      @_SYSTEM_[:_LOCAL_FILENAME_])
      db.transaction do
        db["key"] = @root_control._LOCAL_
      end
    else
      #セーブファイル指定エラー
      pp "対象セーブファイルが指定されていません"
      raise 
    end
  end

  def command__LOAD_(argument, options, inner_options)
    raise unless argument.kind_of?(Numeric)
    #グローバルデータ
    if argument == 0
      db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + 
                      @_SYSTEM_[:_SYSTEM_FILENAME_])
      db.transaction do
        @root_control._SYSTEM_ = db["key"]
      end
    #ユーザーデータ
    #任意の接尾字を指定する
    elsif argument
      db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + 
                      argument.to_s +
                      @_SYSTEM_[:_LOCAL_FILENAME_])
      db.transaction do
        @root_control._LOCAL_ = db["key"]
      end
    else
      #セーブファイル指定エラー
      pp "対象セーブファイルが指定されていません"
      raise 
    end
  end

  def command__QUICK_SAVE_(argument, options, inner_options)
    raise unless argument.kind_of?(Numeric)
    command_list = []
    #子コントロールのシリアライズコマンドを取得
    @control_list.each do |control|
      command_list.push(control.siriarize)
    end

  
    db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + 
                    argument.to_s +
                    @_SYSTEM_[:_QUICK_DATA_FILENAME_])

    db.transaction do
      db["key"] = Marshal.dump(command_list)
    end
  end

  def command__QUICK_LOAD_(argument, options, inner_options)
    raise unless argument.kind_of?(Numeric)
    db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + 
                    argument.to_s +
                    @_SYSTEM_[:_QUICK_DATA_FILENAME_])

    code = ""

    db.transaction do
      command_list = Marshal.load(db["key"])
      eval_commands(command_list)
    end

  end

end

class Control #内部コマンド

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #ブロックを実行する。無名関数として機能する
  def command__SCOPE_(argument, options, inner_options)

    #関数の終端を設定
    interrupt_command([:_END_FUNCTION_, argument, options, inner_options])

    #参照渡し汚染が起きないようにディープコピーで取得
    block_stack = inner_options[:block_stack].dup
    yield_block_stack = inner_options[:yield_block_stack] ? inner_options[:yield_block_stack] : []

    #関数を展開する
    eval_block(argument, options, block_stack, yield_block_stack, &inner_options[:block])
  end

  #ファンクションの終点を示す
  def command__END_FUNCTION_(argument, options, inner_options)
  end
  
  #フレームの終了を示す（ダミーコマンド。これ自体は実行されない）
  def command__END_FRAME_(argument, options, inner_options)
    raise
  end
end

class Control #プロパティのパラメータ遷移
  def command__MOVE_(argument, options, inner_options)
    raise unless argument #必須要素
    
    #オプションハッシュの初期化
    options[:option] =  {} unless options[:option]
    
    #現在の経過カウントを初期化
    options[:option][:count] = 0 unless options[:option][:count]

    #条件判定が存在し、かつその条件が成立した場合
    if options[:option][:check] and 
        check_imple(nil, options[:option][:check])
      #ブロックがあれば実行し、コマンドを終了する
      if inner_options[:block]
        eval_block( nil,
                    {:_STOP_COUNT_ => options[:option][:count]}, 
                    inner_options[:block_stack],
                    inner_options[:yield_block_stack],
                    &inner_options[:block])
      end
      return
    end

    # Easingパラメータが設定されていなければ線形移動を設定
    options[:option][:easing] = :liner unless options[:option][:easing]

    options.each do |key, index|

      next if key == :option

      #開始値が設定されていなければ現在の値で初期化
      unless options[key].instance_of?(Array)
        options[key] = [send(key), options[key]]
      end

      #値を更新する
      send(key.to_s + "=", 
            (options[key][0] + 
              (options[key][1] - options[key][0]).to_f * 
                EasingProcHash[options[:option][:easing]].call(
                  options[:option][:count].fdiv(argument)
              )
            ).to_i)
    end

    #カウントが指定フレーム未満の場合
    if options[:option][:count] < argument
      #カウントアップ
      options[:option][:count] += 1
      #:_MOVE_コマンドをスタックし直す
      push_command_to_next_frame(:_MOVE_, argument, options, inner_options)
    end
  end

  # jQuery + jQueryEasingPluginより32種類の内蔵イージング関数。それぞれの動きはサンプルを実行して確認のこと。
  EasingProcHash = {
    :liner => ->x{x},
    :in_quad => ->x{x**2},
    :in_cubic => ->x{x**3},
    :in_quart => ->x{x**4},
    :in_quint => ->x{x**5},
    :in_expo => ->x{x == 0 ? 0 : 2 ** (10 * (x - 1))},
    :in_sine => ->x{-Math.cos(x * Math::PI / 2) + 1},
    :in_circ => ->x{x == 0 ? 0 : -(Math.sqrt(1 - (x * x)) - 1)},
    :in_back => ->x{x == 0 ? 0 : x == 1 ? 1 : (s = 1.70158; x * x * ((s + 1) * x - s))},
    :in_bounce => ->x{1-EasingProcHash[:out_bounce][1-x]},
    :in_elastic => ->x{1-EasingProcHash[:out_elastic][1-x]},
    :out_quad => ->x{1-EasingProcHash[:in_quad][1-x]},
    :out_cubic => ->x{1-EasingProcHash[:in_cubic][1-x]},
    :out_quart => ->x{1-EasingProcHash[:in_quart][1-x]},
    :out_quint => ->x{1-EasingProcHash[:in_quint][1-x]},
    :out_expo => ->x{1-EasingProcHash[:in_expo][1-x]},
    :out_sine => ->x{1-EasingProcHash[:in_sine][1-x]},
    :out_circ => ->x{1-EasingProcHash[:in_circ][1-x]},
    :out_back => ->x{1-EasingProcHash[:in_back][1-x]},
    :out_bounce => ->x{
      case x
      when 0, 1
        x
      else
        if x < (1 / 2.75)
          7.5625 * x * x
        elsif x < (2 / 2.75)
          x -= 1.5 / 2.75
          7.5625 * x * x + 0.75
        elsif x < 2.5 / 2.75
          x -= 2.25 / 2.75
          7.5625 * x * x + 0.9375
        else
          x -= 2.625 / 2.75
          7.5625 * x * x + 0.984375
        end
      end
    },
    :out_elastic => ->x{
      case x
      when 0, 1
        x
      else
        (2 ** (-10 * x)) * Math.sin((x / 0.15 - 0.5) * Math::PI) + 1
      end
    },
    :swing => ->x{0.5 - Math.cos( x * Math::PI ) / 2},
    :inout_quad => ->x{
      if x < 0.5
        x *= 2
        0.5 * x * x
      else
        x = (x * 2) - 1
        -0.5 * (x * (x - 2) - 1)
      end
    },
    :inout_cubic => ->x{
      if x < 0.5
        x *= 2
        0.5 * x * x * x
      else
        x = (x * 2) - 2
        0.5 * (x * x * x + 2)
      end
    },
    :inout_quart => ->x{
      if x < 0.5
        x *= 2
        0.5 * x * x * x * x
      else
        x = (x * 2) - 2
        -0.5 * (x * x * x * x - 2)
      end
    },
    :inout_quint => ->x{
      if x < 0.5
        x *= 2
        0.5 * x * x * x * x * x
      else
        x = (x * 2) - 2
        0.5 * (x * x * x * x * x + 2)
      end
    },
    :inout_sine => ->x{
      -0.5 * (Math.cos(Math::PI * x) - 1);
    },
    :inout_expo => ->x{
      case x
      when 0, 1
        x
      else
        if x < 0.5
          x *= 2
          0.5 * (2 ** (10 * (x - 1)))
        else
          x = x * 2 - 1
          0.5 * (-2 ** (-10 * x) + 2)
        end
      end
    },
    :inout_circ => ->x{
    if x < 0.5
      x *= 2
      -0.5 * (Math.sqrt(1 - x * x) - 1);
    else
      x = x * 2 - 2
      0.5 * (Math.sqrt(1 - x * x) + 1);
    end
    },
    :inout_back => ->x{
      case x
      when 0, 1
        x
      else
        if x < 0.5
          EasingProcHash[:in_back][x*2] * 0.5
        else
          EasingProcHash[:out_back][x*2-1] * 0.5 + 0.5
        end
      end
    },
    :inout_bounce => ->x{
      case x
      when 0, 1
        x
      else
        if x < 0.5
          EasingProcHash[:in_bounce][x*2] * 0.5
        else
          EasingProcHash[:out_bounce][x*2-1] * 0.5 + 0.5
        end
      end
    },
    :inout_elastic => ->x{
      case x
      when 0, 1
        x
      else
        if x < 0.5
          EasingProcHash[:in_elastic][x*2] * 0.5
        else
          EasingProcHash[:out_elastic][x*2-1] * 0.5 + 0.5
        end
      end
    },
  }

  #スプライン補間
  #これらの実装については以下のサイトを参考にさせて頂きました。感謝します。
  # http://www1.u-netsurf.ne.jp/~future/HTML/bspline.html
  def command__PATH_(argument, options, inner_options)
    raise unless argument #必須要素

    #オプションハッシュの初期化
    options[:option] =  {} unless options[:option]
    
    #現在の経過カウントを初期化
    options[:option][:count] = 0 unless options[:option][:count]
    options[:option][:type] = :spline unless options[:option][:type]

    #条件判定が存在し、かつその条件が成立した場合
    if options[:option][:check] and 
      check_imple(nil, options[:option][:check])
      #ブロックがあれば実行し、コマンドを終了する
      if inner_options[:block]
        eval_block( nil,
                    options, 
                    [], 
                    inner_options[:yiled_block_stack], 
                    &inner_options[:block]) 
      end
      return
    end

    options.each do |key, values|
      next if key == :option

      #Ｂスプライン補間時に始点終点を通らない
      step =(values.size - 1).fdiv(argument) * options[:option][:count]

      result = 0.0

      #全ての座標を巡回し、それぞれの座標についてstep量に応じた重み付けを行い、その総和を現countでの座標とする
      values.size.times do |index|
        case options[:option][:type]
        when :spline
          coefficent = b_spline_coefficent(step - index)
        when :line
          coefficent = line_coefficent(step - index)
        else
          raise
        end

        result += values[index] * coefficent
      end

      #移動先座標の決定
      send(key.to_s + "=", result.round)
    end

    #カウントが指定フレーム以下の場合
    if options[:option][:count] < argument
      #カウントアップ
      options[:option][:count] += 1
      #:move_lineコマンドをスタックし直す
      push_command_to_next_frame(:_PATH_, argument, options, inner_options)
    end
  end

  #３次Ｂスプライン重み付け関数
  def b_spline_coefficent(t)
    t = t.abs

    # -1.0 < t < 1.0
    if t < 1.0 
      return (3.0 * t ** 3 -6.0 * t ** 2 + 4.0) / 6.0

    # -2.0 < t <= -1.0 or 1.0 <= t < 2.0
    elsif t < 2.0 
      return  -(t - 2.0) ** 3 / 6.0

    # t <= -2.0 or 2.0 <= t
    else 
      return 0.0
    end
  end

  def line_coefficent(t)
    t = t.abs

    if t <= 1.0 
      return 1 - t
    # t <= -1.0 or 1.0 <= t
    else 
      return 0.0
    end
  end

end
