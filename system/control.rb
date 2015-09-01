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
  attr_accessor  :_USER_DATA_
  attr_accessor  :_GLOBAL_DATA_
  attr_accessor  :_MODE_STATUS_

  attr_accessor  :id

  attr_accessor  :idle_mode

  #Imageのキャッシュ機構の簡易実装
  #TODO:キャッシュ操作：一括クリア、番号を指定してまとめて削除など
  @@image_cache = Hash.new
  #キャッシュされていない画像パスが指定されたら読み込む
  @@image_cache.default_proc = ->(hsh, key) {
    hsh[key] = Image.load(key)
  }

  def initialize(options, inner_options, root_control)
    #rootコントロールの保存
    @root_control = root_control
    
    #個別ユーザーデータ領域
    @_USER_DATA_ = @root_control._USER_DATA_
    #ゲーム全体で共有するセーブデータ
    @_GLOBAL_DATA_ = @root_control._GLOBAL_DATA_
    #各種モードの管理
    @_MODE_STATUS_ =  @root_control._MODE_STATUS_

    # ユーザ定義関数
    @function_list = options[:function_list] || {} 
    #コントロールのID(省略時は自身のクラス名とする)
    @id = options[:id] || ("Anonymous_" + self.class.name).to_sym
    #コマンドリスト
    @command_list         = [] 
    #一時コマンドリスト
    @next_frame_commands  = options[:next_frame_commands] || [] 

    @idle_mode = true          #待機モードの初期化

    @script_compiler = ScriptCompiler.new(self, @root_control)
    @control_list         = [] #コントロールリスト
    @delete_flag = false       #削除フラグの初期化

    #スクリプトパスが設定されているなら読み込んで登録する
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
    if options[:command_list]
      @command_list = options[:command_list] + @command_list
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
      break if command_name == :_END_FRAME_

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
  def render(offset_x, offset_y, target, parent_size)
    #下位コントロール巡回
    @control_list.each do |child_control|
      #下位コントロールを上位ターゲットに直接描画
      offset_x, offset_y = child_control.render(offset_x, offset_y, target, parent_size)
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


  def siriarize(options = {})

    command_list = []

    #子コントロールのシリアライズコマンドを取得
    @control_list.each do |control|
      command_list.push(control.siriarize)
    end

    options.update({
      :_ARGUMENT_ => self.class.name.to_sym,
      :id => @id,
      :command_list => command_list
    })

    #オプションを生成
    command = [:_CREATE_, options, {}]

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
    #条件が単体だった場合、要素１の配列にする。
    conditions = [conditions] unless conditions.instance_of?(Array)

    args_name = options[:type] ? options[:type] : :_USER_DATA_

    conditions.each do |condition|
      case condition
      #汎用モードチェック
      when :mode
        options[:mode] = [options[:mode]] unless options[:mode].instance_of?(Array)
        options[:mode].each do |mode|
          return true if @_MODE_STATUS_[mode]
        end

      when :not_mode
        options[:mode] = [options[:mode]] unless options[:mode].instance_of?(Array)
        options[:mode].each do |mode|
          return true unless @_MODE_STATUS_[mode]
        end

      when :idle
        return true if all_controls_idle?

      when :not_idle
        return true unless all_controls_idle?

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
        key_code = options[:key_push_code] ? options[:key_push_code] : K_SPACE
        #キー押下があれば
        return true if Input.key_push?(key_code)

      when :not_key_push
        key_code = options[:key_push_code] ? options[:key_push_code] : K_SPACE
        #キー押下があれば
        return true unless Input.key_push?(key_code)

      when :key_down
        key_code = options[:key_down_code] ? options[:key_down_code] : K_SPACE
        #キー押下があれば
        return true if Input.key_down?(key_code)

      when :not_key_down
        key_code = options[:key_down_code] ? options[:key_down_code] : K_SPACE
        #キー押下があれば
        return true unless Input.key_down?(key_code)

      #ユーザデータ確認系

      when :equal
        return unless options[:equal]
        #指定されたデータと値がイコールかどうか
        options[:equal].each do |key, val|
          return true if @root_control.send(args_name)[key] == val
        end

      when :not_equal
        return unless options[:not_equal]
        #指定されたデータと値がイコールでない場合
        options[:not_equal].each do |key, val|
          return true if @root_control.send(args_name)[key] != val
        end

      when :null
        return unless options[:null]
        options[:null] = [options[:null]] unless options[:null].instance_of?(Array)
        #指定されたデータがnilの場合
        options[:null].each do |key|
          return true if @root_control.send(args_name)[key] == nil
        end

      when :not_null
        return unless options[:not_null]
        options[:not_null] = [options[:not_null]] unless options[:not_null].instance_of?(Array)
        #指定されたデータがnilで無い場合
        options[:not_null].each do |key|
          return true if @root_control.send(args_name)[key] != nil
        end

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
        send(variable.to_s)[key] = val
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
  def command__GET_(options, inner_options)
    if options[:_ARGUMENT_]
      variable = options[:_ARGUMENT_]
      options.delete(:_ARGUMENT_)
    else
      variable = nil
    end

    #オプション全探査
    options.each do |key, val|
      if variable
        if key == :_RESULT_
          @_RESULT_ = send(variable.to_s)[val]
        else
          @root_control._USER_DATA_[key] = send(variable.to_s)[val]
        end
      else
        if respond_to?(val.to_s)
          @root_control._USER_DATA_[key] = send(val.to_s)
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

  def command__WAIT_(options, inner_options)

    #チェック条件を満たしたら終了する
    return if check_imple(options[:_ARGUMENT_], options)

    if options[:count]
      options[:count] = options[:count] - 1
    end

    #フレーム終了疑似コマンドをスタックする
    eval_commands([[:_END_FRAME_, {}, {}]])

    #waitにブロックが付与されているならそれを実行する
    eval_block(options, inner_options[:block_stack], &inner_options[:block])

    push_command_to_next_frame(:_WAIT_, options, inner_options)
  end

  def command__CHECK_(options, inner_options)
    #チェック条件を満たさない場合
    if check_imple(options[:_ARGUMENT_], options)
      #checkにブロックが付与されているならそれを実行する
      eval_block(options, &inner_options[:block])
      return
    end
  end

  #繰り返し
  def command__WHILE_(options, inner_options)
    #チェック条件を満たさないなら終了する
    return unless check_imple(options[:_ARGUMENT_], options)

    interrupt_command([:_END_LOOP_, options, inner_options])

    #while文全体をスクリプトストレージにスタック
    eval_commands([[:_WHILE_, options, inner_options]])
    #ブロックを実行時評価しコマンド列を生成する。
    eval_block(options, &inner_options[:block])
  end

  def command__BREAK_(options, inner_options)
    #_END_LOOP_タグが見つかるまで@command_listからコマンドを取り除く
    #_END_LOOP_タグが見つからない場合は@command_listを空にする
    until @command_list.empty? do
      break if @command_list.shift[0] == :_END_LOOP_
    end
  end

  def command__RETURN_(options, inner_options)
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
  def command__DEFINE_(options, inner_options)
    @function_list[options[:_ARGUMENT_]] = inner_options[:block]
  end

  #関数呼び出し
  def command__CALL_(options, inner_options)
    #関数名に対応する関数ブロックを取得する
    function_block =  @function_list[options[:_ARGUMENT_]] || 
                      @root_control.function_list[options[:_ARGUMENT_]]
      
    #定義されていないfunctionが呼びだされたら例外を送出
    raise NameError, "undefined local variable or command or function `#{options[:_ARGUMENT_]}' for #{inner_options}" unless function_block
    
    #伝搬されているブロックがある場合
    if inner_options[:block_stack]
      block_stack = inner_options[:block_stack].dup
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

    interrupt_command([:_END_FUNCTION_, options, inner_options])

    #functionを実行時評価しコマンド列を生成する。
    eval_block(options, block_stack, &function_block)
  end

  #関数ブロックを実行する
  #TODO:この実装だと_YIELD_自身にはブロックを付与できないが、それは良いのか？
  def command__YIELD_(options, inner_options)
    return unless inner_options[:block_stack]

    block_stack = inner_options[:block_stack].dup
    block = block_stack.pop
    block_stack = nil if block_stack.empty?

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

    #デフォルト指定があるならターゲットのコントロールを差し替える
    if options[:default]
      raise unless @root_control.default_control[options[:default]]
      options[:_ARGUMENT_] = @root_control.default_control[options[:default]]
    end

    unless options[:_ARGUMENT_]
      if options[:interrupt]
        base_control.interrupt_command([:_SCOPE_, {}, inner_options])
      else
        base_control.push_command([:_SCOPE_, {}, inner_options])
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
        control.interrupt_command([:_SCOPE_, {}, inner_options])
      else
        control.push_command([:_SCOPE_, {}, inner_options])
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

  #データセーブ
  #TODO：保存先パスや名称は将来的には外部から与えるようにしたい
  def command__SAVE_(options, inner_options)
    #グローバルデータ
    if options[:_ARGUMENT_] == 0
      db = PStore.new(@_GLOBAL_DATA_[:_SAVE_DATA_PATH_] + 
                      @_GLOBAL_DATA_[:_GLOBAL_DATA_FILENAME_])
      db.transaction do
        db["key"] = @root_control._GLOBAL_DATA_
      end
    #ユーザーデータ
    #任意の接尾字を指定する
    elsif options[:_ARGUMENT_]
      db = PStore.new(@_GLOBAL_DATA_[:_SAVE_DATA_PATH_] + 
                      options[:_ARGUMENT_].to_s +
                      @_GLOBAL_DATA_[:_USER_DATA_FILENAME_])
      db.transaction do
        db["key"] = @root_control._USER_DATA_
      end
    else
      #セーブファイル指定エラー
      pp "対象セーブファイルが指定されていません"
      raise 
    end
  end

  def command__LOAD_(options, inner_options)
    #グローバルデータ
    if options[:_ARGUMENT_] == 0
      db = PStore.new(@_GLOBAL_DATA_[:_SAVE_DATA_PATH_] + 
                      @_GLOBAL_DATA_[:_GLOBAL_DATA_FILENAME_])
      db.transaction do
        @root_control._GLOBAL_DATA_ = db["key"]
      end
    #ユーザーデータ
    #任意の接尾字を指定する
    elsif options[:_ARGUMENT_]
      db = PStore.new(@_GLOBAL_DATA_[:_SAVE_DATA_PATH_] + 
                      options[:_ARGUMENT_].to_s +
                      @_GLOBAL_DATA_[:_USER_DATA_FILENAME_])
      db.transaction do
        @root_control._USER_DATA_ = db["key"]
      end
    else
      #セーブファイル指定エラー
      pp "対象セーブファイルが指定されていません"
      raise 
    end
  end

  def command__QUICK_SAVE_(options, inner_options)
    command_list = []
    #子コントロールのシリアライズコマンドを取得
    @control_list.each do |control|
      command_list.push(control.siriarize)
    end

  
    db = PStore.new(@_GLOBAL_DATA_[:_SAVE_DATA_PATH_] + 
                    options[:_ARGUMENT_].to_s +
                    @_GLOBAL_DATA_[:_QUICK_DATA_FILENAME_])

    db.transaction do
      db["key"] = Marshal.dump(command_list)
    end
  end

  def command__QUICK_LOAD_(options, inner_options)
    db = PStore.new(@_GLOBAL_DATA_[:_SAVE_DATA_PATH_] + 
                    options[:_ARGUMENT_].to_s +
                    @_GLOBAL_DATA_[:_QUICK_DATA_FILENAME_])

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
  def command__SCOPE_(options, inner_options)
    interrupt_command([:_END_FUNCTION_, options, inner_options])
    eval_block(options, options[:blcok_stack], &inner_options[:block])
  end

  #ループの終点を示す
  def command__END_LOOP_(options, inner_options)
  end

  #ファンクションの終点を示す
  def command__END_FUNCTION_(options, inner_options)
  end
  
  #フレームの終了を示す（ダミーコマンド。これ自体は実行されない）
  def command__END_FRAME_(options, inner_options)
    raise
  end
end
