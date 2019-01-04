enum adsrStates{
  env_attack,
  env_decay,
  env_sustain,
  env_release,
  env_idle
}

class ADSR {
  float attackTime = 500;
  float decayTime = 200;
  float sustainLevel = 1.0;
  float releaseTime = 700;
  
  float startTime = 0;
  
  float attackEnd = 0;
  float releaseEnd = 0;
  
  float releaseStartVal = sustainLevel;
  
  float output = 0;
  boolean newTrigger = false;
  boolean startRelease = false;
  
  ADSR(float at, float dt, float sl, float rt)
  {
    attackTime = at;
    decayTime = dt;
    sustainLevel = sl;
    releaseTime = rt;
  }
  
  float calculateCoeff(float time, float ratio)
  {
    return (time <= 0) ? 0.0 : exp(-log((1.0 + ratio) / ratio) / time); 
  }
  
  void mouseIsPressed()
  {
    newTrigger = true;
  }
  
  void mouseIsReleased()
  {
    startRelease = true;
  }
  
  public float getOutput()
  {
    
        
    if (newTrigger)
    {
      startTime = millis();
      attackEnd = startTime + attackTime;
      newTrigger = false;
    }
    
    if (millis() < attackEnd)
    {
      output = map(millis(), startTime, attackEnd, 0 , sustainLevel);
    }
    
    if (startRelease)
    {
       
       releaseStartVal = output;
       startTime = millis();
       attackEnd = startTime;
       releaseEnd = startTime + releaseTime;
       
       startRelease = false;
    }
    
    if (millis() < releaseEnd)
    {
      output = map(millis(), startTime, releaseEnd, releaseStartVal, 0);
    }
    return output;
  }
}
