public enum adsrStates{
  env_attack,
  env_decay,
  env_sustain,
  env_release,
  env_idle
}

class Envelope {
  /*
  float attackTime = 500;
  float decayTime = 200;
  float sustainLevel = 1.0;
  float releaseTime = 700;
  
  float startTime = 0;
  
  float attackEnd = 0;
  float releaseEnd = 0;
  
  float releaseStartVal = sustainLevel;
  
  boolean newTrigger = false;
  boolean startRelease = false;
  */
  
  float fps;
  
  float attackRate;
  float decayRate; 
  float releaseRate;
  
  float attackCoef;
  float decayCoef; 
  float releaseCoef;
  
  float sustainLevel;
  
  float targetRatioA;
  float targetRatioDR;
  
  float attackBase;
  float decayBase;
  float releaseBase;
  
  float output = 0;
  
  
  adsrStates currentState;
 
  
  Envelope(float aTime, float dTime, float sLevel, float rTime, float newFps)
  {
    fps =  newFps;
    
    setTargetRatioA(0.01);  // low for exponential, 100 for linear
    setTargetRatioDR(0.01); // low for exponential, 100 for linear
    
    
    setAttackRate( aTime );
    setDecayRate( dTime );
    setSustainLevel( sLevel );
    setReleaseRate( rTime );
    
    currentState = adsrStates.env_idle;
  }
  
  float calcCoef(float rate, float ratio)
  {
    return (rate <= 0) ? 0.0 : exp(-log((1.0 + ratio) / ratio) / rate); 
  }
  
  void setAttackRate(float rate)
  {
    attackRate = rate * fps;
    attackCoef = calcCoef(attackRate, targetRatioA);
    attackBase = (1.0 + targetRatioA) * (1.0 - attackCoef);
    
  }
  
  void setDecayRate(float rate)
  {
    decayRate = rate * fps;
    decayCoef = calcCoef(decayRate, targetRatioDR);
    decayBase = (sustainLevel - targetRatioDR) * (1.0 - decayCoef);
  }
  
  void setReleaseRate(float rate)
  {
    releaseRate = rate * fps;
    releaseCoef = calcCoef(releaseRate, targetRatioDR);
    releaseBase = -targetRatioDR * (1.0 - releaseCoef);
  }
  
  void setTargetRatioA(float ratio)
  {
    if (ratio < 0.00001) { ratio = 0.0001; }
    targetRatioA = ratio;
    attackCoef = calcCoef(attackRate, targetRatioA);
    attackBase = (1.0 + targetRatioA) * (1.0 - attackCoef);
  }
  
  void setTargetRatioDR(float ratio)
  {
    if (ratio < 0.00001) { ratio = 0.0001; }
    
    targetRatioDR = ratio;
    decayCoef = calcCoef(decayRate, targetRatioDR);
    releaseCoef = calcCoef(releaseRate, targetRatioDR);
    decayBase = (sustainLevel - targetRatioDR) * (1.0 - decayCoef);
    releaseBase = -targetRatioDR * (1.0 - releaseCoef);
  }
  
  void setSustainLevel(float level)
  {
    sustainLevel = level;
  }
  
  void mouseIsPressed()
  {
    gate(true);
  }
  
  void mouseIsReleased()
  {
    gate(false);
  }
  
  void gate(boolean on)
  {
    if (on)
    {
      currentState = adsrStates.env_attack;
    } else if (currentState != adsrStates.env_idle)
    {
      currentState = adsrStates.env_release;
    }
    
  }
  
  float getGatedOutput()
  {
    switch (currentState) 
    {
      case env_idle:
        break;
        
      case env_attack:
        output = attackBase + output * attackCoef;
        if (output >= 1.0)
        {
          currentState = adsrStates.env_decay;
        }
        break;
        
      case env_decay:
        output = decayBase + output * decayCoef;
        if  (output <= sustainLevel)
        {
          output = sustainLevel;
          currentState = adsrStates.env_sustain; 
        }
        break;
        
      case env_sustain:
        output = sustainLevel;
        break;
        
      case env_release:
         output = releaseBase + output * releaseCoef;
         
         if (output <= 0.0)
         {
           output = 0.0;
           currentState = adsrStates.env_idle;
         }
         break;
    }
    
    return output;
  }
  
  public float getOutput()
  {
    return output;
  }
}
