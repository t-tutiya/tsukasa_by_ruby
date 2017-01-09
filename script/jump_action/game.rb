#操作キャラコントロールの読み込みと生成
require "./script/jump_action/imple.rb"

_SEND_ :base do
  _SET_ path: "./resource/bg_sample.png"
end


_CREATE_ :DrawableLayout, x: 160, y: 120, width: 320, height: 256 do
  _CREATE_ :TileMap,
    width: 1024, height: 1024,
    size_x: 17, size_y:16,
    map_array: [[1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
          [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 1],
          [1, 0, 0, 1, 1, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 1],
          [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1],
          [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1],
          [1, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 1],
          [1, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 1],
          [1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1],
          [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1],
          [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1],
          [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1],
          [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1],
          [1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1],
          [1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1],
          [1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1]] do
    _SET_TILE_ 0, path: "./script/jump_action/blue.png"
    _SET_TILE_ 1, path: "./script/jump_action/blown.png"
    _SET_TILE_ 2, path: "./script/jump_action/white.png"

  end
  #キャラの生成
  _CREATE_ :MainChar, id: :main_char, width:32, height:32, color: C_RED, x:32, y:32 do
    #※コマンド定義にはコントロール内とグローバル空間の２種類のスコープがあります
    #横移動
    _DEFINE_ :state_x_move do

      #横キー入力判定
      _GET_ [:x, :y], control: [:_ROOT_, :_INPUT_] do |x:, y:|
        pad_x = x
        _GET_ :x do |x:|
          #Ｘ方向の増分を加算
          _SET_ x: x + pad_x * 4
        end
      end

      _ADDJUST_WALL_
    end

    _GET_ :y do |y:|
      #前フレームのY座標を保存
      _SET_ [:_ROOT_, :_TEMP_], y_prev: y, f: 1
    end
    #通常ステート開始
    state_fall
  end
  state_scroll
end

_DEFINE_ :state_scroll do

  _GET_ [:x, :y], control: :main_char do |x:, y:|
    ox = oy = 0
    #画面端であればオフセットを固定し、そうでなければオフセットを設定する
    case x
    when 0..128-1 #画面左端
      ox = 0
    when 128..352-1
      ox = x - 128
    when 352..544 #画面右端
      ox = 352-128
    end

    case y
    when 0..64-1 #画面上端
      oy = 0
    when 64..288-1
      oy = y - 64
    when 288..448 #画面下端
      oy = 288-64
    end

    _SET_ relative_x: ox, relative_y: oy
  end

  _END_FRAME_
  _RETURN_ do
    state_scroll
  end
end

#通常ステート
_DEFINE_ :state_normal do

  #スペースキー入力判定
  _CHECK_INPUT_ key_push: K_SPACE do
    #※_RETURN_の付与ブロックは、コマンドを抜けた後で実行されます。継続(continution)的な挙動になり、シーン（ステート）遷移に使えます
    _RETURN_ do
      #※ブロック内に複数のコマンドを記述できるので、下記のように複数のステートの順番を指定することもできます。
      state_jump #ジャンプステートに遷移
      state_fall #落下ステートに遷移
    end
  end

  #フレームを終了する
  _END_FRAME_

  _RETURN_ do
    state_x_move #Ｘ方向移動ステートに遷移
    state_fall #落下ステートに遷移
  end
end

#ジャンプステート
_DEFINE_ :state_jump do
  #ジャンプ係数を初期化
  _SET_ [:_ROOT_, :_TEMP_], f: -15

  _GET_ :y do |y:|
    #前フレームのY座標を保存
    _SET_ [:_ROOT_, :_TEMP_], y_prev: y
  end
end

_DEFINE_ :state_fall do
  _GET_ [[:f, [:_ROOT_, :_TEMP_]], [:y_prev, [:_ROOT_, :_TEMP_]], :y] do |f:, y_prev:, y:|
    #前フレームのＹ座標を保存＆ジャンプ係数の初期化
    _SET_ [:_ROOT_, :_TEMP_], f: 1, y_prev: y
    #Ｙ軸移動増分の設定
    y_move = (y - y_prev) + f
    #座標増分を加算。増分が31を越えていれば強制的に31とする
    y += y_move <= 31 ? y_move : 31
    #Ｙ座標の更新
    _SET_ y: y
  end

  #マップ外落下判定
  _CHECK_ over: {y:480} do
    _SET_ x: 32, y: 0
    _SET_ [:_ROOT_, :_TEMP_], y_prev: 0
  end

  #着地補正
  _CHECK_LANDING_ do
    _RETURN_ do
      state_normal #通常ステートに遷移
    end
  end

  #天井衝突補正
  _ADDJUST_ROOF_

  #フレームを終了する
  _END_FRAME_

  _RETURN_ do
    state_x_move #Ｘ方向移動ステートに遷移
    state_fall #落下ステートに再遷移
  end
end

_WAIT_