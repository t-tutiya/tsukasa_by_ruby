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

module Clickable

  #コリジョンのエンティティ
  attr_accessor  :collision_shape

  #カラーキー設定
  def colorkey=(arg)
    @colorkey = arg
    @colorkey_control = find_control(@colorkey)
  end
  attr_reader :colorkey

  def initialize(options, yield_block_stack, root_control, &block)
    @collision_shape = options[:collision_shape]
    
    self.colorkey = options[:colorkey] if options[:colorkey]

    witdh = options[:width] || 0
    height = options[:height] || 0

    @collision_sprite = Sprite.new
    if @collision_shape
      @collision_sprite.collision = @collision_shape
    else
      @collision_sprite.collision = [0, 0, 
                                      witdh-1, height-1]
    end

    @mouse_sprite = Sprite.new
    @mouse_sprite.collision = [0, 0]

    @over = false
    @out = true

    @old_cursol_x = @old_cursol_y = nil
    
    #TODO：オブジェクトの生成直後は@collision_spriteと@mouse_spriteはどちらも相対座標が[0,0]設定になっている。
    #この座標は次のrenderタイミングに更新されるため、その前に実行されるupdateタイミングでは衝突扱いになってします。
    #そのため、マウス座標を[-1, -1]に設定している。これは場当たり的な修正であり、本来はマウス座標の更新がrenderタイミングに行われているロジックを修正すべき
    @mouse_pos_x = -1
    @mouse_pos_y = -1

    super
  end

  def update(offset_x, offset_y, target, 
              parent_control_width, parent_control_height, 
              mouse_pos_x,mouse_pos_y )
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

    #前フレームと座標が異なる場合on_mouse_moveイベントを実行する
    @on_mouse_move =  ((@old_cursol_x != @mouse_pos_x) or
                      (@old_cursol_y != @mouse_pos_y))

    #カーソル座標を保存する
    @old_cursol_x = @mouse_sprite.x = @mouse_pos_x
    @old_cursol_y = @mouse_sprite.y = @mouse_pos_y

    @collision_sprite.x = @x
    @collision_sprite.y = @y

    #マウスカーソルがコリジョン範囲内に無い
    if not (@mouse_sprite === @collision_sprite)
      inner_control = false
    #マウスカーソルがコリジョン範囲内にあるがカラーキーボーダー内に無い
    elsif @colorkey and 
          (@colorkey_control.entity[@mouse_pos_x - @x, @mouse_pos_y - @y][0] < @colorkey_control.border)
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

  def check_imple(argument, options, yield_block_stack)
    if options[:mouse]
      #対象キーが配列で渡されていない場合配列に変換する
      options[:mouse] = [options[:mouse]] unless options[:mouse].instance_of?(Array)

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

        end
      end
    end 
    return super
  end
end