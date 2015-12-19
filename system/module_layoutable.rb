#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver1.0(2015/12/24)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
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

module Layoutable

  #座標
  attr_accessor  :x
  attr_accessor  :y

  #オフセット座標
  attr_accessor  :offset_x
  attr_accessor  :offset_y

  #可視フラグ
  attr_accessor  :visible

  #次のコントロールの接続方向指定
  attr_accessor  :float_x
  attr_accessor  :float_y

  #寄せ指定
  attr_accessor  :align_y

  #サイズ
  attr_accessor  :width
  attr_accessor  :height

  #実サイズ（現状ではtext_page_controlのみで使用）
  attr_accessor  :real_width
  attr_accessor  :real_height

  #コリジョンのエンティティ
  attr_accessor  :collision_shape

  #カラーキー設定
  def colorkey=(arg)
    @colorkey = find_control(arg)[0]
  end

  def initialize(argument, options, inner_options, root_control)
    @x = options[:x] || 0 #描画Ｘ座標
    @y = options[:y] || 0 #描画Ｙ座標

    @offset_x = options[:offset_x] || 0 #描画オフセットＸ座標
    @offset_y = options[:offset_y] || 0 #描画オフセットＹ座標

    @real_width = @width  = options[:width] || 0 #幅
    @real_height = @height = options[:height] || 0 #高さ

    #可視フラグ（省略時はtrue）
    @visible = (options[:visible] != false)

    #次コントロールの接続方向指定
    @float_x = options[:float_x]
    @float_y = options[:float_y]

    #下寄せ指定
    @align_y = options[:align_y] || :none

    @collision_shape = options[:collision_shape]
    
    self.colorkey = options[:colorkey] if options[:colorkey]

    @collision_sprite = Sprite.new
    if @collision_shape
      @collision_sprite.collision = @collision_shape
    else
      @collision_sprite.collision = [0, 0, @width-1, @height-1]
    end

    @mouse_sprite = Sprite.new
    @mouse_sprite.collision = [0, 0]

    @over = false
    @out = true

    @old_cursol_x = @old_cursol_y = nil
    
    @mouse_pos_x = 0
    @mouse_pos_y = 0

    super
  end

  def update()
    @on_mouse_over  = false
    @on_mouse_out   = false

    @on_key_down    = false
    @on_key_down_out= false
    @on_key_up      = false
    @on_key_up_out  = false

    @on_right_key_down    = false
    @on_right_key_down_out= false
    @on_right_key_up      = false
    @on_right_key_up_out  = false

    #マウスカーソル座標を取得
    @mouse_sprite.x = @cursol_x = @mouse_pos_x
    @mouse_sprite.y = @cursol_y = @mouse_pos_y

    #前フレームと座標が異なる場合on_mouse_moveイベントを実行する
    @on_mouse_move = (@old_cursol_x != @cursol_x)or(@old_cursol_y != @cursol_y)

    #カーソル座標を保存する
    @old_cursol_x = @cursol_x
    @old_cursol_y = @cursol_y

    @collision_sprite.x = @x
    @collision_sprite.y = @y

    #マウスカーソルがコリジョン範囲内に無い
    if not (@mouse_sprite === @collision_sprite)
      inner_control = false
    #マウスカーソルがコリジョン範囲内にあるがカラーキーボーダー内に無い
    elsif @colorkey and (@colorkey.entity[@cursol_x - @x, @cursol_y - @y][0] < @colorkey.border)
      inner_control = false
    #マウスカーソルがコリジョン範囲内にある
    else
      inner_control = true
    end

    if inner_control
      #イベント起動済みフラグクリア
      @out = false

      #イベント起動前であれば起動し、クリアフラグを立てる
      @on_mouse_over = true unless @over
      @over = true

      #キー押下チェック
      if Input.mouse_push?( M_LBUTTON )
        @on_key_down = true
      end

      #キー解除チェック
      if Input.mouse_release?( M_LBUTTON )
        @on_key_up = true
      end

      #右キー押下チェック
      if Input.mouse_push?( M_RBUTTON )
        @on_right_key_down = true
      end

      #右キー解除チェック
      if Input.mouse_release?( M_RBUTTON )
        @on_right_key_up = true
      end

    else
      #イベント起動済みフラグクリア
      @over = false

      #イベント起動前であれば起動し、クリアフラグを立てる
      @on_mouse_out = true unless @out
      @out = true

      #キー押下チェック
      if Input.mouse_push?( M_LBUTTON )
        @on_key_down_out = true
      end

      #キー解除チェック
      if Input.mouse_release?( M_LBUTTON )
        @on_key_up_out = true
      end

      #右キー押下チェック
      if Input.mouse_push?( M_RBUTTON )
        @on_right_key_down_out = true
      end

      #右キー解除チェック
      if Input.mouse_release?( M_RBUTTON )
        @on_right_key_up_out = true
      end
    end

    super
  end

  #描画
  def render(offset_x, offset_y, target, parent)
    return 0, 0 unless @visible

    #次フレームのクリッカブル判定に使うマウスカーソル座標を取得
    @mouse_pos_x = parent[:mouse_pos_x]
    @mouse_pos_y = parent[:mouse_pos_y]

    #下位コントロールを上位ターゲットに直接描画
    super(offset_x, offset_y, target, 
          { :width => @width, 
            :height => @height,
            :mouse_pos_x => @mouse_pos_x - @x,
            :mouse_pos_y => @mouse_pos_y - @y
          })

    dx = dy = 0

    #連結指定チェック
    case @float_x
    #右連結
    when :left
      dx = @width
    #下連結
    when :bottom
      dx = @x
    end

    #連結指定チェック
    case @float_y
    #右連結
    when :left
      dy = @y
    #下連結
    when :bottom
      dy = @height
    end

    return dx, dy
  end
end

module Layoutable
  def check_imple(argument, options)
    if options[:mouse]
      options[:mouse].each do |key|
        case key
        #前フレと比較してカーソルが移動した場合
        when :cursor_move
          return true if @on_mouse_move

        #カーソルが指定範囲に侵入した場合
        when :cursor_over
          return true if @on_mouse_over

        #カーソルが指定範囲の外に移動した場合
        when :cursor_out
          return true if @on_mouse_out

        #マウスボタンが押下された場合
        when :key_down
          return true if @on_key_down

        #マウスボタンが範囲外で押下された場合
        when :key_down_out
          return true if @on_key_down_out

        #マウスボタン押下が解除された場合
        when :key_up
          return true if @on_key_up

        #マウスボタン押下が範囲外で解除された場合
        when :key_up_out
          return true if @on_key_up_out

        #マウス右ボタンが押下された場合
        when :right_key_down
          return true if @on_right_key_down

        #マウスボタンが範囲外で押下された場合
        when :right_key_down_out
          return true if @on_right_key_down_out

        #マウスボタン押下が解除された場合
        when :right_key_up
          return true if @on_right_key_up

        #マウスボタン押下が範囲外で解除された場合
        when :key_right_up_out
          return true if @on_key_right_up_out

        #ウィンドウの閉じるボタンが押下された場合
        when :requested_close
          return true if Input.requested_close?
        end
      end
    end 
    return super
  end

  def command__MOUSE_POS_(argument, options, inner_options)
    eval_block( argument, {:_X_ => @cursol_x, :_Y_ => @cursol_y}, 
                inner_options[:block_stack], 
                inner_options[:yield_block_stack], 
                &inner_options[:block])
  end
end
