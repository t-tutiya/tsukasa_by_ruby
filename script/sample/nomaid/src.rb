#! ruby -E utf-8

#メニューの選択肢ボタン
_DEFINE_ :menu_button do |id:, text:, y: |
  _TEXT_BUTTON_ text: text, 
    char_options: {font_name: "ＭＳＰ ゴシック"},
    id: id,
    width: 228, 
    height:32,
    y: y, 
    char_color: [255,255,0], #文字色
    out_color: [0,255,255] do
    #キーがクリックされた
    _DEFINE_ :on_key_push do
      _SET_ [:_ROOT_, :_TEMP_], flag: id
    end
  end
end

#アウトプットウィンドウ
_CREATE_ :Char, 
  id: :nomaid_comment_area,
  size: 32, 
  x: 64,
  y: 128,
  color:[255,255,0], 
  font_name: "ＭＳＰ ゴシック",
  char: nil

#ステータスウィンドウ作成用のヘルパーコマンド
_DEFINE_ :status_text do |id: nil, char: nil, x: 0|
  _CREATE_ :Char, 
    size: 32,
    id: id,
    x: x, 
    color:[255,255,0], 
    font_name: "ＭＳＰ ゴシック",
    char: char || nil
end

_DEFINE_ :set_status_window do
  #ステータスウィンドウ
  _CREATE_ :Layout,
    id: :status_window, 
    x: 32,
    y: 256,
    width: 1024,
    height: 192 do
    _CREATE_ :Layout, id: :line1, height: 42, y: 42 * 0 do
      status_text char: "第", x: 32 * 0
      status_text id: :week, x: 32 * 1
      status_text char: "週　第", x: 32 * 2
      status_text id: :day, x: 32 * 5
      status_text char: "日目　現在の所持金は＄", x: 32 * 6
      status_text id: :gold, x: 32 * 17
      status_text char: "。", x: 32 * 20
    end
    _CREATE_ :Layout, id: :line2, height: 42, y: 42 * 1 do
      status_text char: "借金の返済まであと", x: 32 * 0
      status_text id: :last_day, x: 32 * 9
      status_text char: "日。", x: 32 * 10
    end
    _CREATE_ :Layout, id: :line3, height: 42, y: 42 * 2 do
      status_text char: "今週の返済額は$", x: 32 * 0
      status_text id: :week_debt, x: 32 * 8
      status_text char: "で、あと$", x: 32 * 11
      status_text id: :week_debt_last_gold, x: 32 * 15
      status_text char: "必要だ。", x: 32 * 18
    end
    _CREATE_ :Layout, id: :line4, height: 42, y: 42 * 3 do
      status_text char: "＝＝＝＝"
    end
    _CREATE_ :Layout, id: :line5, height: 42, y: 42 * 4 do
      status_text char: "所持金：", x: 32 * 0
      status_text id: :gold, x: 32 * 4
      status_text char: "　ＨＰ：", x: 32 * 6
      status_text id: :helth_point, x: 32 * 9
      status_text char: "/", x: 32 * 11
      status_text id: :helth_point_max, x: 32 * 12
      status_text char: "　ＭＰ：", x: 32 * 14
      status_text id: :mental_point, x: 32 * 17
      status_text char: "/", x: 32 * 19
      status_text id: :mental_point_max, x: 32 * 20
    end
    _CREATE_ :Layout, id: :line6, height: 42, y: 42 * 5 do
      status_text char: "魅力：", x: 32 * 0
      status_text id: :charm, x: 32 * 3
      status_text char: "　気品：", x: 32 * 5
      status_text id: :noble, x: 32 * 9
      status_text char: "　教養：", x: 32 * 11
      status_text id: :culture, x: 32 * 15
    end
    _CREATE_ :Layout, id: :line7, height: 42, y: 42 * 6 do
      status_text char: "知性：", x: 32 * 0
      status_text id: :intelligence, x: 32 * 3
      status_text char: "　恭順：", x: 32 * 5
      status_text id: :allegiance, x: 32 * 9
      status_text char: "　礼節：", x: 32 * 11
      status_text id: :courtesy, x: 32 * 15
    end
    _DEFINE_ :update_status do
      _GET_ [ :week, 
              :day,
              :debt,
              :gold,
              :helth_point,
              :helth_point_max,
              :mental_point,
              :mental_point_max,
              :charm,
              :noble,
              :culture,
              :intelligence,
              :allegiance,
              :courtesy,
              ], control: [:_ROOT_, :_TEMP_] do |
              week:, 
              day:,
              debt:,
              gold:,
              helth_point:,
              helth_point_max:,
              mental_point:,
              mental_point_max:,
              charm:,
              noble:,
              culture:,
              intelligence:,
              allegiance:,
              courtesy:|

        _SEND_ :line1 do
          _SEND_(:day){_SET_ char: day + 1}
          _SEND_(:week){_SET_ char: week + 1}
          _SEND_(:gold){_SET_ char: gold}
        end

        _SEND_ :line2 do
          _SEND_(:last_day){_SET_ char: 7-day}
        end

        _SEND_ :line3 do
          _SEND_(:week_debt){_SET_ char: debt[week]}
          _SEND_(:week_debt_last_gold){_SET_ char: [debt[week] - gold, 0].max}
        end

        _SEND_ :line5 do
          _SEND_(:gold){_SET_ char: gold}
          _SEND_(:helth_point){_SET_ char: helth_point}
          _SEND_(:helth_point_max){_SET_ char: helth_point_max}
          _SEND_(:mental_point){_SET_ char: mental_point}
          _SEND_(:mental_point_max){_SET_ char: mental_point_max}
        end

        _SEND_ :line6 do
          _SEND_(:charm){_SET_ char: charm}
          _SEND_(:noble){_SET_ char: noble}
          _SEND_(:culture){_SET_ char: culture}
        end

        _SEND_ :line7 do
          _SEND_(:intelligence){_SET_ char: intelligence}
          _SEND_(:allegiance){_SET_ char: allegiance}
          _SEND_(:courtesy){_SET_ char: courtesy}
        end
      end
    end
  end
end

#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■メニュー
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

#トップメニュー
_DEFINE_ :top_menu do
  #メニュー押下フラグリセット
  _SET_ [:_ROOT_, :_TEMP_], flag: nil

  _CREATE_ :Layout, id: :top_menu, x:100, y:100 do
    menu_button text: "習い事をさせる", id: :lesson, y: 32 * 0
    menu_button text: "働かせる", id: :work, y: 32 * 1
    menu_button text: "休ませる", id: :rest, y: 32 * 2
  end

  _WAIT_ [:_ROOT_, :_TEMP_],  not_equal: {flag: nil}

  #メニューを削除する
  _SEND_ :top_menu  do
    _DELETE_
  end

  _CHECK_ [:_ROOT_, :_TEMP_], equal: {flag: :lesson} do
    lesson_menu
  end

  _CHECK_ [:_ROOT_, :_TEMP_], equal: {flag: :work} do
    work_menu
  end

  _CHECK_ [:_ROOT_, :_TEMP_], equal: {flag: :rest} do
    rest
  end

  #曜日終了確認
  _CHECK_ [:_ROOT_, :_TEMP_], equal: {end_day: true} do
    _RETURN_
  end
  
  #コマンド終了後、自分自身を再帰呼び出しする
  _RETURN_ do
    top_menu
  end
end

#「習い事をさせる」メニュー
_DEFINE_ :lesson_menu do
  _CREATE_ :Layout, id: :lesson_menu, x:100, y:100 do
    menu_button text: "礼拝", id: :pray, y: 32 * 0
    menu_button text: "学問", id: :academy, y: 32 * 1
    menu_button text: "舞踏", id: :dance, y: 32 * 2
    menu_button text: "礼儀作法", id: :courtesy, y: 32 * 3
    menu_button text: "戻る", id: :cancel, y: 32 * 4
  end

  _SET_ [:_ROOT_, :_TEMP_], flag: nil
  _WAIT_ [:_ROOT_, :_TEMP_],  not_equal: {flag: nil}

  #メニューを削除する
  _SEND_ :lesson_menu  do
    _DELETE_
  end

  #押されたのが「戻る」以外であれば、処理を実行して曜日終了フラグを立てる
  _CHECK_ [:_ROOT_, :_TEMP_], not_equal: {flag: :cancel} do
    _GET_ [ :mental_point_max, 
            :mental_point,
            :helth_point,
            :allegiance,
            :courtesy,
            :noble,
            :intelligence,
            :culture,
            :charm,
            ], control: [:_ROOT_, :_TEMP_] do 
          | mental_point_max:, 
            mental_point:,
            helth_point:,
            allegiance:,
            courtesy:,
            noble:,
            intelligence:,
            culture:,
            charm:|
    #礼拝
    _CHECK_ [:_ROOT_, :_TEMP_], equal: {flag: :pray} do 
      hp_cost = [(mental_point_max - mental_point) + 15, 
                 [helth_point - (mental_point_max - mental_point + 15),
                    helth_point].max].min
      mp_cost = [10, [mental_point - 10, mental_point].max].min
      _SET_ [:_ROOT_, :_TEMP_], 
        allegiance: allegiance + hp_cost / 2 + (mp_cost + courtesy) / 3,
        noble: noble + hp_cost / 2 + (mp_cost + intelligence) / 3,
        helth_point: helth_point - hp_cost,
        mental_point: mental_point - mp_cost
    end
    #勉学
    _CHECK_ [:_ROOT_, :_TEMP_], equal: {flag: :academy} do
      hp_cost = [(mental_point_max - mental_point) + 5, 
                 [helth_point - (mental_point_max - mental_point + 5),
                    helth_point].max].min
      mp_cost = [20, [mental_point - 20, mental_point].max].min
      _SET_ [:_ROOT_, :_TEMP_], 
        culture: culture + hp_cost / 2 + (mp_cost + courtesy) / 2,
        intelligence: intelligence + hp_cost / 2 + (mp_cost + intelligence) / 3,
        helth_point: helth_point - hp_cost,
        mental_point: mental_point - mp_cost
    end
    #舞踏
    _CHECK_ [:_ROOT_, :_TEMP_], equal: {flag: :dance} do
      hp_cost = [(mental_point_max - mental_point) + 20, 
                 [helth_point - (mental_point_max - mental_point + 20),
                    helth_point].max].min
      mp_cost = [15, [mental_point - 15, mental_point].max].min
      _SET_ [:_ROOT_, :_TEMP_], 
        charm: charm + hp_cost / 2 + (mp_cost + courtesy) / 2,
        noble: noble + hp_cost / 2 + (mp_cost + intelligence) / 2,
        helth_point: helth_point - hp_cost,
        mental_point: mental_point - mp_cost
    end
    #礼儀作法
    _CHECK_ [:_ROOT_, :_TEMP_], equal: {flag: :courtesy} do
      hp_cost = [(mental_point_max - mental_point) + 5, 
                 [helth_point - (mental_point_max - mental_point + 5),
                    helth_point].max].min
      mp_cost = [20, [mental_point - 20, mental_point].max].min
      _SET_ [:_ROOT_, :_TEMP_], 
        courtesy: courtesy + hp_cost / 2 + (mp_cost + courtesy) / 2,
        culture: culture + hp_cost / 2 + (mp_cost + intelligence) / 3,
        helth_point: helth_point - hp_cost,
        mental_point: mental_point - mp_cost
      end
    end

    _SEND_ [:_ROOT_], interrupt: true do
      _SEND_ :nomaid_comment_area do
        _SET_ char: "習い事によってメイドは少し成長した。"
      end
      _WAIT_ do
        _CHECK_INPUT_ mouse: :push do
          _BREAK_
        end
      end
      _SEND_ :nomaid_comment_area do
        _CLEAR_
      end
    end
    _SET_ [:_ROOT_, :_TEMP_], end_day: true
  end
end

#「働かせる」メニュー
_DEFINE_ :work_menu do
  _CREATE_ :Layout, id: :work_menu, x:100, y:100 do
    menu_button text: "清掃", id: :cleaning, y: 32 * 0
    menu_button text: "給仕", id: :waitress, y: 32 * 1
    menu_button text: "家庭教師", id: :tutor, y: 32 * 2
    menu_button text: "接待", id: :party, y: 32 * 3
    menu_button text: "戻る", id: :cancel, y: 32 * 4
  end
  _SET_ [:_ROOT_, :_TEMP_], flag: nil
  _WAIT_ [:_ROOT_, :_TEMP_],  not_equal: {flag: nil}

  #メニューを削除する
  _SEND_ :work_menu  do
    _DELETE_
  end

  #押されたのが「戻る」以外であれば、処理を実行して曜日終了フラグを立てる
  _CHECK_ [:_ROOT_, :_TEMP_], not_equal: {flag: :cancel} do
    _GET_ [ :mental_point_max, 
            :mental_point,
            :helth_point,
            :gold,
            :reward,
            :allegiance,
            :courtesy,
            :noble,
            :intelligence,
            :culture,
            :charm,
            ], control: [:_ROOT_, :_TEMP_] do 
          | mental_point_max:, 
            mental_point:,
            helth_point:,
            gold:,
            reward:,
            allegiance:,
            courtesy:,
            noble:,
            intelligence:,
            culture:,
            charm:|
      #清掃
      _CHECK_ [:_ROOT_, :_TEMP_], equal: {flag: :cleaning} do 
        hp_cost = [ mental_point_max - mental_point + 10, 
                    [ helth_point - mental_point_max - mental_point + 10,
                      helth_point].max].min
        mp_cost = [ 10, [ mental_point - 10, mental_point].max].min
        reward = 200 + (hp_cost * allegiance)/2 + (mp_cost * allegiance)/2

        _SET_ [:_ROOT_, :_TEMP_], allegiance: allegiance + hp_cost / 3 + mp_cost / 3,
                       helth_point: helth_point - hp_cost,
                       mental_point: mental_point - mp_cost,
                       gold: gold + reward,
                       reward: reward
      end

      #給仕
      _CHECK_ [:_ROOT_, :_TEMP_], equal: {flag: :waitress} do 
        hp_cost = [ mental_point_max - mental_point + 15, 
                    [ helth_point - mental_point_max - mental_point + 15,
                      helth_point].max].min
        mp_cost = [ 20, [ mental_point - 20, mental_point].max].min
        reward = hp_cost *((allegiance + courtesy + intelligence / 2) / 3)+
                 mp_cost * ((charm * 2 + intelligence) / 3)

        _SET_ [:_ROOT_, :_TEMP_], allegiance: allegiance += hp_cost / 3 + mp_cost / 3,
                        helth_point: helth_point - hp_cost,
                        mental_point: mental_point - mp_cost,
                        gold: gold + reward,
                        reward: reward
      end

      #家庭教師
      _CHECK_ [:_ROOT_, :_TEMP_], equal: {flag: :tutor} do 
        hp_cost = [ mental_point_max - mental_point + 25, 
                    [ helth_point - mental_point_max - mental_point + 25,
                      helth_point].max].min
        mp_cost = [ 40, [ mental_point - 40, mental_point].max].min
        reward = hp_cost * ((noble + courtesy + intelligence / 2) / 3) +
                 mp_cost * ((culture * 2 + intelligence * 2) / 3)

        _SET_ [:_ROOT_, :_TEMP_], helth_point: helth_point - hp_cost,
                        mental_point: mental_point - mp_cost,
                        gold: gold + reward,
                        reward: reward
      end

      #接待
      _CHECK_ [:_ROOT_, :_TEMP_], equal: {flag: :party} do 
        hp_cost = [ mental_point_max - mental_point + 30, 
                    [ helth_point - mental_point_max - mental_point + 30,
                      helth_point].max].min
        mp_cost = [ 30, [ mental_point - 30, mental_point].max].min
        reward =  hp_cost * ((allegiance * 2 + courtesy + intelligence/2)/2)+ 
                  mp_cost * ((culture / 2 + charm * 2 + noble * 2) / 3)

        _SET_ [:_ROOT_, :_TEMP_], helth_point: helth_point - hp_cost,
                        mental_point: mental_point - mp_cost,
                        gold: gold + reward,
                        reward: reward
      end
    end

    _SEND_ [:_ROOT_], interrupt: true  do
      _GET_ :reward, control: [:_ROOT_, :_TEMP_] do |reward:|
        _SEND_ :nomaid_comment_area do
          _SET_ char: "労働の対価として$#{reward}を得た。"
        end
      end
      _WAIT_ do
        _CHECK_INPUT_ mouse: :push do
          _BREAK_
        end
      end
      _SEND_ :nomaid_comment_area do
        _CLEAR_
      end
    end
    _SET_ [:_ROOT_, :_TEMP_], end_day: true
  end
end

#「休ませる」処理
_DEFINE_ :rest do
  _GET_ [ :helth_point, :mental_point], control: [:_ROOT_, :_TEMP_] do 
          |helth_point:, mental_point:|
    _SET_ [:_ROOT_, :_TEMP_], 
      helth_point: helth_point + [100 - helth_point, mental_point].min, 
      mental_point: mental_point + [100 - mental_point, 50].min
  end
  _SEND_ [:_ROOT_], interrupt: true  do
    _SEND_ :nomaid_comment_area do
      _SET_ char: "メイドはゆっくりと身体を休めた……。"
    end
      _WAIT_ do
        _CHECK_INPUT_ mouse: :push do
          _BREAK_
        end
      end
    _SEND_ :nomaid_comment_area do
      _CLEAR_
    end
  end
  _SET_ [:_ROOT_, :_TEMP_], end_day: true
end

#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■初期化処理
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

#ウィンドウのリサイズ
_RESIZE_ width: 800, height: 600

#パラメータ初期値を設定
_SET_ [:_ROOT_, :_TEMP_],
  debt: [1000, 2500, 5000, 10000, 25000, 50000, 100000],
  gold: 0,#所持金
  helth_point: 100, #生命力現在値
  helth_point_max: 100, #生命力
  mental_point: 100, #精神力現在値
  mental_point_max: 100, #精神力
  charm: 1, #魅力
  noble: 1, #気品
  culture: 1, #教養
  intelligence: 1, #知性
  allegiance: 1, #恭順
  courtesy: 1, #礼節
  day: 0,
  week: 0

#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■ＯＰシーン
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

#ＯＰ用テキストレイアウト指定
_SEND_(:text0){
  _SET_ x:32, y:32, width: 1024, height: 1024, size:24
}

#ＯＰ文字列表示
_INCLUDE_ "./script/sample/nomaid/op.tks"

#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■メインシーン
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

#テキストウィンドウクリア
_SEND_(:text0){
  _FLUSH_
}

#ステータスウィンドウ表示
set_status_window

#７週間リピート
_LOOP_ 7 do
  #週開始処理
  _SET_ [:_ROOT_, :_TEMP_], day: 0

  _LOOP_ 7 do
    #画面の更新
    _SEND_ :status_window do
      update_status
    end

    #曜日終了フラグリセット
    _SET_ [:_ROOT_, :_TEMP_], end_day: nil

    #メニュー表示
    top_menu

    #曜日更新処理
    _GET_ [:day], control: [:_ROOT_, :_TEMP_] do |day:|
      _SET_ [:_ROOT_, :_TEMP_], day: day + 1
    end
    _HALT_
  end

  #ゲームオーバー判定
  _GET_ [:debt, :week], control: [:_ROOT_, :_TEMP_] do |debt:, week:|
    _CHECK_ [:_ROOT_, :_TEMP_], under: {gold: debt[week]} do
      _SET_ [:_ROOT_, :_TEMP_], gameover: true
      _BREAK_
    end

    #借金返済
    _GET_ [:gold], control: [:_ROOT_, :_TEMP_] do |gold:|
      _SET_ [:_ROOT_, :_TEMP_], gold: gold - debt[week]
    end
  end

  #ゲームクリア判定
  _CHECK_ [:_ROOT_, :_TEMP_], equal: {week: 6} do
    _SET_ [:_ROOT_, :_TEMP_], gameclear: true
    _BREAK_
  end

  #週更新処理
  _GET_ [:week], control: [:_ROOT_, :_TEMP_] do |week:|
    _SET_ [:_ROOT_, :_TEMP_], week: week + 1
  end
end

#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■ゲーム終了シーン
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

_DELETE_ :status_window

_HALT_

#ゲームオーバーならテキストを出力して終了
_CHECK_ [:_ROOT_, :_TEMP_], equal: {gameover: true} do
  _SEND_ :text0 do
    _TEXT_ "　あなたはメイドの借金を返すことができなかった。"
    _LINE_FEED_
    _TEXT_ "あわれメイドは売られてしまい、その後を知るもの"
    _LINE_FEED_
    _TEXT_ "はいない……。"
  end
  _END_PAUSE_
  _EXIT_
end

#ゲームクリアならテキストを出力して終了
_CHECK_ [:_ROOT_, :_TEMP_], equal: {gameclear: true} do
  _SEND_ :text0 do
    _TEXT_ "　無事にメイドの借金を返済し終えたあなたには、"
    _LINE_FEED_
    _TEXT_ "メイドとの楽しい日々の暮らしが待っている。"
    _LINE_FEED_
    _TEXT_ "　ゲームクリアおめでとうございます。"
    _LINE_FEED_
    _LINE_FEED_
    _TEXT_ "Thank you for playing."
  end
  _END_PAUSE_
  _EXIT_
end

_PUTS_ "eof"