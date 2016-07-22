#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver1.2.1(2016/5/2)
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

  attr_accessor  :colorkey_id
  attr_accessor  :colorkey_border

  attr_reader :cursor_x
  attr_reader :cursor_y

  attr_reader :cursor_offset_x
  attr_reader :cursor_offset_y

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
  def initialize(options, yield_block_stack, root_control, parent_control, &block)
    @collision_shape = options[:collision_shape]

    @colorkey_id = options[:colorkey_id]
    @colorkey_border = options[:colorkey_border] || 255

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

    @mouse_x = @mouse_y = 0

    super
  end

  #描画
  def update(mouse_pos_x, mouse_pos_y, index)
    mouse_pos_x -= check_align_x()
    mouse_pos_y -= check_align_y()

    @inner_control = false
    @on_mouse_over  = false
    @on_mouse_out   = false

    @on_key_push    = false
    @on_key_down    = false
    @on_key_down_out= false
    @on_key_up      = false
    @on_key_up_out  = false

    @on_right_key_push    = false
    @on_right_key_down    = false
    @on_right_key_down_out= false
    @on_right_key_up      = false
    @on_right_key_up_out  = false

    #前フレームとのカーソル座標更新差分を取得
    @cursor_offset_x = mouse_pos_x - @mouse_x
    @cursor_offset_y = mouse_pos_y - @mouse_y
    @mouse_x = mouse_pos_x
    @mouse_y = mouse_pos_y

    #カーソルが移動しているかどうかのフラグを格納
    @on_cursor_move = !((@cursor_offset_x == 0) and (@cursor_offset_y == 0))

    #カーソル座標を保存する
    @cursor_x = @mouse_sprite.x = mouse_pos_x - @x
    @cursor_y = @mouse_sprite.y = mouse_pos_y - @y

    #コリジョン図形の位置を補正
    @collision_sprite.x = @offset_x
    @collision_sprite.y = @offset_y

    #windowがアクティブで無ければ衝突判定をせずに終了
    return super unless Window.active?

    #マウスカーソル座標との衝突判定
    if not (@mouse_sprite === @collision_sprite)
      #マウスカーソルがコリジョン範囲内に無い
      @inner_control = false
    elsif @colorkey_id and (find_control(@colorkey_id).entity[mouse_pos_x - @x, mouse_pos_y - @y][0] <= @colorkey_border)
      #マウスカーソルがコリジョン範囲内にあるがカラーキーボーダー内に無い
      @inner_control = false
    else
      #マウスカーソルがコリジョン範囲内にある
      @inner_control = true
    end

    if @inner_control
      #イベント起動済みフラグクリア
      @out = false

      #イベント起動前であれば起動し、クリアフラグを立てる
      @on_mouse_over = true unless @over
      @over = true

      #キー継続押下チェック
      @on_key_down = Input.mouse_down?( M_LBUTTON )
      #キー押下チェック
      @on_key_push = Input.mouse_push?( M_LBUTTON )
      #キー解除チェック
      @on_key_up = Input.mouse_release?( M_LBUTTON )
      #キー継続押下チェック
      @on_right_key_down = Input.mouse_down?( M_RBUTTON )
      #右キー押下チェック
      @on_right_key_push = Input.mouse_push?( M_RBUTTON )
      #右キー解除チェック
      @on_right_key_up = Input.mouse_release?( M_RBUTTON )
    else
      #イベント起動済みフラグクリア
      @over = false

      #イベント起動前であれば起動し、クリアフラグを立てる
      @on_mouse_out = true unless @out
      @out = true

      #キー押下チェック
      @on_key_down_out = Input.mouse_down?( M_LBUTTON )
      #キー解除チェック
      @on_key_up_out = Input.mouse_release?( M_LBUTTON )
      #右キー押下チェック
      @on_right_key_down_out = Input.mouse_down?( M_RBUTTON )
      #右キー解除チェック
      @on_right_key_up_out = Input.mouse_release?( M_RBUTTON )
    end

    return super
  end

  def check_imple(argument, options, yield_block_stack)
    if options[:mouse]
      Array(options[:mouse]).each do |key|
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
        when :key_push
          return true if @on_key_push

        #マウスボタンが継続押下されている合
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
        when :right_key_push
          return true if @on_right_key_push

        #マウス右ボタンが継続押下されている場合
        when :right_key_down
          return true if @on_right_key_down

        #マウスボタンが範囲外で押下された場合
        when :right_key_down_out
          return true if @on_right_key_down_out

        #マウスボタン押下が解除された場合
        when :right_key_up
          return true if @on_right_key_up

        #マウスボタン押下が範囲外で解除された場合
        when :right_key_up_out
          return true if @on_right_key_up_out

        end
      end
    end 
    return super
  end
end
