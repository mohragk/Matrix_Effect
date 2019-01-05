float symbolSize = 16;
float timeElapsed = 0;
float time = 0;

PVector lastMousePos;
PVector mouseDirection;

PGraphics pre;
PGraphics gfx;
PGraphics pass1;
PGraphics pass2;
PGraphics pass3;

PShader blur;
PShader shine;

PFont font;

Stream[] streams;

ADSR radiusEnvelope;


int rows;

void setup()
{
  size(1024, 720, P2D);
  //fullScreen(P2D);
  
  setupGraphics();
  
  lastMousePos = new PVector(0,0, 0);
  mouseDirection = new PVector (1.0, 1.0);
  
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

void setupGraphics()
{
  pre = createGraphics(width, height, P2D);
  gfx = createGraphics(width, height, P2D);
  
  blur = loadShader("blur.glsl");
  shine = loadShader("sineShine.glsl");
  
  pass1 = createGraphics(width, height, P2D);
  pass1.noSmooth();  
 
  pass2 = createGraphics(width, height, P2D);
  pass2.noSmooth();
  
  pass3 = createGraphics(width, height, P2D);
  pass3.noSmooth();
  
  //blur.set("blurSize", 7);
  //blur.set("sigma", 6);
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

void setBlurAmount(float amt)
{
  int size = floor(amt * 20) + 1;
  float sigma = (amt * 8.0) + 1.0 ;
  
  blur.set("blurSize", size);
  blur.set("sigma", sigma); 
}



void setMouseDirection()
{
  float easing = 0.05;
  float dx = mouseX - lastMousePos.x;
  lastMousePos.x += dx * easing;
  
  float dy = mouseY - lastMousePos.y;
  lastMousePos.y += dy * easing;
  

  float angle = atan(dx/dy);
  mouseDirection = PVector.fromAngle(angle + PI * 0.5);
}

void draw()
{
  background(0);
  shine.set("clear", 0);
  fill(255);
  rect(30, 20, 240, 320);
  
  float dis = PVector.dist(new PVector(mouseX, mouseY), lastMousePos);
  float blurAmount = map(dis, 0, 120, 0, 1);
  setBlurAmount(blurAmount);
  
  if (gfx != null) {gfx.textFont(font);}
  gfx.beginDraw();
  gfx.background(0);
  for (int i =0 ; i < streams.length; i++)
  {
    streams[i].update(timeElapsed);
    streams[i].render(timeElapsed);
  }
  gfx.endDraw();
  
  
  pre.beginDraw();
  pre.image(gfx, 0,0);
  pre.endDraw();
  
  setMouseDirection();
  
  blur.set("horizontalPass", 1);
  blur.set("mouseDir_x", mouseDirection.x);
  blur.set("mouseDir_y", mouseDirection.y);
  pass1.beginDraw();
  pass1.image(gfx, 0,0);
  pass1.shader(blur);
  pass1.endDraw();
  
  
  /*
  blur.set("horizontalPass", 0);
  pass2.beginDraw();
  pass2.shader(blur);
  pass2.image(pass1,0,0);
  pass2.endDraw();
  */
  
  //float alp = millis() / 1000;
  //amt = radiusEnvelope.getOutput() * 0.5;
  
  
  
  float amt = radiusEnvelope.getOutput();
  shine.set("time", amt);
  
  pass3.beginDraw();
  pass3.image(pass1, 0,0);
  pass3.shader(shine);
  pass3.endDraw();

  
  
  image(pass3,0,0);
  //image(pre, 0,0);
  //blend(pre, 0,0, width, height, 0,0, width,height, ADD ); 
  
  
  
  timeElapsed = 1 / frameRate;
  time += 0.01;
  
  shine.set("clear", 1);
}
