import ddf.minim.*;
import ddf.minim.ugens.*;


class orbSound 
{
  float amplitude = 0.25;
  
  ADSR env;
  Minim minim;
  AudioOutput out;
  Oscil lfo;
  
  Noise noise;
  MoogFilter lpf;
  
  float lpfFrequency, lpfMod;
  
  PApplet p;
  
  
  orbSound(PApplet p)
  {
    this.p = p;
    
    if(init())
    {
      println("orbSound succesfully created");
    }
  }
  
  void mouseIsPressed()
  {
   env.gate(true);
  }
  
  void mouseIsReleased()
  {
    env.gate(false);
  }
  
  boolean init()
  {
    
    minim = new Minim(p);
    out = minim.getLineOut();
    
    noise = new Noise(0.2, Noise.Tint.PINK);
    
    lfo = new Oscil(4, 0.4, Waves.SINE);
    lfo.patch(noise.amplitude);
  
    lpf = new MoogFilter(600, .2);
    
    
    
    noise.patch(lpf).patch(out);
    
    env = new ADSR(0.5, 0.7, 1.0, 0.5, 60);
    
    
    return true;
  }
  
  void setIntensity(float amount)
  {
    
    float reso = amount / (width * 0.25);
    
    reso = constrain(reso, 0, 1);
    //lpf.resonance.setLastValue(reso);
    
    lpfMod = amount;
    
  }
  
  void render()
  {
    float a = env.getGatedOutput();
    lfo.amplitude.setLastValue(a);
    
    float f = map(a, 0, 1, 20, 200);
    lpfFrequency = f + lpfMod;
    lpf.frequency.setLastValue(lpfFrequency);
    
   
  }
}
