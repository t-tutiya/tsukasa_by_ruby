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
end

class Control
  include Resource
  @@function_list = {} #functionのリスト（procで保存される）
  @@root = nil

  def initialize(options, &block)
    @@root = self if !@@root #ルートコントロールを登録
    #描画関連
    #TODO;モジュールに全部送れないか検討
    @x_pos = 0
    @y_pos = 0
    @float_mode = options[:float_mode] || :none

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

    #Controlの可視フラグ
    @visible = options[:visible] == false ? false : true

    #コマンドに設定されているデフォルトの送信先クラスのIDディスパッチテーブル
    @control_default = {
      :CharContainer => :default_text_layer,
      :LayoutContainer => :default_layout_container,
      :Anonymous => :anonymous,
    }

    #子コントロールをentityに描画するかどうか
    @draw_to_entity = options[:draw_to_entity]

    @draw_option = {}          #描画オプション

    @draw_option[:z] = options[:index] || 0 #重ね合わせ順序

    #TODO：ここ統合できる筈。

    if options[:default_script_path]
      #デフォルトスクリプトの読み込み
      @script_storage += ScriptCompiler.new({:script_path => options[:default_script_path]}).commands
    end

    #スクリプトパスが設定されているなら読み込んで登録する
    if options[:script_path]
      #シナリオファイルの読み込み
      @script_storage += ScriptCompiler.new({:script_path => options[:script_path]}).commands
    end

    #ブロックが付与されているなら読み込んで登録する
    if block
      @script_storage = ScriptCompiler.new(options, &block).commands
    end

    #コマンドセットがあるなら登録する
    eval_commands(options[:commands]) 

    send_command(:token, nil)

    #初期ブロックを実行する
    update()
  end

  #コマンドをスタックに格納する
  def send_command(command, options, target_id = @id, invoker_control = self)
    #自身が送信対象として指定されている場合
    if @id == target_id or target_id == :anonymous
      #コマンドをスタックの末端に挿入する
      @command_list.push([command, options, invoker_control])
      return true #コマンドをスタックした
    end

    #子要素に処理を伝搬する
    @control_list.each do |control|
      #子要素がコマンドをスタックした時点でループを抜ける
      return true if control.send_command(command, options, target_id, invoker_control)
    end

    return false #コマンドをスタックしなかった
  end

  #コマンドをスタックに格納する
  def send_command_interrupt(command, options, target_id = @id, invoker_control = self)
    #自身が送信対象として指定されている場合
    #TODO：or以降がアリなのか（これがないと子コントロール化にブロックを送信できない）
    if @id == target_id or target_id == :anonymous
      #コマンドをスタックの先頭に挿入する
      @command_list.unshift([command, options, invoker_control])
      return true #コマンドをスタックした
    end

    #子要素に処理を伝搬する
    @control_list.each do |control|
      #子要素がコマンドをスタックした時点でループを抜ける
      return true if control.send_command_interrupt(command, options, target_id,invoker_control)
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
      command, options, target = @command_list.shift

      #コマンドを実行
      end_parse, command = send("command_" + command.to_s, options, target)

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

  #描画
  def render(offset_x, offset_y, target)

    return offset_x, offset_y unless @visible

    offset_x = offset_y = 0 if @draw_to_entity

    #子要素のコントロールの描画
    #TODO:内部でif分岐してるのはおかしい
    @control_list.each do |entity|
      #所持コントロール自身に描画する場合
      if @draw_to_entity
        #子要素を自ターゲットに一時描画
        offset_x, offset_y = entity.render( offset_x, offset_y, @entity) 
      else
        #子要素を親ターゲットに直接描画
        offset_x, offset_y = entity.render( offset_x + @x_pos, 
                                            offset_y + @y_pos, target)
      end
    end

    dx = offset_x + @x_pos
    dy = offset_y + @y_pos

    #自コントロールが描画要素を持っている場合ターゲットに描画
    target.draw_ex(dx, dy, @entity, @draw_option) if @entity

    #連結指定チェック
    case @float_mode
    #右連結
    when :right
      return dx + @width, 
             dy
    #下連結
    when :bottom
      return dx,
             dy + @height
    #連結解除
    when :none
      return 0, 0
    end

    raise
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
  def eval_block(options, block)
    eval_commands(ScriptCompiler.new(options, &block).commands)
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
  def command_create(options, target)

    #コントロールを生成して子要素として登録する
    @control_list.push(Module.const_get(options[:create]).new(options, &options[:block]))

    return :continue
  end

  #disposeコマンド
  #コントロールを削除する
  def command_dispose(options, target)
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

  #スクリプトストレージから取得したコマンドをコントロールツリーに送信する
  def command_token(options, target)
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
    temp = @script_storage.shift
    command = temp[0]     #コマンド名（シンボル）

    #TODO：このdupが本当に必要なのか良く分からない
    options = temp[1].dup #オプション群。状態を持ちうるので複製する
    system_options = temp[2] #システムで使用するオプション群
    
    #送信先ターゲットIDが設定されていない場合
    if system_options[:target_id] == nil
      #デフォルトクラス名からIDを取得する
      target = @control_default[system_options[:default_class]]
    else
      #スクリプトで設定されたターゲットIDを使用する
      target = system_options[:target_id]
    end

    #yield_blockが存在する場合、それをオプション引数に格納する
    #TODO:ユーザー定義引数名との衝突回避方法検討
    options[:yield_block] = system_options[:yield_block]

    #コマンドをコントロールに登録する
    if !send_command( command, 
                      options, 
                      target) then
      pp "error"
      pp command
      pp options
      pp @id
      pp target
#      pp @control_list
      pp command.to_s + "コマンドは伝搬先が見つかりませんでした"
      raise
    end

    send_command(:token, nil)
    return :continue
  end

  #文字列を評価する（デバッグ用）
  def command_eval(options, target)
    eval(options[:eval])
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

  #強制的に１フレーム進めるコマンド
  def command_next_frame(options, target)
    return :end_frame
  end

  #skip_modeコマンド
  #スキップモードの更新
  def command_skip_mode(options, target)
    #スキップモードの更新
    @skip_mode = options[:skip_mode]
    return :continue
  end

  def command_skip_mode_all(options, target)
    #スリープモードを解除する
    @@root.send_command_interrupt_to_all(:skip_mode, 
                                        {:skip_mode => options[:skip_mode_all]})
    return :continue
  end

  #sleep_modeコマンド
  #スリープモードの更新
  def command_sleep_mode(options, target)
    #スリープ状態を更新
    @sleep_mode = options[:sleep_mode] 
    return :continue
  end

  def command_sleep_mode_all(options, target)
    #スリープモードを解除する
    @@root.send_command_interrupt_to_all(:sleep_mode, 
                                        {:sleep_mode => options[:sleep_mode_all]})
    return :continue
  end

  def command_wait(options, target)
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
          @@root.send_command_interrupt_to_all(:skip_mode, {:skip_mode => true})

          return :continue 
        else
          @idle_mode = false
        end

      when :skip
        #スキップモードであれば終了
        return :continue if @skip_mode
      end
    end

    return :end_frame, [:wait, options]
  end

  def command_check_key_push(options, target)
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
  def command_event(options, target)
    @event_list[options[:event]] = options[:block]
    return :continue
  end

  #イベントの実行
  def command_fire(options, target)
    #キーが登録されていないなら終了
    return :continue if !@event_list[options[:fire]]

    eval_block(options, @event_list[options[:fire]])

    return :continue
  end

  #############################################################################
  #スタック操作関連
  #############################################################################

  #関数を定義する
  def command_define(options, target)
    @@function_list[options[:define]] = options[:block]
    return :continue
  end

  def command_call_function(options, target)
    #定義されていないfunctionが呼びだされたら例外を送出
    raise NameError, "undefined local variable or command or function `#{options[:call_function]}' for #{target}" unless @@function_list.key?(options[:call_function])

    #関数ブロックを引数に登録する
    options[:yield_block] = options[:block]
    #不要なコマンドブロックを削除
    options[:block] = nil

    #functionを実行時評価しコマンド列を生成する。
    eval_block(options, @@function_list[options[:call_function]])

    return :continue
  end

  #ブロック内のコマンド列を実行する
  def command_about(options, target)
    #コマンドリストをスタックする
    eval_block(options, options[:block])
    return :continue
  end

  #############################################################################
  #分類未決定
  #############################################################################

  #フラグを設定する
  def command_flag(options, target)
    #ユーザー定義フラグを更新する
    @@global_flag[("user_" + options[:key].to_s).to_sym] = options[:data]
    return :continue
  end

  #コマンド送信先ターゲットのデフォルトを変更する
  def command_change_default_target(options, target)
    @control_default[options[:change_default_target]] = options[:id]
    return :continue
  end


  #次に読み込むスクリプトファイルのパスを設定する
  def command_next_scenario(options, target)
    @next_script_file_path = options[:next_scenario]
    return :continue
  end
  
  #スクリプトファイルの読み込み
  def command_load_script(options, target)
    #指定されたスクリプトファイルを直接読み込む
    #TODO：@script_storageに上書きするのか、追記するのかはオプションで指定できた方が良いか？　その
    @script_storage = ScriptCompiler.new({:script_path => options[:load_script]}).commands
    return :continue
  end
  
end


class Control #旧仕様。廃棄予定

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #############################################################################
  #ヘルパーメソッド
  #############################################################################

  #文字列をbool型に変換
  def object_to_boolean(value)
    return [true, "true", 1, "1", "T", "t"].include?(value.class == String ? value.downcase : value)
  end

  #"RRGGBB"の１６進数６桁カラー指定を、[R,G,B]の配列に変換
  def hex_to_rgb(target)
    return target if target.class == Array
    [target[0, 2].hex, target[2, 2].hex, target[4, 2].hex]
  end

  #タグの必須属性の有無をチェックし、無ければtrueを返す
  def check_exist(target, *attributes)
    if !target
      puts "オプションが空です"
      return true
    end
    attributes.each do |attribute|
      if !target.key?(attribute)
        puts "属性値\"#{attribute.to_s}\"は必須です"
        return true
      end
    end
    return false
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
  def command_IF(options, target)
    #条件式を評価し、結果をoptionsに再格納する
    if eval_lambda(options[:IF], options)
      result = :then
    else
      result = :else
    end

    #if文の中身を実行する
    eval_block(options, options[:block])

    return :continue, [:exp_result, { :result => result}]
  end

  #thenコマンド
  def command_THEN(options, target)
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }
    
    #結果がthenの場合
    if result and @next_frame_commands[result][1][:result] == :then
      #コマンドブロックを実行する
      eval_block(options, options[:block])
    end

    return :continue
  end

  #elseコマンド
  def command_ELSIF(options, target)
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }

    #結果がelseの場合
    if result and @next_frame_commands[result][1][:result] == :else
      #ラムダ式が真の場合
      if eval_lambda(options[:ELSIF], options)
        #コマンドブロックを実行する
        eval_block(options, options[:block])
        #処理がこれ以上伝搬しないように評価結果をクリアする
        #TODO：コマンド自体を削除した方が確実
        @next_frame_commands[result][1][:result] = nil
      end
    end
    
    return :continue
  end

  #elseコマンド
  def command_ELSE(options, target)
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }

    #結果がelseの場合
    if result and @next_frame_commands[result][1][:result] == :else
      #コマンドブロックを実行する
      eval_block(options, options[:block])
    end
    return :continue
  end

  #１フレ分のみifの結果をコマンドリスト上に格納する
  def command_exp_result(options, target)
    return :continue
  end

  #関数ブロックを実行する
  def command_YIELD(options, target)
    return :continue if !options[:yield_block]
    eval_block(options, options[:yield_block])
    return :continue
  end

  #繰り返し
  def command_WHILE(options, target)
    #条件式が非成立であれば繰り返し構文を終了する
    return :continue if !eval_lambda(options[:WHILE], options) #アイドル

    #while文全体をスクリプトストレージにスタック
    eval_commands([[:WHILE, options, {target_id: @id}]])
    #ブロックを実行時評価しコマンド列を生成する。
    eval_block(options, options[:block])

    return :continue
  end

  def command_CASE(options, target)
    #比較元のオブジェクトを評価する
    value = eval_lambda(options[:CASE], options)

    #case文の中身を実行する
    eval_block(options, options[:block])

    return :continue, [:exp_result, { :result => :else,
                                      :case_value => value}]
  end

  def command_WHEN(options, target)
    #条件式評価結果を取得する（ネスト対応の為に逆順に探査する）
    result = @next_frame_commands.rindex{|command|
      command[0] == :exp_result
    }

    #評価結果が存在しなければ処理を終了する
    return :continue unless result

    exp_result = @next_frame_commands[result][1]

    if exp_result[:case_value] == eval_lambda(options[:WHEN], options)
      #コマンドブロックを実行する
      eval_block(options, options[:block])
    end

    return :continue
  end
end



#未分類
class Control

  def command_visible(options, target)
    @visible = options[:visible]
    return :continue
  end


end
