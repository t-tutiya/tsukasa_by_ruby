#! ruby -E utf-8

###############################################################################
#TSUKASA for DXRuby ver2.1(2016/12/23)
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

class HorrorShader < Tsukasa::Control
  #Imageのキャッシュ機構の簡易実装
  #TODO:キャッシュ操作：一括クリア、番号を指定してまとめて削除など
  @@image_cache = Hash.new
  #キャッシュされていない画像パスが指定されたら読み込む
  @@image_cache.default_proc = ->(hsh, key) {
    hsh[key] = DXRuby::Image.load(key)
  }

  attr_reader :entity
=begin
  #ルールトラジンション：ルール画像設定
  attr_reader :path
  def path=(path)
    @path = path
    #画像ファイルをキャッシュから読み込んで初期化する
    @entity = TransitionShader.new(@@image_cache[path])
  end

  #ルールトランジション：カウンター
  attr_reader :counter
  def counter=(arg)
    @counter = arg
    @entity.g_min =(( @vague + 255).fdiv(255) *
                          @counter - 
                          @vague
                        ).fdiv(255)

    @entity.g_max =( ( @vague + 
                            255
                          ).fdiv(255) *
                          @counter
                        ).fdiv(255)
  end
=end
  #ルールトランジション：曖昧さ
#  attr_accessor :vague

  def initialize(options, yield_stack, root_control, parent_control, &block)
#    @vague = options[:vague] || 40
#    self.path = options[:path] if options[:path]
#    self.counter = options[:counter] || 0

    #画像ファイルをキャッシュから読み込んで初期化する
    @entity = HorrorText.new(2.0, 2.0, 16.0, 1.25, 1.0, 640, 200)

    super
  end
  
  def update(mouse_pos_x, mouse_pos_y, index)
    @entity.update
    super
  end

  class HorrorText < DXRuby::Shader
      # シェーダコアのHLSL記述
      hlsl = <<EOS
      // (1) グローバル変数
          float waveAmpU;
          float waveAmpV;
          float wavePhaseU;
          float wavePhaseV;
          float waveLength;
          float2  texelSize;
          texture tex0;

      // (2) サンプラ
          sampler Samp0 = sampler_state
          {
              MipFilter = LINEAR;
              MinFilter = LINEAR;
              MagFilter = LINEAR;
              AddressU  = Clamp;
              AddressV  = Clamp;
              Texture =<tex0>;
          };

      // (3) 入出力の構造体
          struct PixelIn
          {
              float2 UV : TEXCOORD0;
          };
          struct PixelOut
          {
              float4 Color : COLOR0;
          };

      // (4) ピクセルシェーダのプログラム
          PixelOut PS_P0_Main(PixelIn input)
          {
              PixelOut output;
     
              output.Color  = tex2D(Samp0, input.UV) * 0.75f;
     
              float ampU = sin(radians(input.UV.x * waveLength + wavePhaseU)) * texelSize.x;
              float ampV = sin(radians(input.UV.x * waveLength + wavePhaseV)) * texelSize.y;
              
              // エフェクト処理
              input.UV.x += ampU * waveAmpU;
              input.UV.y += ampV * waveAmpV;

              // フィルター処理
              float2 offsetU = float2(texelSize.x, 0);
              float2 offsetV = float2(0, texelSize.y);
                       
              output.Color += tex2D(Samp0, input.UV + offsetU) * 0.09f;
              output.Color += tex2D(Samp0, input.UV - offsetU) * 0.09f;
              output.Color += tex2D(Samp0, input.UV + offsetU * 2) * 0.05f;
              output.Color += tex2D(Samp0, input.UV - offsetU * 2) * 0.05f;
              output.Color += tex2D(Samp0, input.UV + offsetV) * 0.19f;
              output.Color += tex2D(Samp0, input.UV + offsetV * 2) * 0.17f;
              output.Color += tex2D(Samp0, input.UV + offsetV * 3) * 0.15f;
              output.Color += tex2D(Samp0, input.UV + offsetV * 4) * 0.13f;
              output.Color += tex2D(Samp0, input.UV + offsetV * 5) * 0.11f;
              output.Color += tex2D(Samp0, input.UV + offsetV * 6) * 0.09f;
              output.Color += tex2D(Samp0, input.UV + offsetV * 7) * 0.07f;
              output.Color += tex2D(Samp0, input.UV + offsetV * 8) * 0.05f;

              //output.Color = tex2D(Samp0, input.UV);
             
              return output;
          }

      // (5) technique定義
          technique ScanShift
          {
              pass P0
              {
                  PixelShader = compile ps_2_0 PS_P0_Main();
              }
          }
EOS
    # シェーダコアの作成
    @@core = DXRuby::Shader::Core.new(
    hlsl,{
          :waveAmpU     => :float,
          :waveAmpV     => :float,
          :wavePhaseU   => :float,
          :wavePhaseV   => :float,
          :waveLength   => :float,
          :center       => :float,
          :texelSize    => :float,
          :blurPower    => :float,
       }
    )

    attr_accessor :duration
      
    def initialize(wave_amp_u = 1.0, wave_amp_v = 0.0, wave_length = 8.0, 
                   wave_speed_u = 1.0, wave_speed_v = 1.0,
                   width, height)
      super(@@core, "ScanShift")
      self.waveAmpU      = 2.0
      self.waveAmpV      = 2.0
      self.wavePhaseU    = 0
      self.wavePhaseV    = 0
      self.waveLength    = 4500.0
      self.texelSize = 1.0 / width, 1.0 / height
    end
      
    def update
      self.wavePhaseU = (self.wavePhaseU + 1.25) % 360
      self.wavePhaseV = (self.wavePhaseV + 1.0) % 360
    end

  end

end

