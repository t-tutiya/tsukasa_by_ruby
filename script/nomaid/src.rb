#! ruby -E utf-8

#メイドコントロールの読み込みと生成
_LOAD_NATIVE_ "./script/nomaid/nomaid.rb"
_CREATE_ :NomaidControl, id: :maid

=begin
test = <<"EOF"
テスト
  _PUTS_ "test"
EOF

_PARSE_ test, parser: TKSParser
=end
#テキストボタン定義
_DEFINE_ :TextSelect do |argument, options|
  _CREATE_ :LayoutControl,
    float_y: :bottom,
    x: options[:x] || 0, 
    y: options[:y] || 0, 
    width: 228, 
    height: 32, 
    id: :Anonymous_CharControl do
    #テキストを描画するRenderTarget
    _CREATE_ :RenderTargetControl,
      float_x: :left,
      width: 228, 
      height: 32, 
      id: :text_area, 
      bgcolor: [255,255,0] do
      _CREATE_ :CharControl, 
        size: 32, 
        color:[255,255,0], 
        font_name: "ＭＳ ゴシック", 
        charactor: options[:text]
    end
    _NEXT_LOOP_ do
      _CHECK_ mouse: [:cursor_over] do
      #マウスが領域内に入ったら色を変え、
        text_area{
          _SET_ bgcolor: [255,0,255]
        }
      end
      #マウスが領域外に出たら色を戻す
      _CHECK_ mouse: [:cursor_out] do
        text_area{
          _SET_ bgcolor: [0,255,255]
        }
      end
      #マウスがクリックされたらフラグを立てる
      _CHECK_ mouse: [:key_down] do
        _SET_ :_TEMP_, flag: options[:id]
        #_EVAL_ "pp '[" + options[:text].to_s + "]が押されました'"
        _RETURN_
      end
    end
  end
end

#ウィンドウのリサイズ
_RESIZE_ width: 800, height: 600

#トップメニュー
_DEFINE_ :top_menu do
  _CREATE_ :LayoutControl, id: :top_menu, x:100, y:100 do
    TextSelect text: "習い事をさせる", id: :lesson
    TextSelect text: "働かせる", id: :work
    TextSelect text: "休ませる", id: :rest
  end

  _WAIT_ :_TEMP_,  not_equal: {flag: nil}

  #メニューを削除する
  _SEND_ :top_menu  do
    _DELETE_
  end

  _CHECK_ equal: {flag: :lesson} do
    lesson_menu
  end

  _CHECK_ equal: {flag: :work} do
    work_menu
  end

  _CHECK_ equal: {flag: :rest} do
    rest
  end
end

#「習い事をさせる」メニュー
_DEFINE_ :lesson_menu do
  _CREATE_ :LayoutControl, id: :lesson_menu, x:100, y:100 do
    TextSelect text: "礼拝", id: :pray
    TextSelect text: "学問", id: :academy
    TextSelect text: "舞踏", id: :dance
    TextSelect text: "礼儀作法", id: :courtesy
    TextSelect text: "戻る", id: :cancel
  end

  _SET_ :_TEMP_, flag: nil
  _WAIT_ :_TEMP_,  not_equal: {flag: nil}

  #メニューを削除する
  _SEND_ :lesson_menu  do
    _DELETE_
  end

  #押されたのが「戻る」以外であれば、処理を実行して曜日終了フラグを立てる
  _CHECK_ not_equal: {flag: :cancel} do
    maid{
      lesson
      _SEND_ROOT_ do
        _SEND_(default: :TextLayer){
          _FLUSH_
          _TEXT_ "習い事によってメイドは少し成長した。"
        }
        ep
      end
    }
    _SET_ :_TEMP_, end_day: true
  end
end

#「働かせる」メニュー
_DEFINE_ :work_menu do
  _CREATE_ :LayoutControl, id: :work_menu, x:100, y:100 do
    TextSelect text: "清掃", id: :cleaning
    TextSelect text: "給仕", id: :waitress
    TextSelect text: "家庭教師", id: :tutor
    TextSelect text: "接待", id: :party
    TextSelect text: "戻る", id: :cancel
  end
  _SET_ :_TEMP_, flag: nil
  _WAIT_ :_TEMP_,  not_equal: {flag: nil}

  #メニューを削除する
  _SEND_ :work_menu  do
    _DELETE_
  end

  #押されたのが「戻る」以外であれば、処理を実行して曜日終了フラグを立てる
  _CHECK_ not_equal: {flag: :cancel} do
    maid{
      work
      _SEND_ROOT_ do
        _SEND_(default: :TextLayer){
          _FLUSH_
          _TEXT_ "労働の対価として$#{_TEMP_[:reward]}を得た。"
        }
        ep
      end
    }
    _SET_ :_TEMP_, end_day: true
  end
end

#「休ませる」処理
_DEFINE_ :rest do
  maid{
    rest
    _SEND_ROOT_ do
      _SEND_(default: :TextLayer){
        _FLUSH_
        _TEXT_ "メイドはゆっくりと身体を休めた……。"
      }
      ep
    end
  }
  _SET_ :_TEMP_, end_day: true
end

#ＯＰ用テキストレイアウト指定
text0{
  _SET_ x:32, y:32, width: 1024, height: 1024, size:24
}
  
#ＯＰメッセージ表示
_INCLUDE_ "./script/nomaid/op.tks"

#テキストウィンドウの際レイアウト
text0 do
  _SET_ x: 32, y: 256, size:32
        
  #文字レンダラを削除する
  _DEFINE_ :_CHAR_RENDERER_ do
  end
  _DEFINE_ :_CHAR_WAIT_ do
  end
  _DEFINE_ :_LINE_WAIT_ do
  end
  _FLUSH_
end

_END_FRAME_

#７週間リピート
_LOOP_ count:7 do |arg, ops, control|
  #週開始処理
  maid{
    week_init
  }
  
  _LOOP_ count:7 do |arg, ops, control|
    #曜日開始処理
    maid{
      day_init
    }

    #[解説]本来ならtksファイルの中にスクリプトを記述すれば良い筈だが、面倒なので逆にした。
    #読み込み時にがっつりウェイトが入るのは、多分ファイルアクセスが発生しているからかと思われる。
    #_INCLUDE_ "./script/nomaid/start_week.tks"

    _SEND_(default: :TextLayer){
      _TEXT_  "第#{_T[:week] + 1 }週#{_T[:day] + 1}日目。現在の所持金は$#{_T[:gold]}。"
      _LINE_FEED_
      _TEXT_  "借金の返済まで後#{7 - _T[:day]}日。"
      _LINE_FEED_
      _TEXT_  "今週の返済額は$#{_T[:debt][_TEMP_[:week]]}で、あと$#{ [_T[:debt][_T[:week]] - _T[:gold],0].max}必要だ。"
      _LINE_FEED_
      _TEXT_  "==="
      _LINE_FEED_
      _TEXT_  "所持金：#{_T[:gold]}  ＨＰ　：#{_T[:helth_point]}/#{_T[:helth_point_max]}  ＭＰ　：#{_T[:mental_point]}/#{_T[:mental_point_max]}"
      _LINE_FEED_
      _TEXT_ "魅力：#{_T[:charm]}  気品　：#{_T[:noble]}  教養　：#{_T[:culture]}"
      _LINE_FEED_
      _TEXT_ "知性：#{_T[:intelligence]}  恭順　：#{_T[:allegiance]}  礼節　：#{_T[:courtesy]}"
    }

    _END_FRAME_

    _SET_ :_TEMP_, end_day: nil

    #トップメニューの表示と処理
    _LOOP_ do
      _SET_ :_TEMP_, flag: nil

      top_menu

      _CHECK_ equal: {end_day: true} do
        _BREAK_
      end
    end

    maid{
      end_day
    }
  end

  _SET_ :_TEMP_, gameover: nil

  #週終了処理（※１）
  maid{
    end_week #gameoverならtrue、そうでなければfalseが返る
  }

  #gameoverフラグが変化するのを待つ
  #[解説]※１はコマンドを送信するだけですぐこの処理に移ってしまうので、フラグ経由でタイミングを管理しなければならない
  _WAIT_ :_TEMP_,  not_equal: {gameover: nil}

  #ゲームオーバーならテキストを出力して終了
  _CHECK_ equal: {gameover: true} do
    #_INCLUDE_ "./script/nomaid/bad_end.tks"
    _SEND_(default: :TextLayer){
      _FLUSH_
      _TEXT_ "　あなたはメイドの借金を返すことができなかった。"
      _LINE_FEED_
      _TEXT_ "あわれメイドは売られてしまい、その後を知るもの"
      _LINE_FEED_
      _TEXT_ "はいない……。"
    }
    ep
    _EXIT_
  end

  #ゲームクリアならテキストを出力して終了
  _CHECK_ equal: {gameclear: true} do
    #_INCLUDE_ "./script/nomaid/happy_end.tks"
    _SEND_(default: :TextLayer){
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
    ep
    _EXIT_
  end
end

_PUTS_ "eof"