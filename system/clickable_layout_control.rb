#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver1.2(2016/3/1)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2016> <tsukasa TSUCHIYA>
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

class ClickableLayoutControl < LayoutControl
  #コリジョンのエンティティ
  attr_accessor  :collision_shape

  #カラーキー設定
  def colorkey=(arg)
    @colorkey = arg
    @colorkey_control = find_control(@colorkey)
  end
  attr_reader :colorkey

  attr_accessor  :cursor_x
  attr_accessor  :cursor_y

  attr_reader :cursor_offset_x
  attr_reader :cursor_offset_y

  #キー入力をスリープさせる
  attr_accessor  :clickable_sleep

  def width=(arg)
    unless @collision_shape
      @collision_sprite.collision = [ 0, 0, arg, @height]
    end
    super
  end
  def height=(arg)
    unless @collision_shape
      @collision_sprite.collision = [ 0, 0, @width, arg]
    end
    super
  end
end

class ClickableLayoutControl < LayoutControl
  def initialize(options, yield_block_stack, root_control, &block)
    @collision_shape = options[:collision_shape]
    
    self.colorkey = options[:colorkey] if options[:colorkey]

    @collision_sprite = Sprite.new

    if @collision_shape
      @collision_sprite.collision = @collision_shape
    else
      @collision_sprite.collision = [ 0, 
                                      0, 
                                      options[:width]  || 0, 
                                      options[:height] || 0]
    end

    @mouse_sprite = Sprite.new
    @mouse_sprite.collision = [0, 0]

    @over = false
    @out  = true

    @cursor_x = @cursor_y = 0

    @clickable_sleep = false

    super
  end

  #描画
  def update(mouse_pos_x, mouse_pos_y)
    @inner_control = false
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

    #前フレームとのカーソル座標更新差分を取得
    @cursor_offset_x = mouse_pos_x - @cursor_x
    @cursor_offset_y = mouse_pos_y - @cursor_y

    #カーソルが移動しているかどうかのフラグを格納
    @on_cursor_move = !((@cursor_offset_x == 0) and (@cursor_offset_y == 0))

    #カーソル座標を保存する
    @cursor_x = @mouse_sprite.x = mouse_pos_x
    @cursor_y = @mouse_sprite.y = mouse_pos_y

    @collision_sprite.x = @x + @offset_x
    @collision_sprite.y = @y + @offset_y

    #マウスカーソルがコリジョン範囲内に無い
    if not (@mouse_sprite === @collision_sprite)
      @inner_control = false
    #マウスカーソルがコリジョン範囲内にあるがカラーキーボーダー内に無い
    elsif @colorkey and 
          (@colorkey_control.entity[mouse_pos_x - @x, mouse_pos_y - @y][0] < @colorkey_control.border)
      @inner_control = false
    #マウスカーソルがコリジョン範囲内にある
    else
      @inner_control = true
    end

    if @inner_control
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

    return super
  end

  def check_imple(argument, options, yield_block_stack)
    #キー入力がスリープしている場合条件判定を飛ばす
    if @clickable_sleep
      return super
    end

    if options[:mouse]
      #対象キーが配列で渡されていない場合配列に変換する
      options[:mouse] = [options[:mouse]] unless options[:mouse].instance_of?(Array)

      options[:mouse].each do |key|
        case key
        when :cursor_on
          return true if @inner_control

        when :cursor_off
          return true unless @inner_control

        #前フレと比較してカーソルが移動した場合
        when :cursor_move
          return true if @on_cursor_move

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

        end
      end
    end 
    return super
  end
end