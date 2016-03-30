# メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」

# 概要

・ 司エンジンはメッセージ指向ゲーム記述言語「司スクリプト」の実装系です。rubyの内部ＤＳＬとして実装され、開発環境を含むフレームワークとして構成されています。
・ Ruby用DirectXゲームライブラリDXRuby上で動作しています。Windows専用です。
・ また、ノベルゲームの開発に特化した「tksスクリプト」も使用できます。tksスクリプトは内部で司スクリプトに変換され、ユーザーは必要に応じてシームレスに扱うことができます。

# 内部メカニズムの特徴

・ ゲームで用いる全てのオブジェクトをみなし、単一のツリーに連結させている
    ・ 画像、サウンドはもちろん、テキストウィンドウ内の文字一個にいたるまでオブジェクトとして管理しています。
    ・ これによって、ゲームのあらゆる要素に対して一貫した設計コンセプトを実現します。
・ 全てのオブジェクトをＶＭ（計算機）とみなし、ツリーの上位からメッセージを送信して駆動する。
    ・ 上位から送信されたメッセージは各オブジェクト内にスタックされ、実行されます。
    ・ 各メッセージは処理を行ったのち、自律的に自身を削除するか、次フレームに再実行するかを判断します。
    ・ 同フレーム中に複数の上位オブジェクトから同一のオブジェクトに対しメッセージが送信された場合、その全てがスタックされ、同フレーム中に処理されます。
    ・ メッセージには制御構文も含められるため、プログラムブロックをまるごと送信できます。
    ・ これらの挙動により、とかく状態遷移機械としての実装が複雑になりがちなゲームプログラミングのオブジェクトの実装効率の向上を狙っています。
・ 全てのオブジェクトは疑似マルチスレッド的に駆動する。
    ・ それぞれのオブジェクトは受け取ったメッセージ（≒プログラムブロック）を非同期に処理するので、ゲームのように複雑な並列処理が必要とされるプログラムを、平坦に記述できます。

#ドキュメント

　司エンジンに関するドキュメントについては、下記の各サイトを参照してください。

・ 司エンジン：導入手順
    ・ [準備中]
・ 司エンジン：司スクリプト記法解説
    ・ http://d.hatena.ne.jp/t_tutiya/20151103/1446536107
・ 司エンジン：tksスクリプト記法解説
    ・ http://d.hatena.ne.jp/t_tutiya/20151104/1446606281
・ リファレンスマニュアル
    ・ https://github.com/t-tutiya/tsukasa/wiki
・ サンプルコード
    ・ [準備中。script/sampleフォルダに入っているサンプルコードを参照してください]

#その他の資料

##司エンジンの設計コンセプト

　司エンジンは「既存のゲーム開発そのもの」を再定義するために土屋つかさが進めている個人プロジェクトです。下記記事で紹介しています。

DXRuby Advent Calendar 2015 ３日目：汎用ゲームフレームワーク（を目指す）司エンジンの紹介
http://d.hatena.ne.jp/t_tutiya/20151202/1449068891

　上記記事にもリンクしていますが、下記のＰＤＦでは司エンジンが問題領域としている課題について、より専門的な議論を展開しています。
司エンジン解説本第１部サンプル（１２月２日版）
http://someiyoshino.main.jp/file/1218_tsukasa_engine_book_sample_chap1.pdf

## キーコード定数
　キー入力判定時に使用するキーコード定数はDXRubyと同じです。

DXRuby キーコード定数
http://mirichi.github.io/dxruby-doc/api/constant_keycode.html

## フォルダ構成
　司エンジン開発フォルダルート直下のフォルダとファイル構成を簡単に解説しておきます。
・ system 司エンジンのソースコードが格納されています。
・ default 初期値を設定するconfig.rb／デフォルトのスクリプトを格納するdefault_script.rbなどが格納されています。
・ script 司/tksスクリプトを配置するフォルダです。このフォルダのfirst.rbが最初に実行されます。
・ resource サンプルで使うリソースファイルが入っています。
    ・ githubからインストールする場合は、下記ファイルを直接ダウンロードし、展開後に配置してください。
・ datastore データストアを保存するフォルダです。初期状態では空です。
    ・ githubからインストールする場合はこのフォルダが存在しないので、手動で空フォルダを作成してください。
・ main.rb 実行スクリプト。これ自体は司エンジンには含まれません。
・ readme.rd 簡易ドキュメント

##更新履歴

v1.2.0(2016/4/1)

・司スクリプト
　・データストアへの簡易アクセスできる仕様を廃止
　・controlをブロック引数で取得できる仕様を廃止

・クラス構成
　・Layoutable/DrawableモジュールをControl派生クラスLayoutableControl/DrawableControlに変更
　・ClickableモジュールをLayoutControl派生クラスClickableLayoutControlに変更
　・Tsukasaの継承元クラスをControlに変更
　・TileMapControlの継承元クラスをRenderTargetControlに変更
　・CharaControlの継承元クラスをDrawableControlに変更

・Control
　・プロパティ
　　・child_index追加
　　・child_update（子コントロール更新フラグ）追加
　・_SEND_
　　・第１引数を設定しない場合、自コントロールを対象とするように変更
　　・interruptオプションを追加
　　・特殊コントロールＩＤ:_ROOT_/:_PARENT_を対応
　・_SEND_ALL_コマンドを追加
　・_SEND_ROOT_コマンド廃止
　・_SET_OFFSET_コマンドを追加
　・_GET_のインターフェイスを刷新
　　・指定した値はブロック経由で参照する形式に変更
　　・_RESULT_を廃止
　・_MOVE_/_PATH_の仕様を更新
　　・移動が終わるまでウェイトをかけ、実行中はブロックが実行されるように変更
　　・_MOVE_/_PATH_のoptionを_OPTION_に変更
　　・無効のeasingオプションが設定された場合:linerに差し替えるように修正
　・_INCLUDE_で多重読み込みを抑制する処理を追加：forceオプションを追加
　・条件判定
　　・条件判定でコントロールプロパティの比較を可能にした
　　・パッドボタン判定を追加
　　・childをchild_existに変更
　　・child_not_existを追加
　・_DEBUG_変数削除
　・デフォルト設定を廃止

・LayoutableControl
　・width/heightの初期値を１に変更
　・_TO_IMAGE_をLayoutableControlに移動

・DrawableControl
　・visibleプロパティをLayoutableControlから移動
　・entityを非プロパティ化した
　・未使用プロパティreal_width/real_heightを廃止

・ImageControl
　・_LINE_/_BOX_/_CIRCLE_/_TRIANGLE_/_TEXT_/_FILL_/_CLEAR_/_PIXEL_/_COMPARE_コマンドを追加

・CharControl
　・空文字列を受けた時、widthを１とした
　・縁文字のオフセット処理他を廃止した
　・charactorプロパティをcharに改名

・Tsukasa
　・cursor_x/cursor_yはmouse_x/mouse_yに改名（ハードの絶対値を取得／設定する）
　・_SAVE_/_LOAD_/_LOAD_NATIVE_コマンドをControlからTsukasaに移動
　・_SYSTEM_/_LOCAL_/_TEMP_をTsukasaからしか取得できないように変更

・ClickableLayoutControl
　・条件判定にcursor_on/offを追加
　・mouse_pos_x/yを読み取り専用プロパティcursor_x/yに変更（相対座標）
　・読み取り専用プロパティcursor_offset_x/cursor_offset_yを追加

・TileMapControl
　・_SET_IMAGE_/_SET_IMAGE_MAPPING_/_SET_TILE_コマンドを、ロジックを修正した上で_ADD_TILE_/_ADD_TILE_GROUP_/_MAP_STATUS_に改名
　・サイズ初期値を32,32に設定
　・画像共有しないをデフォルトとした（キャッシュ機構が不完全なため）

・標準ユーザー定義コマンド
　・ファイルダイアログ関連：_OPEN_FILENAME_/_SAVE_FILENAME_/_FOLDER_DIALOG_
　・ウィンドウ操作関連：_RESIZE_/_FULL_SCREEN_/_RUNNING_TIME_/_SCREEN_MODES_（組み込みコマンドから変更）/_FPS_
　・ウィンドウ情報取得：_WINDOW_STATUS_（cursor_type/caption/icon_pathをtsukasaから集約）
　・インターフェイス操作関連：_INPUT_UPDATE_/_MOUSE_WHEEL_POS_/_PAD_ARROW_（_PAD_コマンドから変更）/_PAD_CONFIG_/_CURSOR_VISIBLE_（また、cursor_visibleプロパティをシステム変数に変更）
　・_CAPTURE_SS_を組み込みから変更
　・_LABEL_の内部変数を変更（ロジックも刷新）
　・_CURSOR_VISIBLE_を_MOUSE_ENABLE_に改名
　・button/TextButton/TextWindowを_IMAGE_BUTTON_/_TEXT_BUTTON_/_TEXT_WINDOW_に改名
　・pause/line_pause/end_pauseを_PAUSE_/_LINE_PAUSE_/_END_PAUSE_に改名


v1.1.0(2016/1/8)

・Controlクラス
　・追加コマンド
　　・_LOAD_NATIVE_：ネイティブrubyコードの読み込み。
　　・_NEXT_LOOP_：_LOOP_の特殊版
　　・_PARSE_：tks/司スクリプトをパースする
　　・_QUICK_SAVE_ / _QUICK_LOAD_ ：クイックセーブ／ロードを実現するメカニズム。　・追加条件判定項目
　　・command_stack / not_command_stack（旧command）
　　・システム全体の判定を行うsystemを追加。
　　　・key_down/key_up/right_key_down/right_key_up
　　　・block_given/requested_close(mouseから移動)
　・機能追加／変更
　　・_TO_IMAGE_コマンド：任意の拡大率でImageControlを作れるようにした
　　・_YILED_コマンド：付与ブロック無しに呼びだされた場合は例外で落とすようにした
　　・_INCLUDE_コマンド：任意のparserクラスをオプションで指定できるようにした
　　・条件判定で単一要素を渡す際に、[]で囲まなくても良いようにした。
　　・_PARSER_データストア追加

・TextPageControlクラス
　・文字間待機、行間待機をユーザー定義関数で定義する形式に変更
　・文字レンダラをユーザー定義関数で定義する形式に変更（それに伴い_CHAR_RENDERER_コマンドを削除）
　・TextPageControlのwait_frame/line_feed_wait_frame各プロパティを廃止。

・ImageControlクラス
　・_SAVE_IMAGE_（ImageControl）：ImageControlを画像保存する

・司スクリプト
　・_TEMP_/_SYSYTEM_/_LOCAL_の各データストアをスクリプト上から直接参照できるようにした。
　・データストア_TEMP_/_LOCAL_/_SYSTEM_にそれぞれ_T_/_L_/_S_の短縮名を用意した

・標準テキストウィンドウ
　・構造を簡略化し、背景画像を廃止した。
　・左クリックでウェイトスキップされるようにした。
　・ページ送りアイコンの表示にend_page/epユーザー定義コマンドを用いる物とした（これにともないpage_pauseを廃止）
　・スキップ時にクリック待ちアイコンを表示しないように修正
　・ユーザー定義コマンド追加
　・_SEND_TO_ACTIVE_LINE_：テキストウィンドウのアクティブ行にコマンドを送信する

・追加ユーザー定義コマンド
　・_LABEL_：既読フラグ管理機能（これに伴いlabel組み込みコマンドを削除）
　・_CAPTURE_SS_：組み込みからユーザー定義に変更

・サンプルコード
　・ランチャーを用意
　・既読フラグ管理のサンプルコードを追加
　・シリアライズのサンプルコードを追加
　・サンプルゲームにあおいたくさんの「野メイド」移植版を追加

v1.0.0(2015/12/24)　1stリリース
