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

class HorrorShader < Tsukasa::Shader

  def texelSize()
    @shader.texelSize[1]
  end

  def mode()
    @shader.mode
  end
  def mode=(arg)
    @shader.mode = arg
  end

  def duration()
    @shader.duration
  end
  def duration=(arg)
    @shader.duration = arg
  end

  def count()
    @shader.count
  end
  def count=(arg)
    @shader.count = arg
  end

  def wavePhaseU()
    @shader.wavePhaseU
  end
  def wavePhaseU=(arg)
    @shader.wavePhaseU = arg
  end

  def wavePhaseV()
    @shader.wavePhaseV
  end
  def wavePhaseV=(arg)
    @shader.wavePhaseV = arg
  end

  def waveAmpU()
    @shader.waveAmpU
  end
  def waveAmpU=(arg)
    @shader.waveAmpU = arg
  end

  def waveAmpV()
    @shader.waveAmpV
  end
  def waveAmpV=(arg)
    @shader.waveAmpV = arg
  end

  def waveLength()
    @shader.waveLength
  end
  def waveLength=(arg)
    @shader.waveLength = arg
  end

  def wave_amp_u()
    @shader.wave_amp_u
  end
  def wave_amp_u=(arg)
    @shader.wave_amp_u = arg
  end

  def wave_amp_v()
    @shader.wave_amp_v
  end
  def wave_amp_v=(arg)
    @shader.wave_amp_v = arg
  end

  def wave_speed_u()
    @shader.wave_speed_u
  end
  def wave_speed_u=(arg)
    @shader.wave_speed_u = arg
  end

  def wave_speed_v()
    @shader.wave_speed_v
  end
  def wave_speed_v=(arg)
    @shader.wave_speed_v = arg
  end

  def wave_length()
    @shader.wave_length
  end
  def wave_length=(arg)
    @shader.wave_length = arg
  end

  def initialize(system,
    duration: 60, 
    wave_amp_u: 2.0, 
    wave_amp_v: 2.0, 
    wave_length: 16.0, 
    wave_speed_u: 1.25, 
    wave_speed_v: 1.0,
    width:0, height:0, 
    **options, 
    &block)
    @shader = HorrorText.new(duration, wave_amp_u, wave_amp_v, wave_length, 
    wave_speed_u, wave_speed_v, width, height)
    @shader.count = @shader.mode == 0 ? 0 : @shader.duration 
    super
  end

  def check_mode
    @shader.mode == 0 && @shader.count < @shader.duration || @shader.mode == 1 && @shader.count > 0
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

    attr_accessor :count
    attr_accessor :duration
    attr_accessor :mode
    attr_accessor :wave_amp_u
    attr_accessor :wave_amp_v
    attr_accessor :wave_phase_u
    attr_accessor :wave_phase_v
    attr_accessor :wave_length
    attr_accessor :wave_speed_u
    attr_accessor :wave_speed_v
      
    def initialize(duration = 60, wave_amp_u = 1.0, wave_amp_v = 0.0, wave_length = 8.0, 
                   wave_speed_u = 1.0, wave_speed_v = 1.0,
                   width, height)
      super(@@core, "ScanShift")
      @count     = 0
      @duration  = duration
      @mode      = 0
      @wave_amp_u   = wave_amp_u
      @wave_amp_v   = wave_amp_v
      @wave_phase_u = 0
      @wave_phase_v = 0
      @wave_length  = wave_length
      @wave_speed_u = wave_speed_u
      @wave_speed_v = wave_speed_v
      self.waveAmpU      = 2.0
      self.waveAmpV      = 2.0
      self.wavePhaseU    = 0
      self.wavePhaseV    = 0
      self.waveLength    = 4500.0
      self.texelSize = 1.0 / width, 1.0 / height
    end
  end
end

