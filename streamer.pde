
class Stream {
  int length = 18;
  String text ="";
  float x = 0;
  float y = 0;
  float interval = 0.1; //seconds
  float time = 0;
  float currentRadius = 0;

  
  
  Stream(float newX, float newY)
  {
    x = newX;
    y = newY;
  }
  
  void mouseIsPressed()
  {
    radiusEnvelope.mouseIsPressed();
  }
  
  void mouseIsReleased()
  {
    radiusEnvelope.mouseIsReleased();
  }
  
  void prepare()
  {
    y = 0;
    text = randomString();
    length = text.length();
    
    interval = random(0.01, 0.08);
  }
  
  void update(float timeElapsed)
  {
    if (time >= interval)
    {
      y += (symbolSize);
      time = 0;
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
    float rad = abs(radius);
    
    
    float distance = dist(x, y, mouseX, mouseY);    
    
    if(distance < rad)
    {    
      float factor = distance / rad;
      float displacement = (rad/4) *(1 - factor);
      
      
      p.limit(1);
      
      if (radius > 0) 
      {
        targetPos.x -= (p.x * displacement);
        targetPos.y -= (p.y * displacement);
      }
      else
      {
        targetPos.x += (p.x * displacement);
        targetPos.y += (p.y * displacement);
      }
    }

    return targetPos;
  }
  

  void render(float timeElapsed)
  {
    currentRadius = radiusEnvelope.getGatedOutput() * (width /4);
    for (int i =0; i < text.length(); i++)
    {
      int rowPos = floor(y / symbolSize);
      int charIdx = abs(i - (rowPos)) % text.length();
      
      char c = text.charAt(charIdx);
      
      colorMode(HSB, 360, 100, 100);
      color col = color(132, 92, 82);
      
      float brightness = map(interval, 0.01, 0.08, 100, 20);
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
      
      
      /*
      float targetRadius = 0;

      if (mousePressed)
      {
         targetRadius = width /4;
      }
 
      
      float speed = 1.0;
      currentRadius += (targetRadius - currentRadius) * speed * timeElapsed; 
      */
      
      

      
      PVector targetPos = getAvoidPosition(_x, _y, currentRadius);
        
      _x = targetPos.x;
      _y = targetPos.y;
    
      
      gfx.textSize(symbolSize);
      gfx.fill(col);
      gfx.text(c, _x, _y);
    }
    
  }
  
}
