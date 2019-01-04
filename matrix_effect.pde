float symbolSize = 16;
float timeElapsed = 0;

PGraphics gfx;
PFont font;

Stream[] streams;

ADSR radiusEnvelope;


int rows;

void setup()
{
  //size(1024, 720, P2D);
  fullScreen(P2D);
  
  gfx = createGraphics(width, height, P2D);
  
  rows = (int)width / (int)symbolSize;
  streams = new Stream[rows];
  radiusEnvelope = new ADSR(
    60, // attackTime 
    0, // decayTime (unused) 
    1, // sustainLevel [0.0 - 1.0]
    200, // releaseTime
    60   // fps
  );
  
  for (int i =0 ; i < streams.length; i++)
  {
    
    float newX = i * symbolSize;
    streams[i] = new Stream(newX,0);
    streams[i].prepare();
  }
   
  font = createFont("HiraginoSans-W3", symbolSize);
  
}

void mousePressed()
{
  for (int i =0 ; i < streams.length; i++)
  {
    streams[i].mouseIsPressed();
  }
}

void mouseReleased()
{
  for (int i =0 ; i < streams.length; i++)
  {
    streams[i].mouseIsReleased();
  }
}

void draw()
{
  background(0);
  
  if (gfx != null)
  {gfx.textFont(font);}
  gfx.beginDraw();
  gfx.background(0);
  for (int i =0 ; i < streams.length; i++)
  {
    streams[i].update(timeElapsed);
    streams[i].render(timeElapsed);
  }
  gfx.endDraw();
  
  image(gfx,0,0);
  
  
  timeElapsed = 1 / frameRate;
}
