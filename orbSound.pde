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
  
  float lpfFrequency, lpfMod, lfoFreq, lfoMod;
  
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
    
    lfoFreq = 9;
    
    lfo = new Oscil(lfoFreq, 0.001, Waves.TRIANGLE);
    lfo.patch(noise.amplitude);
  
    lpf = new MoogFilter(600, .5);
    
    delay = new Delay( 0.15, 0.3, true, true );
    
    
    noise.patch(lpf).patch(out);
    
    env = new Envelope(0.5, 0.7, 1.0, 0.5, 60);
    
    
    return true;
  }
  
  void setIntensity(float amount)
  {
    
    lfoMod = amount / 300;
    
    if(mousePressed)
    {
      lpfMod = amount * 3;
    }
    else
    {
      lpfMod = 0;
    }
    
  }
  
  float lastFreq;
  float lastGain;
  float lastLfoFreq;
  
  void render(float timeElapsed)
  {
    
    float a = env.getGatedOutput() * 0.7;
    
    Line gainControl = new Line(timeElapsed, lastGain, a);
    
    gainControl.patch(lfo.amplitude);
    
    float f = map(a, 0, 1, 20, 200);
    lpfFrequency = f + lpfMod;
    
    Line freqControl = new Line(timeElapsed, lastFreq, lpfFrequency);
    freqControl.patch(lpf.frequency);
    
    
    float lfoF = lfoFreq / (lfoMod + 1);
    lfo.frequency.setLastValue(lfoF);
    
    lastFreq = lpfFrequency;
    lastGain = a;
    
   
  }
}
