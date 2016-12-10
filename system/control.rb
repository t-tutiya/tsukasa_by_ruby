#! ruby -E utf-8

require 'pstore'
require "tmpdir"

#キーコード定数／パッド定数／マウスボタン定数
require_relative './Constant.rb'
#例外（TskasaError）
require_relative './Exception.rb'
#スクリプトコンパイラ
require_relative './ScriptCompiler.rb'

###############################################################################
#TSUKASA for DXRuby ver2.0(2016/8/28)
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

module Tsukasa

class Control #公開インターフェイス
  #プロセスのカレントディレクトリを保存する
  @@system_path = File.expand_path('../../', __FILE__)

  attr_accessor :id
  attr_reader :child_index
  attr_accessor :child_update  #子コントロールの更新可否
  attr_reader  :function_list #ユーザー定義関数

  #rootコントロールになった場合のみ使用
  attr_reader :script_compiler #スクリプトコンパイラ
  attr_accessor :script_parser #スクリプトパーサ
  attr_accessor :exit #終了

  def initialize( options = {}, 
                  yield_stack = nil, 
                  root_control = nil, 
                  parent_control = nil, 
                  &block)
    @child_update = true

    if root_control
      #rootコントロールの保存
      @root_control = root_control
      #親コントロールの保存
      @parent_control = parent_control
      #終了フラグを初期化
      @exit = false
    else
      #rootコントロールの保存
      @root_control = self
      #親コントロールの保存
      @parent_control = self
      #パーサー
      @script_compiler = ScriptCompiler.new
      @script_parser = {}
    end

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
      parse_block(options, yield_stack, &block)
    end

    #コマンドセットがあるなら登録する（シリアライズなどで使用）
    if options[:command_list]
      @command_list = options[:command_list] + @command_list
    end

  end

  #コマンドをスタックに格納する
  def push_command(command, options, yield_stack, block)
    #コマンドをスタックの末端に挿入する
    @command_list.push([command, options, yield_stack, block])
  end

  def update(mouse_pos_x, mouse_pos_y, index)
    @child_index = index

    #コマンドリストが空になるまで走査し、コマンドを実行する
    until @command_list.empty?
      #コマンドリストの先頭要素を取得
      command_name, options, yield_stack, block = @command_list.shift

      #今フレーム処理終了判定
      break if command_name == :_END_FRAME_

      #コマンドを実行する
      exec_command(command_name, options, yield_stack, &block)
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

  def serialize()
    options = {}

    #自コントロールのプロパティを取得
    methods.each do |method|
      method = method.to_s
      if method[-1] == "=" and not(["===", "==", "!="].index(method))
        options[method.chop!.to_sym] = send(method)
      end
    end

    command_list = [[:_SET_, options, {}]]

    #子コントロールのシリアライズコマンドを取得
    @control_list.each do |control|
      result = [:_CREATE_,
                {
                  _ARGUMENT_: control.class.name,
                  command_list: control.serialize()
                },{}]
      command_list.push(result)
    end

    return command_list
  end
end

class Control #判定系
  def check_eaual(property, value)
    return send(property) == value
  end
  def check_not_eaual(property, value)
    return send(property) != value
  end
  def check_under(property, value)
    return send(property) < value
  end
  def check_over(property, value)
    return send(property) > value
  end
end

class Control #内部メソッド

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #rubyブロックのコマンド列を配列化してスクリプトストレージに積む
  def parse_block(options, yield_stack, &block)
    command_list = @root_control.script_compiler.eval_block(
                      options, 
                      yield_stack, 
                      &block
                    )
    @command_list = command_list + @command_list
  end

  #コマンドの実行
  def exec_command(command_name, options, yield_stack, &block)
    #コマンドがメソッドとして存在する場合
    if self.respond_to?(command_name, true)
      #コマンドを実行する
      send(command_name, yield_stack, options, &block)
      return
    end

    #関数名に対応する関数ブロックを取得する
    function_block =  @function_list[command_name] || 
                      @root_control.function_list[command_name]

    #ユーザー定義コマンドが存在しない場合、コマンド送信文であるとみなす
    unless function_block
      raise(Tsukasa::TsukasaError, "コマンド[#{command_name}]はコントロールに登録されていません")
    end

    #参照渡し汚染が起きないようにディープコピーで取得
    yield_stack = yield_stack ? yield_stack.dup : []
    #スタックプッシュ
    yield_stack.push(block)
    #終端コマンドを挿入
    @command_list.unshift(:_END_FUNCTION_)

    #functionを実行時評価しコマンド列を生成する。
    parse_block(options, yield_stack, &function_block)
  end
end

class Control #コントロールの生成／破棄
  #コントロールをリストに登録する
  def _CREATE_(yield_stack, _ARGUMENT_:, **options, &block)
    begin 
    #コントロールを生成して子要素として登録する
    @control_list.push(
      Tsukasa.const_get(_ARGUMENT_).new(options, 
                                        yield_stack, 
                                        @root_control, 
                                        self, 
                                        &block)
    )
    rescue NameError
      raise(Tsukasa::TsukasaError, "コントロール[#{_ARGUMENT_}]の生成に失敗しました。")
    end
  end

  #コントロールを削除する
  def _DELETE_(yield_stack, _ARGUMENT_: nil)
    #コントロールを検索する
    control = find_control_path(_ARGUMENT_)

    #削除フラグを立てる
    control.dispose() if control
  end

  #プロパティを動的に追加する
  def _DEFINE_PROPERTY_(yield_stack, options)
    #ハッシュを巡回
    options.each do |key, value|
      #インスタンス変数を動的に生成し、値を設定する
      instance_variable_set('@' + key.to_s, value)
      
      #ゲッターメソッドを動的に生成する
      singleton_class.send( :define_method, 
                            key,
                            lambda{ 
                              instance_variable_get('@' + key.to_s) 
                            })
      
      #セッターメソッドを動的に生成する
      singleton_class.send( :define_method, 
                            key.to_s + '=', 
                            lambda{ |set_value| 
                              instance_variable_set('@' + key.to_s, set_value) 
                            })
    end
  end
end

class Control #セッター／ゲッター
  #コントロールのプロパティを更新する
  def _SET_(yield_stack, _ARGUMENT_: nil, **options)
    #オプション全探査
    options.each do |key, val|
      begin
        #コントロールプロパティに値を代入
        find_control_path(_ARGUMENT_).send(key.to_s + "=", val)
      rescue
        warn  "クラス[#{self.class}]：変数[" + "@#{key}]は存在しません"
      end
    end
  end

  #指定したコントロール(orデータストア)のプロパティを取得する
  def _GET_(yield_stack, _ARGUMENT_:, control: nil, &block)
    result = {}

    #オプション全探査
    Array(_ARGUMENT_).each do |property|
      property = Array(property)
      #取得先コントロールパスが指定されていなければcontrolに準じる
      property[1] = control unless property[1]
      #格納名が指定されていなければpropetyに準じる
      property[2] = property[0] unless property[2]
      begin
        #コントロールプロパティから値を取得する
        result[property[2]] = find_control_path(property[1]).send(property[0])
      rescue
        warn  "クラス[#{self.class}]：変数[" + "@#{property}]は存在しません"
      end
    end

    #ブロックを実行する
    parse_block(result, yield_stack, &block)
  end
end

class Control #制御構文
  #条件判定
  def _CHECK_(yield_stack, _ARGUMENT_: nil, **options, &block)
    #比較対象とするコントロールを取得する
    control = find_control_path(_ARGUMENT_)

    # 全ての条件を判定する
    result = options.any? do |condition, value|
      case condition
      #指定されたデータと値がイコールの場合
      when :equal
        value.any?{|key, val| control.check_eaual(key, val)}
      #指定されたデータと値がイコールでない場合
      when :not_equal
        value.any?{|key, val| control.check_not_eaual(key, val)}
      #指定されたデータと値が未満の場合
      when :under
        value.any?{|key, val| control.check_under(key, val)}
      #指定されたデータと値がより大きい場合
      when :over
        value.any?{|key, val| control.check_over(key, val)}
      else
        false
      end
    end

    #チェック条件を満たす場合
    if result
      #ブロックを実行する
      parse_block(nil, yield_stack, &block)
    end
  end


  def _CHECK_BLOCK_(yield_stack, options, &block)
    unless yield_stack[-1] == nil
      #条件が成立したらブロックを実行する
      parse_block(nil, yield_stack, &block)
    end
  end

  #繰り返し
  def _LOOP_(yield_stack, _ARGUMENT_: nil, &block) 
    if _ARGUMENT_
      _ARGUMENT_ = Array(_ARGUMENT_)
      
      #現在の経過カウントを初期化
      _ARGUMENT_[1] ||= 0
      #カウントが終了しているならループを終了する
      return if _ARGUMENT_[0] == _ARGUMENT_[1]
      #カウントアップ
      _ARGUMENT_[1] += 1

      args = {end: _ARGUMENT_[0], now: _ARGUMENT_[1]}
    else
      args = nil
    end

    #リストの先端に自分自身を追加する
    @command_list.unshift([:_LOOP_, {_ARGUMENT_: _ARGUMENT_}, yield_stack, block])
    #現在のループ終端を挿入
    @command_list.unshift([:_END_LOOP_])
    #ブロックを実行時評価しコマンド列を生成する。
    parse_block(args, yield_stack,&block)
  end

  def _NEXT_(yield_stack, _ARGUMENT_: nil, &block)
    #_END_LOOP_タグが見つかるまで@command_listからコマンドを取り除く
    #_END_LOOP_タグが見つからない場合は@command_listを空にする
    until @command_list.empty? do
      break if @command_list.shift[0] == :_END_LOOP_ 
    end

    if block
      #ブロックが付与されているならそれを実行する
      parse_block(nil, yield_stack, &block)
    end
  end

  def _BREAK_(yield_stack, _ARGUMENT_: nil, &block)
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
      parse_block(nil, yield_stack, &block)
    end
  end

  def _RETURN_(yield_stack, _ARGUMENT_: nil, &block)
    #_END_FUNCTION_タグが見つかるまで@command_listからコマンドを取り除く
    #_END_FUNCTION_タグが見つからない場合は@command_listを空にする
    until @command_list.empty? do
      break if @command_list.shift == :_END_FUNCTION_
    end

    if block
      #ブロックが付与されているならそれを実行する
      parse_block(nil, yield_stack, &block)
    end
  end
end

class Control #ユーザー定義関数操作
  #ユーザー定義コマンドを定義する
  def _DEFINE_(yield_stack, _ARGUMENT_:, &block)
    @function_list[_ARGUMENT_] = block
  end

  #ユーザー定義コマンドの別名を作る
  def _ALIAS_(yield_stack, new:, old:, &block)
    @function_list[new] = @function_list[old]
  end

  #関数ブロックを実行する
  def _YIELD_(yield_stack, options)
    new_yield_stack = yield_stack.dup
    yield_block = new_yield_stack.pop
    raise unless yield_block

    parse_block(options, new_yield_stack, &yield_block)
  end
end

class Control #スクリプト制御
  #カスタムパーサーの登録
  def _SCRIPT_PARSER_(yield_stack, path:, ext_name:, parser:)
    require_relative path
    @root_control.script_parser[ext_name] = [
      Module.const_get(parser).new,
      Module.const_get(parser)::Replacer.new]
  end

  #ネイティブコードを読み込む
  def _LOAD_NATIVE_(yield_stack, _ARGUMENT_:)
    require _ARGUMENT_
  end

  #子コントロールを検索してコマンドブロックを送信する
  def _SEND_(yield_stack, _ARGUMENT_: nil, interrupt: nil, **options, &block)
    #コントロールを検索する
    control = find_control_path(_ARGUMENT_)
    return unless control

    #インタラプト指定されている
    if interrupt
      #子コントロールのコマンドリスト先頭に挿入
      control._SCOPE_(yield_stack, options, &block)
    else
      #子コントロールのコマンドリスト末端に挿入
      control.push_command(:_SCOPE_, options, yield_stack, block)
    end
  end

  #直下の子コントロール全てにコマンドを送信する
  def _SEND_ALL_(yield_stack, _ARGUMENT_: nil, **options, &block)
    #子コントロール全てを探査対象とする
    @control_list.each do |control|
      next if _ARGUMENT_ and (control.id != _ARGUMENT_)
      control._SEND_(yield_stack, options, &block)
    end
  end

  #スクリプトファイルを挿入する
  def _INCLUDE_(yield_stack, _ARGUMENT_:, path: nil, parser: nil, force: false, **)
    #プロセスのカレントディレクトリを強制的に更新する
    #TODO：Window.open_filenameが使用された場合の対策だが、他に方法はないか？
    FileUtils.chdir(@@system_path)
    #ファイルのフルパスを取得
    path = File.expand_path(_ARGUMENT_)
    #拡張子取得
    ext_name = File.extname(path)
    #rbファイルでなければparserのクラス名を初期化する。
    unless ext_name == ".rb"
      ext_name.slice!(0)
      parser = ext_name.to_sym
    end

    begin
      #スクリプトをパースする
      _PARSE_(yield_stack, 
        _ARGUMENT_: File.read(path, encoding: "UTF-8"),
        parser: parser
      )
    rescue Errno::ENOENT
      raise(Tsukasa::TsukasaLoadError.new(path))
    end
  end

  #スクリプトをパースする
  def _PARSE_(yield_stack, _ARGUMENT_:, path: nil, parser: nil, **)
    path = "(parse)" unless path

    #パーサーが指定されている場合
    if parser
      #文字列を取得して変換をかける
      _ARGUMENT_ =  @root_control.script_parser[parser][1].apply(
                      @root_control.script_parser[parser][0].parse(_ARGUMENT_)
                    )
    end

    #司スクリプトを評価してコマンド配列を取得し、コマンドリストの先頭に追加する
    command_list = @root_control.script_compiler.eval_commands(
                      _ARGUMENT_,
                      path,
                      yield_stack, 
                    )
    @command_list = command_list + @command_list
  end

  #アプリを終了する
  def _EXIT_(yield_stack, options)
    @root_control.exit = true
  end

  #文字列を評価する（デバッグ用）
  def _EVAL_(yield_stack, _ARGUMENT_:)
    eval(_ARGUMENT_)
  end

  #文字列をコマンドラインに出力する（デバッグ用）
  def _PUTS_(yield_stack, _ARGUMENT_: nil, **options)
    if _ARGUMENT_
      puts '"' + _ARGUMENT_.to_s + '"'
    else
      puts options.to_s
    end
  end
end

class Control #セーブデータ制御
  def _SERIALIZE_(yield_stack, _ARGUMENT_: nil, &block)
    #第一引数が設定されている
    if _ARGUMENT_
      #デシリアライズする（コマンドリストが挿し変わる）
      @command_list = _ARGUMENT_
    else
      #シリアライズし、ブロックに渡す
      parse_block({command_list: serialize()}, yield_stack, &block)
    end
  end
end

class Control #内部コマンド
  #ブロックを実行する。無名関数として機能する
  def _SCOPE_(yield_stack, options, &block)
    #関数の終端を設定
    @command_list.unshift(:_END_FUNCTION_)

    #参照渡し汚染が起きないようにディープコピーで取得
    yield_stack = yield_stack ? yield_stack.dup : []

    #関数を展開する
    parse_block(options, yield_stack, &block)
  end

  #ファンクションの終点を示す
  def _END_LOOP_(yield_stack, options)
  end

  #ファンクションの終点を示す
  def _END_FUNCTION_(yield_stack, options)
  end
  
  #フレームの終了を示す（ダミーコマンド。これ自体は実行されない）
  def _END_FRAME_(yield_stack, options)
    raise
  end
end

class Control #プロパティのパラメータ遷移

  def _MOVE_(yield_stack, _ARGUMENT_:, **options, &block)
    _ARGUMENT_ = Array(_ARGUMENT_)
    # Easingパラメータが設定されていない場合は線形移動を設定
    _ARGUMENT_[1] ||= :liner
    #現在の経過カウントを初期化
    _ARGUMENT_[2] ||= 0
    #カウントが終了しているならループを終了する
    return if _ARGUMENT_[0] == _ARGUMENT_[2]
    #カウントアップ
    _ARGUMENT_[2] += 1

    options.each do |key, value|
      #値を更新する
      send(key.to_s + "=", 
        (value[0] + (value[1] - value[0]).to_f * 
          EasingProcHash[_ARGUMENT_[1]].call(_ARGUMENT_[2].fdiv(_ARGUMENT_[0]))
        ).to_i
      )
    end

    options[:_ARGUMENT_] = _ARGUMENT_
    @command_list.unshift([:_MOVE_, options, yield_stack, block])

    #現在のループ終端を挿入
    @command_list.unshift([:_END_LOOP_])
    #フレーム終了疑似コマンドをスタックする
    @command_list.unshift([:_END_FRAME_])

    if block
      #ブロックが付与されているならそれを実行する
      parse_block({end: _ARGUMENT_[0], now: _ARGUMENT_[2]}, 
                  yield_stack,&block)
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
  def _PATH_(yield_stack, _ARGUMENT_:, **options, &block)
    _ARGUMENT_ = Array(_ARGUMENT_)
    #移動アルゴリズムの指定（初期値Ｂスプライン）
    _ARGUMENT_[1] ||= :spline
    #現在の経過カウントを初期化
    _ARGUMENT_[2] ||= 0
    #カウントが終了しているならループを終了する
    return if _ARGUMENT_[0] == _ARGUMENT_[2]
    #カウントアップ
    _ARGUMENT_[2] += 1

    options.each do |key, value|
      #Ｂスプライン補間時に始点終点を通らない
      step =(value.size - 1).fdiv(_ARGUMENT_[0]) * (_ARGUMENT_[2])

      result = 0.0

      #全ての座標を巡回し、それぞれの座標についてstep量に応じた重み付けを行い、その総和を現countでの座標とする
      value.size.times do |index|
        case _ARGUMENT_[1]
        when :spline
          coefficent = b_spline_coefficent(step - index)
        when :line
          coefficent = line_coefficent(step - index)
        else
          raise
        end

        result += value[index] * coefficent
      end

      #移動先座標の決定
      send(key.to_s + "=", result.round)
    end

    options[:_ARGUMENT_] = _ARGUMENT_
    @command_list.unshift([:_PATH_, options, yield_stack, block])

    #現在のループ終端を挿入
    @command_list.unshift([:_END_LOOP_])
    #フレーム終了疑似コマンドをスタックする
    @command_list.unshift([:_END_FRAME_])

    if block
      #ブロックが付与されているならそれを実行する
      parse_block({end: _ARGUMENT_[0], now: _ARGUMENT_[2]}, 
                  yield_stack, &block)
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
  def _DEBUG_TREE_(yield_stack, options)
    put_control_tree(0)
  end

  #プロパティの現在値を出力する
  def _DEBUG_PROP_(yield_stack, options)
    methods.each do |method|
      method = method.to_s
      if method[-1] == "=" and not(["===", "==", "!="].index(method))
        puts method.chop! + " : " + send(method).to_s
      end
    end
  end

  #コマンドリストを出力する
  def _DEBUG_COMMAND_(yield_stack, options)
    @command_list.each do |command|
      p command
    end
  end
end

end
