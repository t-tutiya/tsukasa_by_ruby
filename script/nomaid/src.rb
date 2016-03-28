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
      nomaid_comment_area{_SET_ charactor: "習い事によってメイドは少し成長した。"}
      _WAIT_ system: :key_down
      nomaid_comment_area{_SET_ charactor: " "}
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
        nomaid_comment_area{_SET_ charactor: "労働の対価として$#{options[:reward]}を得た。"}
      end
      _WAIT_ system: :key_down
      nomaid_comment_area{_SET_ charactor: " "}
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
    nomaid_comment_area{_SET_ charactor: "メイドはゆっくりと身体を休めた……。"}
    _WAIT_ system: :key_down
    nomaid_comment_area{_SET_ charactor: " "}
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
  charactor: " "

#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■メイﾝループ
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

_CREATE_ :TextPageControl, 
  x: 32,
  y: 256,
  width: 1024,
  height: 192,
  size: 32, 
  id: :text1,
  font_name: "ＭＳＰ ゴシック"

#７週間リピート
_LOOP_ count:7 do |arg, ops, control|
  #週開始処理
  _SET_ :_TEMP_, day: 0

  _LOOP_ count:7 do |arg, ops, control|
    _END_FRAME_

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
            ], datastore: :_TEMP_ do |arg, options|

    text1{
      _FLUSH_
      _TEXT_  "第#{options[:week] + 1 }週#{options[:day] + 1}日目。現在の所持金は$#{options[:gold]}。"
      _LINE_FEED_
      _TEXT_  "借金の返済まで後#{7 - options[:day]}日。"
      _LINE_FEED_
      _TEXT_  "今週の返済額は$#{options[:debt][options[:week]]}で、あと$#{ [options[:debt][options[:week]] - options[:gold],0].max}必要だ。"
      _LINE_FEED_
      _TEXT_  "==="
      _LINE_FEED_
      _TEXT_  "所持金：#{options[:gold]}  ＨＰ　：#{options[:helth_point]}/#{options[:helth_point_max]}  ＭＰ　：#{options[:mental_point]}/#{options[:mental_point_max]}"
      _LINE_FEED_
      _TEXT_ "魅力：#{options[:charm]}  気品　：#{options[:noble]}  教養　：#{options[:culture]}"
      _LINE_FEED_
      _TEXT_ "知性：#{options[:intelligence]}  恭順　：#{options[:allegiance]}  礼節　：#{options[:courtesy]}"
    }
    end

    _SET_ :_TEMP_, end_day: nil

    #トップメニューの表示と処理
    _LOOP_ do
      _SET_ :_TEMP_, flag: nil

      top_menu

      _CHECK_ :_TEMP_, equal: {end_day: true} do
        _BREAK_
      end
    end

    #曜日開始処理
    _GET_ :day, datastore: :_TEMP_ do |arg, options|
      _SET_ :_TEMP_ , day: options[:day] + 1
    end
  end

  _SET_ :_TEMP_, gameover: nil

  _GET_ [:gold, :debt, :week, :gameover, :gameclear], datastore: :_TEMP_ do |arg, options|
    options[:gold] -= options[:debt][options[:week]]
    options[:week] += 1

    if options[:gold] < 0
      options[:gameover] = true
    else
      options[:gameover] = false
    end

    if options[:week] == 7
      options[:gameclear] = true
    end
    _SET_ :_TEMP_,  gold: options[:gold], 
                    week: options[:week], 
                    gameover: options[:gameover], 
                    gameclear: options[:gameclear]
  end
end


  #gameoverフラグが変化するのを待つ
  #[解説]※１はコマンドを送信するだけですぐこの処理に移ってしまうので、フラグ経由でタイミングを管理しなければならない
  _WAIT_ :_TEMP_,  not_equal: {gameover: nil}

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
    _WAIT_ system: :key_down
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
    _WAIT_ system: :key_down
    _EXIT_
  end

_PUTS_ "eof"