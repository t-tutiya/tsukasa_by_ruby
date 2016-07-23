#! ruby -E utf-8

require 'pstore'
require "tmpdir"

###############################################################################
#TSUKASA for DXRuby ver1.2.1(2016/5/2)
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

  attr_reader :id
  attr_reader :child_index
  attr_accessor :child_update  #子コントロールの更新可否
end

class Control #内部メソッド

  def initialize(options, yield_block_stack, root_control, parent_control, &block)
    @child_update = true

    #rootコントロールの保存
    @root_control = root_control
    #親コントロールの保存
    @parent_control = parent_control
    # ユーザ定義関数
    @function_list = {} 
    #コントロールのID(省略時は自身のクラス名とする)
    @id = options[:id] || self.class.name.to_sym

    #コマンドリスト
    @command_list = [] 

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

  def update(mouse_pos_x, mouse_pos_y, index)
    @child_index = index

    #コマンドリストが空になるまで走査し、コマンドを実行する
    until @command_list.empty?
      #コマンドリストの先頭要素を取得
      command_name, argument, options, yield_block_stack, block = @command_list.shift

      #今フレーム処理終了判定
      break if command_name == :_END_FRAME_

      #コマンドを実行する
      exec_command(command_name, argument, options, yield_block_stack,&block)
    end

    #子コントロールを更新しない場合は処理を終了
    return 0, 0 unless @child_update

    child_index = 0

    #下位コントロール巡回
    @control_list.delete_if do |child_control|
      #下位コントロールを自ターゲットに直接描画
      child_dx, child_dy = child_control.update(
                            mouse_pos_x, mouse_pos_y, child_index)
      #マウス座標のオフセットを更新する
      mouse_pos_x -= child_dx
      mouse_pos_y -= child_dy
      child_index += 1

      #コントロールの削除チェック
      child_control.delete?
    end

    return 0, 0
  end

  #描画
  def render(offset_x, offset_y, target)
    #下位コントロール巡回
    @control_list.each do |child_control|
      #下位コントロールを自ターゲットに直接描画
      child_dx, child_dy = child_control.render(offset_x, offset_y, target)
      #次のコントロールの描画座標原点を設定する
      offset_x += child_dx
      offset_y += child_dy
    end
    #オフセット値を返す
    return 0, 0
  end

  def find_control(id)
    #idがnilであれば自身を返す
    return self unless id
    #整数であれば子要素の添え字と見なす
    return @control_list[id] if id.instance_of?(Fixnum)
    #_ROOT_：ルートコントロール
    return @root_control if id == :_ROOT_
    #_PARENT_：親コントロール
    return @parent_control if id == :_PARENT_
    #直下の子コントロールを探査して返す。存在しなければnil
    return @control_list.find {|control| control.id == id }
  end

  def find_control_path(control_path)
    control = self
    Array(control_path).each do |control_id|
      control = control.find_control(control_id)
      break unless control
    end

    #候補が見つからなかった場合
    unless control
      warn "コントロール\"#{control_path}\"は存在しません"
    end
    
    return control
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
                      &block
                    )
    @command_list = command_list + @command_list
  end

  #コマンドの実行
  def exec_command(command_name, argument, options, yield_block_stack, &block)

    #コマンドがメソッドとして存在する場合
    if self.respond_to?(command_name, true)
      #コマンドを実行する
      send(command_name, argument, options, yield_block_stack, &block)
      return
    end

    #関数名に対応する関数ブロックを取得する
    function_block =  @function_list[command_name] || 
                      @root_control.function_list[command_name]

    #ユーザー定義コマンドが存在しない場合、コマンド送信文であるとみなす
    unless function_block
      raise(TsukasaError, "コマンド[#{command_name}]はコントロールに登録されていません")
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

  def check_imple(argument, options, yield_block_stack)
    options.each do |condition, value|
      return unless value

      case condition

      #count数が０以下の場合
      when :count
        return true if value <= 0

      #指定ＩＤの子コントロールが存在する
      when :child_exist
        Array(value).each do |id|
          return true if find_control(id)
        end

      #指定ＩＤの子コントロールが存在しない
      when :child_not_exist
        Array(value).each do |id|
          return true unless find_control(id)
        end

      #キーが押下された
      when :key_push
        Array(value).each do |key_code|
          return true if DXRuby::Input.key_push?(key_code)
        end

      #キーが押下されていない
      when :not_key_push
        Array(value).each do |key_code|
          return true unless DXRuby::Input.key_push?(key_code)
        end

      #キーが継続押下されている
      when :key_down
        Array(value).each do |key_code|
          return true if DXRuby::Input.key_down?(key_code)
        end

      #キーが継続押下されていない
      when :not_key_down
        Array(value).each do |key_code|
          return true unless DXRuby::Input.key_down?(key_code)
        end

      #キーが解除された
      when :key_up
        Array(value).each do |key_code|
          return true if DXRuby::Input.key_release?(key_code)
        end

      #キーが解除されていない
      when :not_key_up
        Array(value).each do |key_code|
          return true unless DXRuby::Input.key_release?(key_code)
        end

      #パッドボタン処理系

      when :pad_down
        Array(value).each do |pad_code|
          return true if DXRuby::Input.pad_down?(pad_code,
                                        @root_control._SYSTEM_[:_PAD_NUMBER_])
        end

      when :pad_push
        Array(value).each do |pad_code|
          return true if DXRuby::Input.pad_push?(pad_code,
                                        @root_control._SYSTEM_[:_PAD_NUMBER_])
        end

      when :pad_release
        Array(value).each do |pad_code|
          return true if DXRuby::Input.pad_release?(pad_code,
                                        @root_control._SYSTEM_[:_PAD_NUMBER_])
        end

      #ユーザデータ確認系

      #指定されたデータと値がイコールかどうか
      when :equal
        value.each do |key, val|
          if argument
            #データストアとの比較
            return true if @root_control.send(argument)[key] == val
          else
            #コントロールプロパティとの比較
            return true if send(key) == val
          end
        end

      #指定されたデータと値がイコールでない場合
      when :not_equal
        value.each do |key, val|
          if argument
            #データストアとの比較
            return true if @root_control.send(argument)[key] != val
          else
            #コントロールプロパティとの比較
            return true if send(key) != val
          end
        end

      #指定されたデータと値が未満かどうか
      when :under
        value.each do |key, val|
          if argument
            #データストアとの比較
            return true if @root_control.send(argument)[key] < val
          else
            #コントロールプロパティとの比較
            return true if send(key) < val
          end
        end

      #指定されたデータと値がより大きいかどうか
      when :over
        value.each do |key, val|
          if argument
            #データストアとの比較
            return true if @root_control.send(argument)[key] > val
          else
            #コントロールプロパティとの比較
            return true if send(key) > val
          end
        end

      #指定されたデータがnilの場合
      when :null
        value.each do |key|
          if argument
            #データストアとの比較
            return true if @root_control.send(argument)[key] == nil
          else
            #コントロールプロパティとの比較
            return true if send(key) == nil
          end
        end

      #指定されたデータがnilで無い場合
      when :not_null
        value.each do |key|
          if argument
            #データストアとの比較
            return true if @root_control.send(argument)[key] != nil
          else
            #コントロールプロパティとの比較
            return true if send(key) != nil
          end
        end

      when :system
        Array(value).each do |key|
          case key
          #ウィンドウの閉じるボタンが押下された場合
          when :requested_close
            return true if DXRuby::Input.requested_close?
          when :mouse_push
            return true if DXRuby::Input.mouse_push?( M_LBUTTON )
          when :mouse_down
            return true if DXRuby::Input.mouse_down?( M_LBUTTON )
          when :mouse_up
            return true if DXRuby::Input.mouse_release?( M_LBUTTON )
          when :right_mouse_down
            return true if DXRuby::Input.mouse_down?( M_RBUTTON )
          when :right_mouse_push
            return true if DXRuby::Input.mouse_push?( M_RBUTTON )
          when :right_mouse_up
            return true if DXRuby::Input.mouse_release?( M_RBUTTON )
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
  #コントロールをリストに登録する
  def _CREATE_(argument, options, yield_block_stack, &block)
    begin 
    #コントロールを生成して子要素として登録する
    @control_list.push(Tsukasa.const_get(argument).new(options, 
                                                      yield_block_stack, 
                                                      @root_control, 
                                                      self, 
                                                      &block)
    )
    rescue NameError
      raise(TsukasaError, "コントロール[#{argument}]の生成に失敗しました。")
    end
  end

  #disposeコマンド
  #コントロールを削除する
  def _DELETE_(argument, options, yield_block_stack)
    #コントロールを検索する
    control = find_control_path(argument)

    #削除フラグを立てる
    control.dispose() if control
  end
end

class Control #セッター／ゲッター
  #コントロールのプロパティを更新する
  def _SET_(argument, options, yield_block_stack)
    #オプション全探査
    options.each do |key, val|
      #データストアが設定されている場合
      if argument
        #指定データストアのキーに値を代入する
        @root_control.send(argument.to_s)[key] = val
      else
        #セッターが存在する場合
        if  respond_to?(key.to_s + "=")
          #コントロールプロパティに値を代入
          send(key.to_s + "=", val)
        else
          #warningを出して処理を続行する
          warn  "クラス[#{self.class}]：変数[" + "@#{key}]は存在しません"
        end
      end
    end
  end

  #コントロールのプロパティを更新する
  def _SET_OFFSET_(argument, options, yield_block_stack)
    #オプション全探査
    options.each do |key, val|
      #データストアが設定されている場合
      if argument
        #指定データストアのキーに値をオフセット値を加算して代入
        @root_control.send(argument.to_s)[key] += val
      else
        #セッターが存在する場合
        if  respond_to?(key.to_s + "=")
          #コントロールプロパティに値をオフセット加算して代入
          send(key.to_s + "=", send(key.to_s) + val)
        else
          #warningを出して処理を続行する
          warn  "クラス[#{self.class}]：変数[" + "@#{key}]は存在しません"
        end
      end
    end
  end

  #指定したコントロール(orデータストア)のプロパティを取得する
  def _GET_(argument, options, yield_block_stack, &block)
    result = {}

    #オプション全探査
    Array(argument).each do |property|
      #データストアが設定されている場合
      if options[:datastore]
        #データストアから値を取得する
        result[property] = @root_control.send(options[:datastore])[property]
      else
        if respond_to?(property.to_s)
          #コントロールプロパティから値を取得する
          result[property] = send(property)
        else
          warn  "クラス[#{self.class}]：変数[" + "@#{property}]は存在しません"
        end
      end
    end

    #ブロックを実行する
    parse_block(nil, result, yield_block_stack, &block)
  end
end

class Control #制御構文
  def _WAIT_(argument, options, yield_block_stack, &block)

    #チェック条件を満たしたら終了する
    return if check_imple(argument, options, yield_block_stack)

    if options[:count]
      options[:count] = options[:count] - 1
    end

    @command_list.unshift([:_WAIT_, argument, options, yield_block_stack, block])
    #現在のループ終端を挿入
    @command_list.unshift([:_END_LOOP_])

    #フレーム終了疑似コマンドをスタックする
    @command_list.unshift(:_END_FRAME_)

    if block
      #ブロックが付与されているならそれを実行する
      parse_block(argument, options, yield_block_stack, &block)
    end
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
    #現在のループ終端を挿入
    @command_list.unshift([:_END_LOOP_])
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

    @command_list.push([:_END_LOOP_])
    #リストの末端に自分自身を追加する
    @command_list.push([:_STACK_LOOP_, argument, options, yield_block_stack, block])
  end

  def _NEXT_(argument, options, yield_block_stack, &block)
    #_END_LOOP_タグが見つかるまで@command_listからコマンドを取り除く
    #_END_LOOP_タグが見つからない場合は@command_listを空にする
    until @command_list.empty? do
      break if @command_list.shift[0] == :_END_LOOP_ 
    end

    if block
      #ブロックが付与されているならそれを実行する
      parse_block(argument, options, yield_block_stack, &block)
    end

    #第１引数で指定されているコマンドを実行する
    if argument
      exec_command(argument, nil, nil, yield_block_stack)
    end
  end

  def _BREAK_(argument, options, yield_block_stack, &block)
    #_END_LOOP_タグが見つかるまで@command_listからコマンドを取り除く
    #_END_LOOP_タグが見つからない場合は@command_listを空にする
    until @command_list.empty? do
      if @command_list.shift[0] == :_END_LOOP_ 
        @command_list.shift #_LOOP_をpopする
        break 
      end
    end

    if block
      #ブロックが付与されているならそれを実行する
      parse_block(argument, options, yield_block_stack, &block)
    end

    #第１引数で指定されているコマンドを実行する
    if argument
      exec_command(argument, nil, nil, yield_block_stack)
    end
  end

  def _RETURN_(argument, options, yield_block_stack, &block)
    #_END_FUNCTION_タグが見つかるまで@command_listからコマンドを取り除く
    #_END_FUNCTION_タグが見つからない場合は@command_listを空にする
    until @command_list.empty? do
      break if @command_list.shift == :_END_FUNCTION_
    end

    if block
      #ブロックが付与されているならそれを実行する
      parse_block(argument, options, yield_block_stack, &block)
    end

    #第１引数で指定されているコマンドを実行する
    if argument
      exec_command(argument, nil, nil, yield_block_stack)
    end
  end
end

class Control #ユーザー定義関数操作
  #ユーザー定義コマンドを定義する
  def _DEFINE_(argument, options, yield_block_stack, &block)
    @function_list[argument] = block
  end

  #ユーザー定義コマンドの別名を作る
  def _ALIAS_(argument, options, yield_block_stack, &block)
    @function_list[options[:new]] = @function_list[options[:old]]
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
  #子コントロールを検索してコマンドブロックを送信する
  def _SEND_(argument, options, yield_block_stack, &block)
    #コントロールを検索する
    control = find_control_path(argument)
    return unless control

    #インタラプト指定されている
    if options[:interrupt]
      #子コントロールのコマンドリスト先頭に挿入
      control._SCOPE_(nil, options, yield_block_stack, &block)
    else
      #子コントロールのコマンドリスト末端に挿入
      control.push_command(:_SCOPE_, nil, options, yield_block_stack, block)
    end
  end

  #直下の子コントロール全てにコマンドを送信する
  def _SEND_ALL_(argument, options, yield_block_stack, &block)
    #子コントロール全てを探査対象とする
    @control_list.each do |control|
      next if argument and (control.id != argument)
      control._SEND_(nil, options, yield_block_stack, &block)
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
    options[:path] = File.expand_path(argument)

    #強制フラグが無く、一度_INCLUDE_しているファイルなら終了
    if !(options[:force]) and 
        @root_control._TEMP_[:_LOADED_FEATURES_].index(options[:path])
      return
    end

    #ファイルパスをリストに追加する。
    @root_control._TEMP_[:_LOADED_FEATURES_].push(options[:path])

    #拡張子取得
    ext_name = File.extname(options[:path])
    #rbファイルでなければparserのクラス名を初期化する。
    unless ext_name == ".rb"
      ext_name.slice!(0)
      options[:parser] = ext_name.to_sym
    end

    begin
      #スクリプトをパースする
      _PARSE_(File.read(options[:path], encoding: "UTF-8"),
                      options, 
                      yield_block_stack)
    rescue Errno::ENOENT
      raise(TsukasaLoadError.new(options[:path]))
    end
  end

  #スクリプトをパースする
  def _PARSE_(argument, options, yield_block_stack)
    options[:path] = "(parse)" unless options[:path]

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
                      options[:path],
                      yield_block_stack, 
                    )
    @command_list = command_list + @command_list
  end

  #アプリを終了する
  def _EXIT_(argument, options, yield_block_stack)
    @root_control.close
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
  def _QUICK_SAVE_(argument, options, yield_block_stack)
    raise unless argument.kind_of?(Numeric)

    command_list = []

    @control_list.each do |control|
      command_list.push(control.serialize())
    end

    db = PStore.new(@root_control._SYSTEM_[:_SAVE_DATA_PATH_] + 
                    argument.to_s +
                    @root_control._SYSTEM_[:_QUICK_DATA_FILENAME_])

    db.transaction do
      db["key"] = Marshal.dump(command_list)
    end
  end

  def _QUICK_LOAD_(argument, options, yield_block_stack)
    raise unless argument.kind_of?(Numeric)
    db = PStore.new(@root_control._SYSTEM_[:_SAVE_DATA_PATH_] + 
                    argument.to_s +
                    @root_control._SYSTEM_[:_QUICK_DATA_FILENAME_])

    db.transaction do
      command_list = Marshal.load(db["key"])
      @command_list = command_list + @command_list
    end

  end

end

class Control #内部コマンド
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
    options[:_OPTION_] =  {} unless options[:_OPTION_]
    options[:_OPTION_][:check] =  {} unless options[:_OPTION_][:check]
    
    #現在の経過カウントを初期化
    unless options[:_OPTION_][:check][:count]
      options[:_OPTION_][:check][:count] = argument 
    end

    #条件が成立した場合
    return if check_imple(options[:_OPTION_][:datastore], options[:_OPTION_][:check], yield_block_stack)

    #カウントダウン
    options[:_OPTION_][:check][:count] -= 1

    # Easingパラメータが設定されていない場合は線形移動を設定
    unless options[:_OPTION_][:easing]
      options[:_OPTION_][:easing] = :liner 
    end
    #指定されたeasingオプションが存在しない場合は線形移動を設定
    unless EasingProcHash[options[:_OPTION_][:easing]]
      warn "easingオプション#{EasingProcHash[options[:_OPTION_][:easing]]}は設定されていません"
      options[:_OPTION_][:easing] = :liner 
    end

    options.each do |key, index|
      next if key == :_OPTION_

      #開始値が設定されていなければ現在の値で初期化
      unless options[key].instance_of?(Array)
        #オフセットオプションが設定されている場合
        if options[:_OPTION_][:offset]
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
                EasingProcHash[options[:_OPTION_][:easing]].call(
                  (argument - options[:_OPTION_][:check][:count]).fdiv(argument)
              )
            ).to_i)
    end

    @command_list.unshift([:_MOVE_, argument, options, yield_block_stack, block])

    #現在のループ終端を挿入
    @command_list.unshift([:_END_LOOP_])
    #フレーム終了疑似コマンドをスタックする
    @command_list.unshift([:_END_FRAME_])

    if block
      #ブロックが付与されているならそれを実行する
      parse_block(argument, options, yield_block_stack, &block)
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
  def _PATH_(argument, options, yield_block_stack, &block)
    raise unless argument #必須要素

    #オプションハッシュの初期化
    options[:_OPTION_] =  {} unless options[:_OPTION_]
    options[:_OPTION_][:check] =  {} unless options[:_OPTION_][:check]

    #現在の経過カウントを初期化
    unless options[:_OPTION_][:check][:count]
      options[:_OPTION_][:check][:count] = argument 
    end

    #条件判定が存在し、かつその条件が成立した場合
    return if check_imple(nil, options[:_OPTION_][:check], yield_block_stack)

    options[:_OPTION_][:check][:count] -= 1

    options[:_OPTION_][:type] = :spline unless options[:_OPTION_][:type]

    options.each do |key, values|
      next if key == :_OPTION_

      #Ｂスプライン補間時に始点終点を通らない
      step =(values.size - 1).fdiv(argument) * (argument - options[:_OPTION_][:check][:count])

      result = 0.0

      #全ての座標を巡回し、それぞれの座標についてstep量に応じた重み付けを行い、その総和を現countでの座標とする
      values.size.times do |index|
        case options[:_OPTION_][:type]
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

    @command_list.unshift([:_PATH_, argument, options, yield_block_stack, block])

    #現在のループ終端を挿入
    @command_list.unshift([:_END_LOOP_])
    #フレーム終了疑似コマンドをスタックする
    @command_list.unshift([:_END_FRAME_])

    if block
      #ブロックが付与されているならそれを実行する
      parse_block(argument, options, yield_block_stack, &block)
    end
  end

  #３次Ｂスプライン重み付け関数
  def b_spline_coefficent(t)
    t = t.abs

    # -1.0 < t < 1.0
    if t < 1.0 
      return (3.0 * t ** 3 - 6.0 * t ** 2 + 4.0) / 6.0

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

class Control #デバッグ支援機能
  def put_control_tree(space_count)
    space = ""
    space_count.times do
      space +="  "
    end
    puts space + "->" + @id.to_s + " [ " + self.class.to_s + " ]"
    space_count +=1
    @control_list.each do |control|
      control.put_control_tree(space_count)
    end
  end

  #コントロールツリーを出力する
  def _DEBUG_TREE_(argument, options, yield_block_stack)
    put_control_tree(0)
  end

  #プロパティの現在値を出力する
  def _DEBUG_PROP_(argument, options, yield_block_stack)
    methods.each do |method|
      method = method.to_s
      if method[-1] == "=" and not(["===", "==", "!="].index(method))
        puts method.chop! + " : " + send(method).to_s
      end
    end
  end

  def _DEBUG_TEMP_(argument, options, yield_block_stack)
    pp @root_control._TEMP_
  end

  def _DEBUG_LOCAL_(argument, options, yield_block_stack)
    pp @root_control._LOCAL_
  end

  def _DEBUG_SYSTEM_(argument, options, yield_block_stack)
    pp @root_control._SYSTEM_
  end

  #コマンドリストを出力する
  def _DEBUG_COMMAND_(argument, options, yield_block_stack)
    @command_list.each do |command|
      p command
    end
  end
end
