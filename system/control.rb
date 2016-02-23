#! ruby -E utf-8

require 'dxruby'
require 'pstore'

###############################################################################
#TSUKASA for DXRuby ver1.2(2016/3/1)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2016> <tsukasa TSUCHIYA>
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
  #プロセスのカレントディレクトリを保存する
  @@system_path = File.expand_path('../../', __FILE__)

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

  attr_reader  :_RESULT_
end

class Control #内部メソッド

  def initialize(options, yield_block_stack, root_control, &block)
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
    @control_list = [] #コントロールリスト
    @delete_flag = false       #削除フラグの初期化

    #ブロックが付与されているなら読み込んで登録する
    if block
      parse_block(nil, options, yield_block_stack, &block)
    end

    #コマンドセットがあるなら登録する
    if options[:command_list]
      @command_list = options[:command_list] + @command_list
    end

  end

  #コマンドをスタックに格納する
  def push_command(command, argument, options, yield_block_stack, block)
    #コマンドをスタックの末端に挿入する
    @command_list.push([command, argument, options, yield_block_stack, block])
  end

  def push_command_to_next_frame(command, argument, options, yield_block_stack, block)
    @next_frame_commands.push([command, argument, options, yield_block_stack, block])
  end

  def update(offset_x, offset_y, target, 
              parent_control_width, parent_control_height, 
              mouse_pos_x,mouse_pos_y )
    #コマンドリストが空になるまで走査し、コマンドを実行する
    until @command_list.empty?
      #コマンドリストの先頭要素を取得
      command_name, argument, options, yield_block_stack, block = @command_list.shift

      #今フレーム処理終了判定
      break if command_name == :_END_FRAME_

      #コマンドがメソッドとして存在する場合
      if self.respond_to?(command_name, true)
        #コマンドを実行する
        send(command_name, argument, options, yield_block_stack, &block)
      else
        #ユーザー定義コマンドとみなして実行する
        call_user_command(command_name, argument, options, yield_block_stack,&block)
      end
    end

    unless @next_frame_commands.empty?
      #一時的にスタックしていたコマンドをコマンドリストに再スタックする
      #※スワップさせた後に連結している
      @command_list, @next_frame_commands = @next_frame_commands, @command_list
      @command_list.concat(@next_frame_commands)

      #次フレコマンド列を初期化
      @next_frame_commands.clear
    end

    #下位コントロール巡回
    @control_list.delete_if do |child_control|
      #下位コントロールを自ターゲットに直接描画
      child_dx, child_dy = child_control.update(offset_x, offset_y, target, 
                                                parent_control_width , 
                                                parent_control_height , 
                                                mouse_pos_x,
                                                mouse_pos_y)
      #次のコントロールの描画座標原点を設定する
      offset_x += child_dx
      offset_y += child_dy
      #マウス座標のオフセットを更新する
      mouse_pos_x -= child_dx
      mouse_pos_y -= child_dy

      #コントロールの削除チェック
      child_control.delete?
    end

    #オフセット値を返す
    return offset_x, offset_y
  end

  #_TO_IMAGE_用
  def render(offset_x, offset_y, target, 
              parent_control_width, parent_control_height)
    #下位コントロール巡回
    @control_list.each do |child_control|
      #下位コントロールを自ターゲットに直接描画
      child_dx, child_dy = child_control.render(offset_x, offset_y, target, 
                                                parent_control_width , 
                                                parent_control_height)
      #次のコントロールの描画座標原点を設定する
      offset_x += child_dx
      offset_y += child_dy
    end
    #オフセット値を返す
    return offset_x, offset_y
  end

  def find_control(id)
    #整数であれば子要素の添え字と見なす
    return @control_list[id] if id.instance_of?(Fixnum)
    #子コントロールを探査して返す。存在しなければnil
    return @control_list.find {|control| control.id == id }
  end

  #ユーザー定義コマンドの実行
  def call_user_command(command_name, argument, options, yield_block_stack, &block)
    #関数名に対応する関数ブロックを取得する
    function_block =  @function_list[command_name] || 
                      @root_control.function_list[command_name]

    #ユーザー定義コマンドが存在しない場合、コマンド送信文であるとみなす
    unless function_block
      _SEND_(command_name, options, yield_block_stack, &block)
      return
    end

    #参照渡し汚染が起きないようにディープコピーで取得
    yield_block_stack = yield_block_stack ? yield_block_stack.dup : []
    #スタックプッシュ
    yield_block_stack.push(block)
    #終端コマンドを挿入
    @command_list.unshift(:_END_FUNCTION_)

    #functionを実行時評価しコマンド列を生成する。
    parse_block(argument, options, yield_block_stack, &function_block)
  end

  #コントロールを削除して良いかどうか
  def delete?
    return @delete_flag
  end

  #リソースを解放する
  def dispose
    @delete_flag = true
    @control_list.each do |child_control|
      child_control.dispose
    end
    @control_list.clear
    @command_list.clear
  end

  def serialize(control_name = nil, **options)
  
    methods.each do |method|
      method = method.to_s
      if method[-1] == "=" and not(["===", "==", "!="].index(method))
        options[method.chop!.to_sym] = send(method)
      end
    end

    command_list = []

    #子コントロールのシリアライズコマンドを取得
    @control_list.each do |control|
      command_list.push(control.serialize())
    end

    options[:command_list] = command_list unless command_list.empty?

    #オプションを生成
    command = [:_CREATE_, self.class.name.to_sym, options, {}]

    return command
  end
end

class Control #内部メソッド

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #rubyブロックのコマンド列を配列化してスクリプトストレージに積む
  def parse_block(argument, options, yield_block_stack, &block)
    command_list = @root_control.script_compiler.eval_block(
                      argument,
                      options, 
                      yield_block_stack, 
                      self,
                      &block
                    )
    @command_list = command_list + @command_list
  end

  def check_imple(argument, options, yield_block_stack)
    #演算対象のデータ領域を設定
    argument = :_TEMP_ unless argument

    options.each do |key, value|

      return unless value
      #対象キーが配列で渡されていない場合配列に変換する
      value = [value] unless value.instance_of?(Array)

      case key

      when :count
        #count数が０以下の場合に成立
        value.each do |count|
          return true if count <= 0
        end

      #継続条件：コマンドがリスト上に存在している
      when :stack_command
        value.each do |command|
          if @next_frame_commands.index{|stack_command|
            stack_command[0] == command}
            return true 
          end
        end

      #継続条件：コマンドがリスト上に存在していない
      when :not_stack_command
        value.each do |command|
          unless @next_frame_commands.index{|stack_command|
            stack_command[0] == command}
            return true 
          end
        end

      #継続条件：指定ＩＤの子要素が存在する
      when :child
        #キーの入力チェック
        value.each do |id|
          return true if find_control(id)
        end

      #キーが押下されている
      when :key_push
        #キーの入力チェック
        value.each do |key_code|
          return true if Input.key_push?(key_code)
        end

      #キーが押下されていない
      when :not_key_push
        #キーの入力チェック
        value.each do |key_code|
          return true unless Input.key_push?(key_code)
        end

      #キーが押下されている（前回との比較付き）
      when :key_down
        #キーの入力チェック
        value.each do |key_code|
          return true if Input.key_down?(key_code)
        end

      #キーが押下されていない（前回との比較付き）
      when :not_key_down
        #キーの入力チェック
        value.each do |key_code|
          return true unless Input.key_down?(key_code)
        end

      #キーが解除された
      when :key_up
        #キーの入力チェック
        value.each do |key_code|
          return true if Input.key_release?(key_code)
        end

      #キーが解除されていない
      when :not_key_up
        #キーの入力チェック
        value.each do |key_code|
          return true unless Input.key_release?(key_code)
        end

      #ユーザデータ確認系

      when :equal
        #キーの入力チェック
        value.each do |hash|
          #指定されたデータと値がイコールかどうか
          hash.each do |key, val|
            return true if @root_control.send(argument)[key] == val
          end
        end

      when :not_equal
        #キーの入力チェック
        value.each do |hash|
          #指定されたデータと値がイコールでない場合
          hash.each do |key, val|
            return true if @root_control.send(argument)[key] != val
          end
        end

      when :null
        #指定されたデータがnilの場合
        value.each do |key|
          return true if @root_control.send(argument)[key] == nil
        end

      when :not_null
        #指定されたデータがnilで無い場合
        value.each do |key|
          return true if @root_control.send(argument)[key] != nil
        end

      when :system
        value.each do |key|
          case key
          #ウィンドウの閉じるボタンが押下された場合
          when :requested_close
            return true if Input.requested_close?
          when :key_down
            return true if Input.mouse_push?( M_LBUTTON )
          when :key_up
            return true if Input.mouse_release?( M_LBUTTON )
          when :right_key_down
            return true if Input.mouse_push?( M_RBUTTON )
          when :right_key_up
            return true if Input.mouse_release?( M_RBUTTON )
          when :block_given
            return true unless yield_block_stack[-1] == nil
          end
        end
      end
    end
    
    return false
  end

end

class Control #コントロールの生成／破棄

  #############################################################################
  #非公開インターフェイス
  #############################################################################

#  private

  #コントロールをリストに登録する
  def _CREATE_(argument, options, yield_block_stack, &block)
    #コントロールを生成して子要素として登録する
    @control_list.push(
      Module.const_get(argument).new( options, 
                                      yield_block_stack, 
                                      @root_control, 
                                      &block)
    )
  end

  #disposeコマンド
  #コントロールを削除する
  def _DELETE_(argument, options, yield_block_stack)
    #削除フラグを立てる
    dispose()
  end
end

class Control #セッター／ゲッター

  #############################################################################
  #非公開インターフェイス
  #############################################################################

#  private

  #コントロールのプロパティを更新する
  #TODO：複数の変数を一回で設定できるようにしてあるが、１個に限定すべきかもしれない。
  def _SET_(argument, options, yield_block_stack)
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
  def _GET_(argument, options, yield_block_stack)
    #オプション全探査
    options.each do |key, val|
      if argument
        if key == :_RESULT_
          @_RESULT_ = send(argument.to_s)[val]
        else
          @root_control._TEMP_[key] = send(argument.to_s)[val]
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

#  private

  def _WAIT_(argument, options, yield_block_stack, &block)

    #チェック条件を満たしたら終了する
    return if check_imple(argument, options, yield_block_stack)

    if options[:count]
      options[:count] = options[:count] - 1
    end

    #フレーム終了疑似コマンドをスタックする
    @command_list.unshift(:_END_FRAME_)

    if block
      #waitにブロックが付与されているならそれを実行する
      parse_block(argument, options, yield_block_stack, &block)
    end

    @next_frame_commands.push([:_WAIT_, argument, options, yield_block_stack, block])
  end

  def _CHECK_(argument, options, yield_block_stack, &block)
    #チェック条件を満たす場合
    if check_imple(argument, options, yield_block_stack)
      #checkにブロックが付与されているならそれを実行する
      parse_block(argument, options, yield_block_stack, &block)
    end
  end

  #繰り返し
  def _LOOP_(argument, options, yield_block_stack, &block) 
    unless options.empty?
      #チェック条件を満たしたら終了する
      return if check_imple(argument, options, yield_block_stack)
    end

    #カウンタを減算
    if options[:count]
      options[:count] = options[:count] - 1
    end

    #リストの先端に自分自身を追加する
    @command_list.unshift([:_LOOP_, argument, options, yield_block_stack, block])
    @command_list.unshift(:_END_LOOP_)
    #ブロックを実行時評価しコマンド列を生成する。
    parse_block(argument, options, yield_block_stack, &block)
  end

  def _STACK_LOOP_(argument, options, yield_block_stack, &block) 
    unless options.empty?
      #チェック条件を満たしたら終了する
      return if check_imple(argument, options, yield_block_stack)
    end

    #カウンタを減算
    if options[:count]
      options[:count] = options[:count] - 1
    end

    #ブロックを実行時評価しコマンド列を生成する。
    parse_block(argument, options, yield_block_stack, &block)

    @command_list.push(:_END_LOOP_)
    #リストの末端に自分自身を追加する
    @command_list.push([:_STACK_LOOP_, argument, options, yield_block_stack, block])
  end

  def _NEXT_(argument, options, yield_block_stack)
    #_END_LOOP_タグが見つかるまで@command_listからコマンドを取り除く
    #_END_LOOP_タグが見つからない場合は@command_listを空にする
    until @command_list.empty? do
      break if @command_list.shift == :_END_LOOP_ 
    end
  end

  def _BREAK_(argument, options, yield_block_stack)
    #_END_LOOP_タグが見つかるまで@command_listからコマンドを取り除く
    #_END_LOOP_タグが見つからない場合は@command_listを空にする
    until @command_list.empty? do
      if @command_list.shift == :_END_LOOP_ 
        @command_list.shift #_LOOP_をpopする
        break 
      end
    end
  end

  def _RETURN_(argument, options, yield_block_stack)
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

#  private

  #ユーザー定義コマンドを定義する
  def _DEFINE_(argument, options, yield_block_stack, &block)
    @function_list[argument] = block
  end

  #関数ブロックを実行する
  def _YIELD_(argument, options, yield_block_stack)
    new_yield_block_stack = yield_block_stack.dup
    yield_block = new_yield_block_stack.pop
    raise unless yield_block

    parse_block(argument, options, new_yield_block_stack, &yield_block)
  end
end

class Control #スクリプト制御

  #############################################################################
  #非公開インターフェイス
  #############################################################################

#  private

  #コントロールにコマンドブロックを送信する
  def _SEND_(argument, options, yield_block_stack, &block)
    #デフォルト指定があるならターゲットのコントロールを差し替える
    if options[:default]
      raise unless @root_control._DEFAULT_CONTROL_[options[:default]]
      argument = [@root_control._DEFAULT_CONTROL_[options[:default]]]
      options.delete(:default)
    end
    
    control = self
    
    if argument.instance_of?(Array)
      argument.each do |control_id|
        control = control.find_control(control_id)
      end
    else
      control = control.find_control(argument)
    end

    unless control
      pp argument.to_s + "は無効な識別子です"
      return
    end

    control.push_command(:_SCOPE_, nil, nil, yield_block_stack, block)
  end

  #ルートコントロールにコマンドブロックを送信する
  def _SEND_ROOT_(argument, options, yield_block_stack, &block)
    if argument
      @root_control._SEND_(argument, options, yield_block_stack, &block)
    else
      @root_control._SCOPE_(argument, nil, yield_block_stack, &block)
    end
  end

  #スクリプトファイルを挿入する
  def _INCLUDE_(argument, options, yield_block_stack)
    #オプションが設定していなければ例外送出
    raise unless argument

    #第１引数がシンボルの場合
    if argument.instance_of?(Symbol)
      #データストアの値を対象のファイルパスとする
      argument = @root_control._TEMP_[argument]
    end

    #プロセスのカレントディレクトリを強制的に更新する
    #TODO：Window.open_filenameが使用された場合の対策だが、他に方法はないか？
    FileUtils.chdir(@@system_path)
    #ファイルのフルパスを取得
    options[:file_path] = File.expand_path(argument)

    #拡張子取得
    ext_name = File.extname(options[:file_path])
    #rbファイルでなければparserのクラス名を初期化する。
    unless ext_name == ".rb"
      ext_name.slice!(0)
      options[:parser] = ext_name.to_sym
    end

    #スクリプトをパースする
    _PARSE_(File.read(options[:file_path], encoding: "UTF-8"),
                    options, 
                    yield_block_stack)
  end

  #スクリプトをパースする
  def _PARSE_(argument, options, yield_block_stack)
    options[:file_path] = "(parse)" unless options[:file_path]

    #パーサーが指定されている場合
    if options[:parser]
      #文字列を取得して変換をかける
      argument = @root_control.script_parser[options[:parser]][1].apply(
                   @root_control.script_parser[options[:parser]][0].parse(argument)
                 )
    end

    #司スクリプトを評価してコマンド配列を取得し、コマンドリストの先頭に追加する
    command_list = @root_control.script_compiler.eval_commands(
                      argument,
                      options[:file_path],
                      yield_block_stack, 
                    )
    @command_list = command_list + @command_list
  end

  #アプリを終了する
  def _EXIT_(argument, options, yield_block_stack)
    @root_control.close = true
  end

  #文字列を評価する（デバッグ用）
  def _EVAL_(argument, options, yield_block_stack)
    eval(argument)
  end

  #文字列をコマンドラインに出力する（デバッグ用）
  def _PUTS_(argument, options, yield_block_stack)
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

#  private

  #データセーブ
  #TODO：保存先パスや名称は将来的には外部から与えるようにしたい
  def _SAVE_(argument, options, yield_block_stack)
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

  def _LOAD_(argument, options, yield_block_stack)
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

  #ネイティブコードを読み込む
  def _LOAD_NATIVE_(argument, options, yield_block_stack)
    raise unless argument
    require argument
  end

  def _QUICK_SAVE_(argument, options, yield_block_stack)
    raise unless argument.kind_of?(Numeric)

    command_list = []

    @control_list.each do |control|
      command_list.push(control.serialize())
    end

    db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + 
                    argument.to_s +
                    @_SYSTEM_[:_QUICK_DATA_FILENAME_])

    db.transaction do
      db["key"] = Marshal.dump(command_list)
    end
  end

  def _QUICK_LOAD_(argument, options, yield_block_stack)
    raise unless argument.kind_of?(Numeric)
    db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + 
                    argument.to_s +
                    @_SYSTEM_[:_QUICK_DATA_FILENAME_])

    code = ""

    db.transaction do
      command_list = Marshal.load(db["key"])
      @command_list = command_list + @command_list
    end

  end

end

class Control #内部コマンド

  #############################################################################
  #非公開インターフェイス
  #############################################################################

#  private

  #ブロックを実行する。無名関数として機能する
  def _SCOPE_(argument, options, yield_block_stack, &block)
    #関数の終端を設定
    @command_list.unshift(:_END_FUNCTION_)

    #参照渡し汚染が起きないようにディープコピーで取得
    yield_block_stack = yield_block_stack ? yield_block_stack.dup : []

    #関数を展開する
    parse_block(argument, options, yield_block_stack, &block)
  end

  #ファンクションの終点を示す
  def _END_LOOP_(argument, options, yield_block_stack)
  end

  #ファンクションの終点を示す
  def _END_FUNCTION_(argument, options, yield_block_stack)
  end
  
  #フレームの終了を示す（ダミーコマンド。これ自体は実行されない）
  def _END_FRAME_(argument, options, yield_block_stack)
    raise
  end
end

class Control #プロパティのパラメータ遷移
  def _MOVE_(argument, options, yield_block_stack, &block)
    raise unless argument #必須要素
    
    #オプションハッシュの初期化
    options[:option] =  {} unless options[:option]
    options[:option][:check] =  {} unless options[:option][:check]
    
    #現在の経過カウントを初期化
    unless options[:option][:check][:count]
      options[:option][:check][:count] = argument 
    end
   
    #条件が成立した場合
    if check_imple(options[:option][:datastore], options[:option][:check], yield_block_stack)
      #ブロックがあれば実行し、コマンドを終了する
      if block
        parse_block( nil,
                    {:_STOP_COUNT_ => options[:option][:check][:count]}, 
                    yield_block_stack,
                    &block)
      end
      return
    end

    #カウントダウン
    options[:option][:check][:count] -= 1

    # Easingパラメータが設定されていなければ線形移動を設定
    options[:option][:easing] = :liner unless options[:option][:easing]

    options.each do |key, index|
      next if key == :option

      #開始値が設定されていなければ現在の値で初期化
      unless options[key].instance_of?(Array)
        #オフセットオプションが設定されている場合
        if options[:option][:offset]
          #相対座標移動
          options[key] = [send(key), send(key) + options[key]]
        else
          #絶対座標移動
          options[key] = [send(key), options[key]]
        end
      end

      #値を更新する
      send(key.to_s + "=", 
            (options[key][0] + 
              (options[key][1] - options[key][0]).to_f * 
                EasingProcHash[options[:option][:easing]].call(
                  (argument - options[:option][:check][:count]).fdiv(argument)
              )
            ).to_i)
    end

    #:_MOVE_コマンドをスタックし直す
    @next_frame_commands.push([:_MOVE_, argument, options, yield_block_stack, block])
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
  def _PATH_(argument, options, yield_block_stack, &block)
    raise unless argument #必須要素

    #オプションハッシュの初期化
    options[:option] =  {} unless options[:option]
    options[:option][:check] =  {} unless options[:option][:check]

    #現在の経過カウントを初期化
    unless options[:option][:check][:count]
      options[:option][:check][:count] = argument 
    end

    #条件判定が存在し、かつその条件が成立した場合
    if check_imple(nil, options[:option][:check], yield_block_stack)
      #ブロックがあれば実行し、コマンドを終了する
      if block
        parse_block(nil, options, yiled_block_stack, &block) 
      end
      return
    end

    options[:option][:check][:count] -= 1

    options[:option][:type] = :spline unless options[:option][:type]

    options.each do |key, values|
      next if key == :option

      #Ｂスプライン補間時に始点終点を通らない
      step =(values.size - 1).fdiv(argument) * (argument - options[:option][:check][:count])

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

    #:move_lineコマンドをスタックし直す
    @next_frame_commands.push([:_PATH_, argument, options, yield_block_stack, block])
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
