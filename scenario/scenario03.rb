#! ruby -E utf-8

###############################################################################
#TSUKASA for DXRuby α１
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

procedure :log,
  impl: <<"EOS"
    [[:create, {:create => :ImageControl,
      :file_path => options[:file_path], 
      :x_pos =>     0, 
      :y_pos =>     0, 
      :id =>       :test}]]
EOS

#log file_path: "./sozai/bg_sample.png"


create :ImageControl ,
       file_path: "./sozai/bg_sample.png", x_po: 0, y_pos: 0, 
       id: :BG do
  move offset_x: 300,offset_y: 0, frame: 60, offset: true
  transition_fade frame: 200,
                  count: 0,
                  start: 0,
                  last: 255
  wait_command :move_line
  move offset_x: -100, offset_y: 0, frame: 60, offset: true
end

create :LayoutContainer,
  x_pos: 0,
  y_pos: 0,
  width: 300,
  height: 300,
  id: :main_text_layer do

  #ボタンコントロール
  create :ButtonControl, x_pos: 0, y_pos: 0, id: :button2 do
          create :ImageControl, 
                 :file_path=>"./sozai/button_normal.png", 
                 :id=>:normal
          create :ImageControl, 
                :file_path=>"./sozai/button_over.png", 
                :id=>:over
          create :ImageControl, 
                :file_path=>"./sozai/button_key_down.png", 
                :id=>:key_down
          create :ImageControl, 
                :file_path=>"./sozai/button_key_up.png", 
                :id=>:key_up do
  #                flag :key=>1, :data=>true
                end
          create :ImageControl, 
                :file_path=>"./sozai/button_out.png", 
                :id=>:out
  end
end



#ボタンコントロール
create :ButtonControl, :x_pos => 0, :y_pos => 0, :id=>:button1 do
        create :ImageControl, 
               :file_path=>"./sozai/button_normal.png", 
               :id=>:normal
        create :ImageControl, 
              :file_path=>"./sozai/button_over.png", 
              :id=>:over
        create :ImageControl, 
              :file_path=>"./sozai/button_key_down.png", 
              :id=>:key_down
        create :ImageControl, 
              :file_path=>"./sozai/button_key_up.png", 
              :id=>:key_up do
#                flag :key=>1, :data=>true
              end
        create :ImageControl, 
              :file_path=>"./sozai/button_out.png", 
              :id=>:out
end

next_frame

WHILE "true", target_control: :button1 do
  move_line x: 300, y: 0,   count:0, frame: 60, start_x: 0,   start_y: 0
  move_line x: 300, y: 300, count:0, frame: 60, start_x: 300, start_y: 0
  move_line x: 0,   y: 300, count:0, frame: 60, start_x: 300, start_y: 300
  move_line x: 0,   y: 0,   count:0, frame: 60, start_x: 0,   start_y: 300
end










create :LayoutContainer,
  x_pos: 128,
  y_pos: 528,
  width: 1024,
  height: 600,
  id: :main_text_layer do
    #メッセージウィンドウ
    create :CharContainer, 
      id: :default_text_layer,
      font_config: { :size => 32, 
                     :face => "ＭＳＰ ゴシック"},
      style_config: { :wait_frame => 2,} do
      char_renderer do
      	transition_fade frame: 30,
          count: 0,
          start: 0,
          last: 255
        sleep_frame
        transition_fade frame: 60,
          count: 0,
          start: 255,
          skip: 255,
          last:128
      end
    end
end

next_frame

ailias :ailias_test do
  text "土"
  text "屋"
  text "つかさです"
end

ailias_test

text "ＡＤＶエンジン「司（Tsukasa）」のα１バージョンを"
line_feed
text "ひとまず公開します。"
pause
sleep_frame
text "画像データをどこかにアップしておければ良い"
line_feed
text "のですが難しいかもしれません。"
pause
sleep_frame
text "間に合わなかったらごめんなさい。"
line_feed
pause
sleep_frame
flash

text "「司（Tsukasa）」は、土屋つかさが考えている「ゲームのアーキテクチ"
line_feed
text "ャというのはこういうモデルなのではないか」という仮説を検証する為"
line_feed
text "に開発しているＡＤＶエンジンです。"
pause
sleep_frame
text "将来的にはＡＤＶに限定せず、デジタ"
line_feed
text "ルゲーム全体のサポートができるようになれば良いと思っています。"
pause
sleep_frame
flash

text "コードはピュアRubyで、DirectX用RubyゲームライブラリDXRubyを"
line_feed
text "使用しています。"
pause
sleep_frame
text "あくまでプロトタイプ開発を指向しており、パフォー"
line_feed
text "マンスを無視した設計になっているため、恐らく販売／頒布用には"
line_feed
text "使えないだろうと考えています。"
line_feed
pause
sleep_frame
flash

text "コントロールを組み合わせてより複雑なコントロールを作ることもでき"
line_feed
text "る「筈」で、カスタマイズされたコントロールについてもrubyを直接書"
line_feed
text "くことが比較的容易にできる「筈」です。"
pause
sleep_frame
flash

text "あるコマンド（あるいはコマンドを含んだ制御構造）が、どのステート"
line_feed
text "マシンを駆動させるかをスクリプト上で指定し、動的にコマンド群を送"
line_feed
text "信することが特徴だと考えています。"
pause
sleep_frame
text "if文やloop文も任意のステートマ"
line_feed
text "シンに送信できます"
line_feed
pause
sleep_frame
flash

text "現状ではロジックを成立させるためのコア部分しか実装してない為、"
line_feed
text "ＡＤＶを作ることは困難ですが、今後機能を追加していきたいと思"
line_feed
text "います。"
pause
sleep_frame
text "スクリプトも最終的には吉里吉里ライクの物を実装したい"
line_feed
text "です。"
pause
sleep_frame
line_feed
text "ではでは～"
line_feed
pause
sleep_frame
flash

EVAL "pp 'text'"
text "true1"
IF "false" do
  THEN do
    EVAL "pp 'true3'"
  end
  ELSE do
    EVAL "pp 'false4'"
    #text "test"
  end
end

#wait_command :move_line

#move offset_x: 300,offset_y: 0, frame: 60, offset: true, target_control: :BG

#move offset_x: 300,offset_y: 0, frame: 60, offset: true, target_control: :button1

