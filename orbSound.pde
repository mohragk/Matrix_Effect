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
  MoogFilter hpf;
 
  
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
    
    noise = new Noise(0.5, Noise.Tint.PINK);
    
    lfoFreq = 9;
    
    lfo = new Oscil(lfoFreq, 0.001, Waves.SINE);
    lfo.patch(noise.amplitude);
  
    lpf = new MoogFilter(600, .5);
    hpf = new MoogFilter(80, 0.7);
    hpf.type = MoogFilter.Type.HP;
        
    
    noise.patch(hpf).patch(lpf).patch(out);
    
    env = new Envelope(0.5, 0.7, 1.0, 0.5, 60);
    
    
    return true;
  }
  
  void setIntensity(float amount)
  {
    
    lfoMod = amount/ (width * 0.5);
   
    lpfMod = mousePressed ? amount * 3 : 0;
  
  }
  
  float lastFreq;
  float lastGain;
  float lastLfoFreq;
  
  void render(float timeElapsed)
  {
    
    float a = env.getGatedOutput() * 0.95;
    
    Line gainControl = new Line(timeElapsed, lastGain, a);
    
    gainControl.patch(lfo.amplitude);
    
    float f = map(a, 0, 1, 20, 200);
    lpfFrequency = f + lpfMod;
    
    Line freqControl = new Line(timeElapsed, lastFreq, lpfFrequency);
    freqControl.patch(lpf.frequency);
    
    
    
    
    float lfoF = lfoFreq / (lfoMod + 1);
    Line lfoFreqControl = new Line(timeElapsed, lastLfoFreq, lfoF);
    lfoFreqControl.patch(lfo.frequency);
   
    //lfo.frequency.setLastValue(lfoF);
    
    lastFreq = lpfFrequency;
    lastLfoFreq = lfoF;
    lastGain = a;
    
   
  }
}
