#! ruby -E utf-8

_SET_ :_TEMP_,
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

_DEFINE_ :menu_button do |id:, text: |
  _TEXT_BUTTON_ text: text, 
    id: id,
    width: 228, 
    height:32,
    char_color: [255,255,0], #文字色
    out_color: [0,255,255],
    float_y: :bottom do |id|
    _SET_ :_TEMP_, flag: id
  end
end

#ウィンドウのリサイズ
_RESIZE_ width: 800, height: 600

#トップメニュー
_DEFINE_ :top_menu do
  _CREATE_ :LayoutControl, id: :top_menu, x:100, y:100 do
    menu_button text: "習い事をさせる", id: :lesson
    menu_button text: "働かせる", id: :work
    menu_button text: "休ませる", id: :rest
  end

  _WAIT_ :_TEMP_,  not_equal: {flag: nil}

  #メニューを削除する
  _SEND_ :top_menu  do
    _DELETE_
  end

  _CHECK_ :_TEMP_, equal: {flag: :lesson} do
    lesson_menu
  end

  _CHECK_ :_TEMP_, equal: {flag: :work} do
    work_menu
  end

  _CHECK_ :_TEMP_, equal: {flag: :rest} do
    rest
  end
end

#「習い事をさせる」メニュー
_DEFINE_ :lesson_menu do
  _CREATE_ :LayoutControl, id: :lesson_menu, x:100, y:100 do
    menu_button text: "礼拝", id: :pray
    menu_button text: "学問", id: :academy
    menu_button text: "舞踏", id: :dance
    menu_button text: "礼儀作法", id: :courtesy
    menu_button text: "戻る", id: :cancel
  end

  _SET_ :_TEMP_, flag: nil
  _WAIT_ :_TEMP_,  not_equal: {flag: nil}

  #メニューを削除する
  _SEND_ :lesson_menu  do
    _DELETE_
  end

  #押されたのが「戻る」以外であれば、処理を実行して曜日終了フラグを立てる
  _CHECK_ :_TEMP_, not_equal: {flag: :cancel} do
    _GET_ [ :mental_point_max, 
            :mental_point,
            :helth_point,
            :allegiance,
            :courtesy,
            :noble,
            :intelligence,
            :culture,
            :charm,
            ], datastore: :_TEMP_ do |arg, options|
    #礼拝
    _CHECK_ :_TEMP_, equal: {flag: :pray} do 
      hp_cost = [(options[:mental_point_max] - options[:mental_point]) + 15, 
                 [options[:helth_point] - (options[:mental_point_max] - options[:mental_point] + 15),
                    options[:helth_point]].max].min
      mp_cost = [10, [options[:mental_point] - 10, options[:mental_point]].max
                ].min
      _SET_ :_TEMP_, allegiance: options[:allegiance] +  hp_cost / 2 + (mp_cost + options[:courtesy]) / 3
      _SET_ :_TEMP_, noble: options[:noble] + hp_cost / 2 + (mp_cost + options[:intelligence]) / 3
      _SET_ :_TEMP_, helth_point: options[:helth_point] - hp_cost
      _SET_ :_TEMP_, mental_point: options[:mental_point] - mp_cost
      
      pp options
    end
    #勉学
    _CHECK_ :_TEMP_, equal: {flag: :academy} do |a,b,c|
      hp_cost = [(options[:mental_point_max] - options[:mental_point]) + 5, 
                 [options[:helth_point] - (options[:mental_point_max] - options[:mental_point] + 5),
                    options[:helth_point]].max].min
      mp_cost = [20, [options[:mental_point] - 20, options[:mental_point]].max
                ].min
      _SET_ :_TEMP_, culture: options[:culture] + hp_cost / 2 + (mp_cost + options[:courtesy]) / 2
      _SET_ :_TEMP_, intelligence: options[:intelligence] + hp_cost / 2 + (mp_cost + options[:intelligence]) / 3
      _SET_ :_TEMP_, helth_point: options[:helth_point] - hp_cost
      _SET_ :_TEMP_, mental_point: options[:mental_point] - mp_cost
    end
    #舞踏
    _CHECK_ :_TEMP_, equal: {flag: :dance} do |a,b,c|
      hp_cost = [(options[:mental_point_max] - options[:mental_point]) + 20, 
                 [options[:helth_point] - (options[:mental_point_max] - options[:mental_point] + 20),
                    options[:helth_point]].max].min
      mp_cost = [15, [options[:mental_point] - 15, options[:mental_point]].max
                ].min
      _SET_ :_TEMP_, charm: options[:charm] + hp_cost / 2 + (mp_cost + options[:courtesy]) / 2
      _SET_ :_TEMP_, noble: options[:noble] + hp_cost / 2 + (mp_cost + options[:intelligence]) / 2
      _SET_ :_TEMP_, helth_point: options[:helth_point] - hp_cost
      _SET_ :_TEMP_, mental_point: options[:mental_point] - mp_cost
    end
    #礼拝
    _CHECK_ :_TEMP_, equal: {flag: :courtesy} do |a,b,c|
      hp_cost = [(options[:mental_point_max] - options[:mental_point]) + 5, 
                 [options[:helth_point] - (options[:mental_point_max] - options[:mental_point] + 5),
                    options[:helth_point]].max].min
      mp_cost = [20, [options[:mental_point] - 20, options[:mental_point]].max
                ].min
      _SET_ :_TEMP_, courtesy: options[:courtesy] +  hp_cost / 2 + (mp_cost + options[:courtesy]) / 2
      _SET_ :_TEMP_, culture: options[:culture] + hp_cost / 2 + (mp_cost + options[:intelligence]) / 3
      _SET_ :_TEMP_, helth_point: options[:helth_point] - hp_cost
      _SET_ :_TEMP_, mental_point: options[:mental_point] - mp_cost
    end
    end
    _SEND_ [:_ROOT_], interrupt: true do
      nomaid_comment_area{_SET_ char: "習い事によってメイドは少し成長した。"}
      _WAIT_ system: :mouse_push
      nomaid_comment_area{_SET_ char: " "}
    end
    _SET_ :_TEMP_, end_day: true
  end
end

#「働かせる」メニュー
_DEFINE_ :work_menu do
  _CREATE_ :LayoutControl, id: :work_menu, x:100, y:100 do
    menu_button text: "清掃", id: :cleaning
    menu_button text: "給仕", id: :waitress
    menu_button text: "家庭教師", id: :tutor
    menu_button text: "接待", id: :party
    menu_button text: "戻る", id: :cancel
  end
  _SET_ :_TEMP_, flag: nil
  _WAIT_ :_TEMP_,  not_equal: {flag: nil}

  #メニューを削除する
  _SEND_ :work_menu  do
    _DELETE_
  end

  #押されたのが「戻る」以外であれば、処理を実行して曜日終了フラグを立てる
  _CHECK_ :_TEMP_, not_equal: {flag: :cancel} do
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
            ], datastore: :_TEMP_ do |arg, options|
      #礼拝
      _CHECK_ :_TEMP_, equal: {flag: :cleaning} do |a,b,c|
        hp_cost = [ options[:mental_point_max] - options[:mental_point] + 10, 
                    [ options[:helth_point] - options[:mental_point_max] - options[:mental_point] + 10,
                      options[:helth_point]].max].min
        mp_cost = [ 10, [ options[:mental_point] - 10, options[:mental_point]].max].min
        reward = 200 + (hp_cost * options[:allegiance])/2 + (mp_cost * options[:allegiance])/2
        _SET_ :_TEMP_, allegiance: options[:allegiance] + hp_cost / 3 + mp_cost / 3
        _SET_ :_TEMP_, helth_point: options[:helth_point] - hp_cost
        _SET_ :_TEMP_, mental_point: options[:mental_point] - mp_cost
        _SET_ :_TEMP_, gold: options[:gold] + reward
        _SET_ :_TEMP_, reward: reward
      end
      #給仕
      _CHECK_ :_TEMP_, equal: {flag: :waitress} do |a,b,c|
        hp_cost = [ options[:mental_point_max] - options[:mental_point] + 15, 
                    [ options[:helth_point] - options[:mental_point_max] - options[:mental_point] + 15,
                      options[:helth_point]].max].min
        mp_cost = [ 20, [ options[:mental_point] - 20, options[:mental_point]].max].min
        reward = hp_cost *((options[:allegiance] + options[:courtesy] + options[:intelligence] / 2) / 3)+
                 mp_cost * ((options[:charm] * 2 + options[:intelligence]) / 3)

        _SET_ :_TEMP_, allegiance: options[:allegiance] += hp_cost / 3 + mp_cost / 3

        _SET_ :_TEMP_, helth_point: options[:helth_point] - hp_cost
        _SET_ :_TEMP_, mental_point: options[:mental_point] - mp_cost
        _SET_ :_TEMP_, gold: options[:gold] + reward
        _SET_ :_TEMP_, reward: reward
      end

      #家庭教師
      _CHECK_ :_TEMP_, equal: {flag: :tutor} do |a,b,c|
        hp_cost = [ options[:mental_point_max] - options[:mental_point] + 25, 
                    [ options[:helth_point] - options[:mental_point_max] - options[:mental_point] + 25,
                      options[:helth_point]].max].min
        mp_cost = [ 40, [ options[:mental_point] - 40, options[:mental_point]].max].min
        reward =  hp_cost * ((options[:noble] + options[:courtesy] + options[:intelligence] / 2) / 3) +
                mp_cost * ((options[:culture] * 2 + options[:intelligence] * 2) / 3)

        _SET_ :_TEMP_, helth_point: options[:helth_point] - hp_cost
        _SET_ :_TEMP_, mental_point: options[:mental_point] - mp_cost
        _SET_ :_TEMP_, gold: options[:gold] + reward
        _SET_ :_TEMP_, reward: reward
      end

      #接待
      _CHECK_ :_TEMP_, equal: {flag: :party} do |a,b,c|
        hp_cost = [ options[:mental_point_max] - options[:mental_point] + 30, 
                    [ options[:helth_point] - options[:mental_point_max] - options[:mental_point] + 30,
                      options[:helth_point]].max].min
        mp_cost = [ 30, [ options[:mental_point] - 30, options[:mental_point]].max].min
        reward =  hp_cost * ((options[:allegiance] * 2 + options[:courtesy] + options[:intelligence] / 2) / 2) + 
                mp_cost * ((options[:culture] / 2 + options[:charm] * 2 + options[:noble] * 2) / 3)

        _SET_ :_TEMP_, helth_point: options[:helth_point] - hp_cost
        _SET_ :_TEMP_, mental_point: options[:mental_point] - mp_cost
        _SET_ :_TEMP_, gold: options[:gold] + reward
        _SET_ :_TEMP_, reward: reward
      end

    end
    _SEND_ [:_ROOT_], interrupt: true  do
      _GET_ :reward, datastore: :_TEMP_ do |arg, options|
        nomaid_comment_area{_SET_ char: "労働の対価として$#{options[:reward]}を得た。"}
      end
      _WAIT_ system: :mouse_push
      nomaid_comment_area{_SET_ char: " "}
    end
    _SET_ :_TEMP_, end_day: true
  end
end

#「休ませる」処理
_DEFINE_ :rest do
  _GET_ [:helth_point, :mental_point], datastore: :_TEMP_ do |arg, options|
    options[:helth_point] += [100 - options[:helth_point], 
                              options[:mental_point]].min
    options[:mental_point] += [100 - options[:mental_point], 50].min
    _SET_ :_TEMP_,  helth_point: options[:helth_point], 
                    mental_point: options[:mental_point]
  end
  _SEND_ [:_ROOT_], interrupt: true  do
    nomaid_comment_area{_SET_ char: "メイドはゆっくりと身体を休めた……。"}
    _WAIT_ system: :mouse_push
    nomaid_comment_area{_SET_ char: " "}
  end
  _SET_ :_TEMP_, end_day: true
end

#ＯＰ用テキストレイアウト指定
_SEND_(:text0){
  _SET_ x:32, y:32, width: 1024, height: 1024, size:24
}

_INCLUDE_ "./script/nomaid/op.tks"

_SEND_(:text0){
  _FLUSH_
}

_CREATE_ :CharControl, 
  id: :nomaid_comment_area,
  size: 32, 
  x: 64,
  y: 128,
  color:[255,255,0], 
  font_name: "ＭＳ ゴシック",
  char: " "

#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■メイﾝループ
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

#ステータスウィンドウ
_CREATE_ :TextPageControl, 
  x: 32,
  y: 256,
  width: 1024,
  height: 192,
  size: 32, 
  id: :text1,
  font_name: "ＭＳＰ ゴシック"

_DEFINE_ :status_text do |id: nil, char: nil|
  _CREATE_ :CharControl, 
    size: 32,
    id: id,
    float_x: :left, 
    color:[255,255,0], 
    font_name: "ＭＳＰ ゴシック",
    char: char || " "
end

_CREATE_ :LayoutControl,
  id: :status_window, 
  x: 32,
  y: 256,
  width: 1024,
  height: 192 do
    _CREATE_ :LayoutControl, id: :line1, height: 42, float_y: :bottom do
      status_text char: "第"
      status_text id: :week
      status_text char: "週　第"
      status_text id: :day
      status_text char: "日目　現在の所持金は＄"
      status_text id: :gold
      status_text char: "。"
    end
    _CREATE_ :LayoutControl, id: :line2, height: 42, float_y: :bottom do
      status_text char: "借金の返済まであと"
      status_text id: :last_day
      status_text char: "日。"
    end
    _CREATE_ :LayoutControl, id: :line3, height: 42, float_y: :bottom do
      status_text char: "今週の返済額は＄"
      status_text id: :week_debt
      status_text char: "で、あと＄"
      status_text id: :week_debt_last_gold
      status_text char: "必要だ。"
    end
    _CREATE_ :LayoutControl, id: :line4, height: 42, float_y: :bottom do
      status_text char: "＝＝＝＝"
    end
    _CREATE_ :LayoutControl, id: :line5, height: 42, float_y: :bottom do
      status_text char: "所持金："
      status_text id: :gold
      status_text char: "　ＨＰ："
      status_text id: :helth_point
      status_text char: "/"
      status_text id: :helth_point_max
      status_text char: "　ＭＰ："
      status_text id: :mental_point
      status_text char: "/"
      status_text id: :mental_point_max
    end
    _CREATE_ :LayoutControl, id: :line6, height: 42, float_y: :bottom do
      status_text char: "魅力："
      status_text id: :charm
      status_text char: "　気品："
      status_text id: :noble
      status_text char: "　教養："
      status_text id: :culture
    end
    _CREATE_ :LayoutControl, id: :line7, height: 42, float_y: :bottom do
      status_text char: "知性："
      status_text id: :intelligence
      status_text char: "　恭順："
      status_text id: :allegiance
      status_text char: "　礼節："
      status_text id: :courtesy
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
              ], datastore: :_TEMP_ do |
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
        line1{
          day{_SET_ char: day + 1}
          week{_SET_ char: week + 1}
          gold{_SET_ char: gold}
        }
        line2{
          last_day{_SET_ char: 7-day}
        }
        line3{
          week_debt{_SET_ char: debt[week]}
          week_debt_last_gold{_SET_ char: [debt[week] - gold, 0].max}
        }
        line5{
          gold{_SET_ char: gold}
          helth_point{_SET_ char: helth_point}
          helth_point_max{_SET_ char: helth_point_max}
          mental_point{_SET_ char: mental_point}
          mental_point_max{_SET_ char: mental_point_max}
        }
        line6{
          charm{_SET_ char: charm}
          noble{_SET_ char: noble}
          culture{_SET_ char: culture}
        }
        line7{
          intelligence{_SET_ char: intelligence}
          allegiance{_SET_ char: allegiance}
          courtesy{_SET_ char: courtesy}
        }
      end
    end
end

#７週間リピート
_LOOP_ count:7 do
  #週開始処理
  _SET_ :_TEMP_, day: 0

  _LOOP_ count:7 do
    #画面の更新
    status_window{
      update_status
    }

    #曜日終了フラグリセット
    _SET_ :_TEMP_, end_day: nil

    #トップメニューの表示と処理
    _LOOP_ do
      #メニュー押下フラグリセット
      _SET_ :_TEMP_, flag: nil
      #メニュー表示
      top_menu
      #曜日終了確認
      _CHECK_ :_TEMP_, equal: {end_day: true} do
        _BREAK_
      end
    end

    #曜日更新処理
    _SET_OFFSET_ :_TEMP_ , day: 1
    _END_FRAME_
  end

  #ゲームオーバー判定
  _GET_ [:debt, :week], datastore: :_TEMP_ do |debt:, week:|
    _CHECK_ :_TEMP_, under: {gold: debt[week]} do
      _SET_ :_TEMP_, gameover: true
      _BREAK_
    end

    #借金返済
    _SET_OFFSET_  :_TEMP_, gold: -debt[week]
  end

  #ゲームクリア判定
  _CHECK_ :_TEMP_, equal: {week: 6} do
    _SET_ :_TEMP_, gameclear: true
    _BREAK_
  end

  #週更新処理
  _SET_OFFSET_  :_TEMP_, week: 1
end

status_window{_DELETE_}

_END_FRAME_

#ゲームオーバーならテキストを出力して終了
_CHECK_ :_TEMP_, equal: {gameover: true} do
  #_INCLUDE_ "./script/nomaid/bad_end.tks"
  text1{
    _FLUSH_
    _TEXT_ "　あなたはメイドの借金を返すことができなかった。"
    _LINE_FEED_
    _TEXT_ "あわれメイドは売られてしまい、その後を知るもの"
    _LINE_FEED_
    _TEXT_ "はいない……。"
  }
  _WAIT_ system: :mouse_push
  _EXIT_
end

#ゲームクリアならテキストを出力して終了
_CHECK_ :_TEMP_, equal: {gameclear: true} do
  #_INCLUDE_ "./script/nomaid/happy_end.tks"
  text1{
    _FLUSH_
    _TEXT_ "　無事にメイドの借金を返済し終えたあなたには、"
    _LINE_FEED_
    _TEXT_ "メイドとの楽しい日々の暮らしが待っている。"
    _LINE_FEED_
    _TEXT_ "　ゲームクリアおめでとうございます。"
    _LINE_FEED_
    _LINE_FEED_
    _TEXT_ "Thank you for playing."
  }
  _WAIT_ system: :mouse_push
  _EXIT_
end

_PUTS_ "eof"