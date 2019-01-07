import ddf.minim.*;
import ddf.minim.ugens.*;


class OrbSound 
{
  float amplitude = 0.25;
  
  Envelope env;
  Minim minim;
  AudioOutput out;
 
  Oscil lfo;
  
  Noise noise;
  MoogFilter lpf;
  
  Delay delay;
  
  float lpfFrequency, lpfMod;
  
  PApplet p;
  
  
  OrbSound(PApplet p)
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
    
    lfo = new Oscil(12, 0.001, Waves.TRIANGLE);
    lfo.patch(noise.amplitude);
  
    lpf = new MoogFilter(600, .4);
    
    delay = new Delay( 0.15, 0.3, true, true );
    
    
    noise.patch(lpf).patch(out);
    
    env = new Envelope(0.5, 0.7, 1.0, 0.5, 60);
    
    
    return true;
  }
  
  void setIntensity(float amount)
  {
    
    float reso = amount / (width * 0.25);
    
    reso = constrain(reso, 0, 1);
    //lpf.resonance.setLastValue(reso);
    
    if(mousePressed)
    {
      lpfMod = amount * 2;
    }
    else
    {
      lpfMod = 0;
    }
    
  }
  
  float lastFreq;
  float lastGain;
  
  void render(float timeElapsed)
  {
    
    float a = env.getGatedOutput() * 0.7;
    
    Line gainControl = new Line(timeElapsed, lastGain, a);
    
    gainControl.patch(lfo.amplitude);
    
    float f = map(a, 0, 1, 20, 200);
    lpfFrequency = f + lpfMod;
    
    Line freqControl = new Line(timeElapsed, lastFreq, lpfFrequency);
    
    
    freqControl.patch(lpf.frequency);
    lastFreq = lpfFrequency;
    lastGain = a;
   
  }
}
