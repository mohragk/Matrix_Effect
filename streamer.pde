
class Stream {
  int length = 14;
  String text ="";
  float x = 0;
  float y = 0;
  float speed = 0.1; //seconds
  float time = 0;
  float currentRadius = 0;

  
  Stream(float newX, float newY)
  {
    x = newX;
    y = newY;
  }
  
  
  void prepare()
  {
    y = 0;
    text = randomString();
    length = text.length();
    
    speed = random(0.01, 0.08);
  }
  
  void update(float timeElapsed)
  {
    if (time >= speed)
    {
      y += (symbolSize);
      time = 0;
      text = shift(text);
    }
    
    if (y - (text.length() * symbolSize) > height)
    {
      prepare();
    }
    
    flicker();
    
    time += timeElapsed;
  }
  
  String shift(String s) {
    return s.charAt(s.length()-1)+s.substring(0, s.length()-1);
  }
  

  String randomString()
  {
    int targetLength = (int)random(12, 96);
    StringBuilder buff = new StringBuilder(targetLength);
    
    for (int i = 0; i < targetLength; i++)
    {
      buff.append(randomChar());
    }
    
    return buff.toString();
  }
  
  char randomChar()
  {
//    int leftBound = 0x3041;
        int leftBound = 0x30A0;

    int rightBound = leftBound + 96;
    
    int r = (int)random(leftBound, rightBound);
    
    return (char) r;
  }
  
  void flicker()
  {
    int r = (int)random(0, 5);
    
    if (r == 0)
    {
      int idx = (int)random(2, text.length());
      char[] temp = text.toCharArray();
      temp[idx] = randomChar();
      
      text = String.valueOf(temp);
      
    }
  }
  
  
  PVector getAvoidPosition(float x, float y, float radius)
  {
    PVector targetPos = new PVector(x,y);
    
    if (radius == 0)
    {
      return targetPos;
    }
    
   
    PVector p = new PVector( mouseX-x, mouseY-y);
    
    
    float distance = dist(x, y, mouseX, mouseY);    
    
    if(distance < radius)
    {    
      float factor = distance / radius;
      float displacement = (radius/4) *(1 - factor);
      
      
      p.limit(1);
      targetPos.x -= (p.x * displacement);
      targetPos.y -= (p.y * displacement);
    }

    return targetPos;
  }
  
  
  float getDynamicRadius(float currentRadius, float targetRad, float elapsedTime)
  {
    float speed = 1.0;
    
    currentRadius += (targetRad - currentRadius) * speed * elapsedTime; 
    
    return currentRadius;
  }
  
  void render(float timeElapsed)
  {

    for (int i =0; i < text.length(); i++)
    {
      char c = text.charAt(i);
      
      colorMode(HSB, 360, 100, 100);
      color col = color(132, 92, 82);
      
      float brightness = map(speed, 0.01, 0.08, 100, 20);
      col = color(132, 92, brightness);
      
      if (i < 7)
      {
        col = color(132, 20, brightness + 10);
      }
      
      if ( i > text.length() - (text.length() /4))
      {
        col = color(132, 92, brightness - 20);
      }
      
      if (i == 0) {
        c = randomChar();
        col = color(0, 0, 100);
      } 
      
    
      float _x = x;
      float _y = y - (i * symbolSize);
      
      float targetRadius = 0;
      
      if (mousePressed)
      {
         targetRadius = width /4;
      }
      
      currentRadius = getDynamicRadius(currentRadius, targetRadius, timeElapsed);
      
      PVector targetPos = getAvoidPosition(_x, _y, currentRadius);
        
      _x = targetPos.x;
      _y = targetPos.y;
    
      
      gfx.textSize(symbolSize);
      gfx.fill(col);
      gfx.text(c, _x, _y);
    }
    
  }
  
}
