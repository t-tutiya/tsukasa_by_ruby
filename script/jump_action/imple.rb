#! ruby -E utf-8

require 'dxruby'

class MainChar < Tsukasa::Image

  #対応する配列を返す
  def collision_tile(x, y)
    return @map[y/32][x/32] #マップ配列の仕様上、ｘとｙが逆になっているのに注意
  end

  def initialize(system, options)

    #マップデータ
    @map = [[1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
            [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 1],
            [1, 0, 0, 1, 1, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1],
            [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1],
            [1, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 1],
            [1, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1],
            [1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1],
            [1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1],
            [1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1],
            [1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1]]

    super
  end

  def _CHECK_LANDING_(options)
    #床衝突判定
    if collision_tile(@x   , @y+31) == 1 or 
       collision_tile(@x+31, @y+31) == 1
      @y = @y/32*32
      #ブロックを実行する
      unshift_command_block(options)
    end
  end

  def _ADDJUST_ROOF_(options)
    #天井衝突判定
    if collision_tile(@x   , @y   ) == 1 or 
       collision_tile(@x+31, @y   ) == 1
      @y = @y/32*32 + 32
    end
  end

  def _ADDJUST_WALL_(options)
    #壁衝突判定（左側）
    if    collision_tile(@x   , @y   ) == 1 or 
          collision_tile(@x   , @y+31) == 1
      @x = @x/32*32 + 32
    #壁衝突判定（右側）
    elsif collision_tile(@x+31, @y   ) == 1 or 
          collision_tile(@x+31, @y+31) == 1 
      @x = @x/32*32
    end
  end
end