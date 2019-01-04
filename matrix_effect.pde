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
  radiusEnvelope = new ADSR(100.0, 10.0, width/4, 400.0);
  
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
  
  textSize(32);
  fill(255);
  text(frameRate, 100, 100);
  
  timeElapsed = 1 / frameRate;
}
