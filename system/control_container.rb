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

class Control
  @@root = nil        #コントロールツリーのルート
  @@global_flag = {}  #グローバルフラグ
  @@procedure_list = Hash.new #プロシージャーのリスト
  @@ailias_list =  Hash.new #エイリアスのリスト

  def initialize(options)
    #ルートクラスの設定
    @@root = self if !@@root

    #描画関連
    #TODO;モジュールに全部送れないか検討
    @x_pos = 0
    @y_pos = 0
    @float_mode = options[:float_mode] || :none

    #コントロールのID(省略時は自身のクラス名とする)
    @id = options[:id] || ("Anonymous_" + self.class.name).to_sym

    @script_storage       = Array.new #スクリプトストレージ
    @script_storage_stack = Array.new #コールスタック

    @command_list       = Array.new #コマンドリスト
    @command_list_stack = Array.new #コールスタック

    @control_list = Array.new #コントロールリスト

    @event_list = Hash.new #イベントリスト

    @next_frame_commands =  Array.new  #一時コマンドリスト

    @skip_mode = false #スキップモードの初期化
    @idol_mode = true #待機モードの初期化

    @sleep_mode = :wake #スリープの初期状態を設定する

    @delete_flag = false #削除フラグの初期化
    
    #Controlの可視フラグ
    @visible = options[:visible] == false ? false : true

    #子コントロールをentityに描画するかどうか
    @draw_to_entity = options[:draw_to_entity]
    
    @draw_option = {} #描画オプション

    #スクリプトパスが設定されているなら読み込んで登録する
    if options[:script_path]
      #シナリオファイルの読み込み
      @script_storage = Tsukasa::ScriptCompiler.new(options[:script_path])
    end

    #コマンドセットがあるなら登録する
    if options[:commands]
      eval_block(options[:commands]) 
    end

    send_command(:token, nil)

    #初期ブロックを実行する
    update()
  end

  #コマンドをスタックに格納する
  def send_command(command, options, id = @id, base_control = self)
    #自身が送信対象として指定されている場合
    if @id == id or id == :anonymous
      #コマンドをスタックの末端に挿入する
      options = {} if !options
      options[:base_control] = base_control
      @command_list.push([command, options, base_control])
      #pp "@id[" + @id.to_s + "]" + command.to_s
      return true #コマンドをスタックした
    end

    #子要素に処理を伝搬する
    @control_list.each do |control|
      #子要素がコマンドをスタックした時点でループを抜ける
      return true if control.send_command(command, options, id, base_control)
    end

    return false #コマンドをスタックしなかった
  end

  #コマンドをスタックに格納する
  def send_command_interrupt(command, options, id = @id, base_control = self)
    #自身が送信対象として指定されている場合
    #TODO：or以降がアリなのか（これがないと子コントロール化にブロックを送信できない）
    if @id == id or id == :anonymous
      #コマンドをスタックの先頭に挿入する
      options = {} if !options
      options[:base_control] = base_control
      @command_list.unshift([command, options, base_control])
      return true #コマンドをスタックした
    end

    #子要素に処理を伝搬する
    @control_list.each do |control|
      #子要素がコマンドをスタックした時点でループを抜ける
      return true if control.send_command_interrupt(command, options, id,base_control)
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
=begin
    #コマンドリストが空で、かつ、コールスタックが空でない場合
    if @command_list.empty? and !@command_list_stack.empty?
      #コールスタックからネスト元のコマンドセットを取得する
      @command_list = @command_list_stack.pop
    end
=end
    #待機モードを初期化
    @idol_mode = true

    #コマンドリストが空になるまで走査し、コマンドを実行する
    while !@command_list.empty?
      #コマンドリストの先頭要素を取得
      command, options, target = @command_list.shift

      #コマンドを実行
      end_parse, command = send("command_" + command.to_s, options)

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
    base_offset_x = offset_x
    base_offset_y = offset_y

    child_offset_x = 0
    child_offset_y = 0
    
    #子要素のコントロールの描画
    #TODO:内部でif分岐してるのはおかしい
    @control_list.each do |entity|
      #所持コントロール自身に描画する場合
      if @draw_to_entity
        #子要素を自ターゲットに一時描画
        child_offset_x,child_offset_y = entity.render(child_offset_x, child_offset_y, @entity)
      else
        #子要素を親ターゲットに直接描画
        offset_x,offset_y = entity.render(offset_x + @x_pos, offset_y + @y_pos, target) if entity.visible
        if offset_x == :base and offset_y == :base
          offset_x = base_offset_x
          offset_y = base_offset_y
        end
      end
    end

    #自コントロールが描画要素を持っている場合
    if @entity
      #ターゲットに描画
      target.draw_ex( offset_x + @x_pos, 
                      offset_y + @y_pos, 
                      @entity, 
                      @draw_option) 
    end

    #連結指定チェック
    case @float_mode
    #右連結
    when :right
      result_x = offset_x + @width + @x_pos
      result_y = offset_y + @y_pos
    #下連結
    when :bottom
      result_x = offset_x + @x_pos
      result_y = offset_y + @height + @y_pos
    #連結解除
    when :none
      result_x = :base
      result_y = :base
    else
      raise
    end

    return result_x, result_y #引数を返値に伝搬する
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
  def all_controls_idol?
    @control_list.each do |control|
      @idol_mode &= control.all_controls_idol?
    end

    return @idol_mode
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
  
    #ブロック文の実行
  #TODO：単体コマンドとして実装すべき？
  def eval_block(block)
    #現在のスクリプトストレージをコールスタックにプッシュ
    @script_storage_stack.push(@script_storage) if !@script_storage.empty?
    #コマンドリストをクリアする
    @script_storage = block.dup
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
  def command_create(options)
    #指定されたコントロールを生成してリストに連結する
    @control_list.push(Module.const_get(options[:create]).new(options))
    return :continue
  end

  #disposeコマンド
  #コントロールを削除する
  def command_dispose(options)
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
  def command_token(options)
    #トークンの取得対象であるスクリプトストレージが空の場合
    if @script_storage.empty?
      #スクリプトストレージのコールスタックが存在する場合
      if !@script_storage_stack.empty?
        #コールスタックからスクリプトストレージをポップする
        @script_storage = @script_storage_stack.pop
      #次に読み込むスクリプトファイルが指定されている場合
      elsif @next_script_file_path
        #指定されたスクリプトファイルを読み込む
        @script_storage = Tsukasa::ScriptCompiler.new(@next_script_file_path)
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
    options = temp[1].dup #オプションは状態を持ちうるので複製する
    target = temp[2]
    
    #コマンドがプロシージャーリストに登録されている場合
    if @@procedure_list.key?(command)
      #プロシージャー名をオプションに格納する
      options[:procedure] = command
      target = @id
      #発行するコマンドをプロシージャー呼び出しに差し替える
      command = :call_procedure
    end

    #コマンドがエイリアスリストに登録されている場合
    if @@ailias_list.key?(command)
      @script_storage_stack.push(@script_storage)
      #コマンドリストをクリアする
      @script_storage = @@ailias_list[command].dup
      #コマンドを取り出す
      command,options  = @script_storage.shift
    end

    #コマンドをコントロールに登録する
    if !send_command(command,options,target) then
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
  def command_eval(options)
    eval(options[:eval])
    return :continue
  end

  #############################################################################
  #制御構文コマンド
  #############################################################################

  #条件分岐
  #TODO:コードが冗長
  def command_if(options)
    #evalで評価した条件式が真の場合
    if eval(options[:if])
      eval_block(options[:then])
    #else節がある場合
    elsif options[:else]
      eval_block(options[:else])
    end
    return :continue
  end

  #繰り返し
  def command_while(options)
    #条件式が非成立であれば繰り返し構文を終了する
    return :continue if !eval(options[:while]) #アイドル

    #while文全体をスクリプトストレージにスタック
    eval_block([[:while, options, @id]])
    #while文の中身をスクリプトストレージスタック
    eval_block(options[:commands])

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
  def command_next_frame(options)
    return :end_frame
  end

  #skip_modeコマンド
  #スキップモードの更新
  def command_skip_mode(options)
    #スキップモードの更新
    @skip_mode = options[:skip_mode]
    return :continue
  end

  def command_skip_mode_all(options)
    #スリープモードを解除する
    options[:base_control].send_command_interrupt_to_all(:skip_mode, 
                                        {:skip_mode => options[:skip_mode_all]})
    return :continue
  end

  #sleep_modeコマンド
  #スリープモードの更新
  def command_sleep_mode(options)
    #スリープ状態を更新
    @sleep_mode = options[:sleep_mode] 
    return :continue
  end

  def command_sleep_mode_all(options)
    #スリープモードを解除する
   options[:base_control].send_command_interrupt_to_all(:sleep_mode, 
                                        {:sleep_mode => options[:sleep_mode_all]})
    return :continue
  end

  #puaseコマンド
  #スキップ待機とキー入力待機
  def command_pause(options)
    #TODO:※ページスキップ的な機能が実装されたら、このへんでその処理を行う筈

    #■ルートの待機処理

    #スリープモードを設定
    send_command(:sleep_mode, {:sleep_mode => :sleep})
    #ウェイク待ち
    send_command(:wait_wake, nil)

    #■行表示中スキップ処理

    #idolになるかキー入力を待つ
    #※wait中にキーが押された場合、waitはスキップモードフラグを立てる
    send_command(:wait_key_push_with_idol, nil, :default_text_layer)
    #キー入力伝搬を止める為に１フレ送る
    send_command(:next_frame, nil, :default_text_layer)

    #■行末待機処理

    #キー入力があるまで待機
    send_command(:check_key_push,           nil, :default_text_layer)
    send_command(:wait_idol, nil, :default_text_layer)
    
    #■ポーズ終了処理
    
    #ルートにウェイクを送る
    #TODO：本来rootにのみ通知できれば良い筈
    send_command(:sleep_mode_all, {:sleep_mode_all => :wake}, :default_text_layer)
    #スキップフラグを下ろす
    send_command(:skip_mode_all, {:skip_mode_all => false},:default_text_layer)
    #スキップフラグ伝搬が正しく行われるように１フレ送る
    send_command(:next_frame, nil, :default_text_layer)

    return :continue
  end
end

class Control

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #キー入力を待つ
  def command_wait(options)
    #スキップモードであれば終了
    return :continue if @skip_mode

    #キー押下があれば終了
    if Input.key_push?(K_SPACE)
      return :continue 
    end

    #待ちフレーム数を取得。設定されていない場合はコンフィグから初期値を取得する
    #TODO:@style_config[:wait_frame]はchar特有のプロパティ
    wait_frame =  options[:wait] == :unset_wait_frame ?
                  @style_config[:wait_frame] :
                  options[:wait]

    #残りwaitフレーム数が０より大きい場合
    if 0 < wait_frame
      #残りwaitフレーム数をデクリメントし、:waitコマンドを再度スタックする
      return :end_frame, [:wait, {:wait => wait_frame - 1}]
    end

    return :continue
  end

  #wait_commandコマンド
  #特定のコマンドが自身より前に存在し続ける限り待機を続ける
  def command_wait_command(options)
    #指定されたコマンドが次フレ用に積まれている場合
    if @next_frame_commands.index{|command| 
          command[0] == options[:wait_command]
       }
      #自分自身をスタックし、コマンド探査を終了する
      return :end_frame, [:wait_command, options]
    else
      return :continue
    end
  end

  def command_wait_flag(options)
    flag = @@global_flag[("user_" + options[:wait_flag].to_s).to_sym]
    if flag == nil
      return :end_frame, [:wait_flag, options]
    else
      return :continue
    end
  end

  #wait_wake
  #覚醒待機状態
  def command_wait_wake(options)
    if @sleep_mode == :sleep
      return :end_frame, [:wait_wake, nil]
    end
    return :continue
  end

  #wait_idolコマンド
  #子要素のコントロールが全てアイドルになるまで待機
  def command_wait_idol(options, command_name = :wait_idol)
    if !all_controls_idol?
      return :end_frame, [command_name, options]
    end

    return :continue
  end

  def command_wait_key_push_with_idol(options)
    return :continue if all_controls_idol?
    #子要素のコントロールが全てアイドル状態の時にキーが押された場合
    if Input.key_push?(K_SPACE)
      #スキップフラグを立てる
      @@root.send_command_interrupt_to_all(:skip_mode, {:skip_mode => true})
      return :continue
    else
      @idol_mode = false
      #ポーズ状態を続行する
      return :end_frame, [:wait_key_push_with_idol, options]
    end
  end

  def command_check_key_push(options, command_name = :check_key_push)
    #子要素のコントロールが全てアイドル状態の時にキーが押された場合
    if Input.key_push?(K_SPACE)
      return :continue
    else
      @idol_mode = false
      #ポーズ状態を続行する
      return :continue, [command_name, options]
    end
  end
end

class Control

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #イベントコマンドの登録
  def command_event(options)
    #TODO：コマンドは追加にする
    @event_list[options[:event]] = options[:commands]
    return :continue
  end

  #イベントの実行
  def command_fire(options)
    #キーが登録されていないなら終了
    return :continue if !@event_list[options[:fire]]

    #コマンド列を格納する（インタラプトなので逆順にsendする）
    @event_list[options[:fire]].reverse_each do |command|
      send_command_interrupt(command[0], command[1])
    end

    return :continue
  end

  #############################################################################
  #スタック操作関連
  #############################################################################

  #プロシージャーを登録する
  def command_procedure(options)
    @@procedure_list[options[:procedure]] = options[:impl]
    return :continue
  end

  #プロシージャーコールを実行する
  def command_call_procedure(options)
    #現在のコマンドリストをスタック
    @command_list_stack.push(@command_list)
    #プロシージャの中身をevalでコマンドセット化してコマンドリストに登録する
    @command_list = eval(@@procedure_list[options[:procedure]])
    return :continue
  end

  #プロシージャーを登録する
  def command_ailias(options)
    @@ailias_list[options[:ailias]] = options[:commands]

    return :continue
  end

  #############################################################################
  #分類未決定
  #############################################################################

  #フラグを設定する
  def command_flag(options)
    #ユーザー定義フラグを更新する
    @@global_flag[("user_" + options[:key].to_s).to_sym] = options[:data]
    return :continue
  end

  #次に読み込むスクリプトファイルのパスを設定する
  def command_next_scenario(options)
    @next_script_file_path = options[:next_scenario]
    return :continue
  end
end


class Control

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
