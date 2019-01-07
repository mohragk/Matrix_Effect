float symbolSize = 18;
float timeElapsed = 0;
float time = 0;

PVector lastMousePos;
PVector mouseDirection;

PGraphics pre;
PGraphics gfx;
PGraphics blurPass;
PGraphics shinePass;
PGraphics orbPass;

PShader blur;
PShader shine;
PShader orb;

PFont font;

Stream[] streams;

ADSR radiusEnvelope;


int rows;

void setup()
{
  //size(1024, 720, P2D);
  fullScreen(P2D);
  
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
  orb = loadShader("sphere.glsl");
  
  blurPass = createGraphics(width, height, P2D);
  blurPass.noSmooth();  
 
  shinePass = createGraphics(width, height, P2D);
  shinePass.noSmooth();
  
  orbPass = createGraphics(width, height, P2D);
  orbPass.noSmooth();
  
  
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
  float easing = 0.09;
  float dx = mouseX - lastMousePos.x;
  lastMousePos.x += dx * easing;
  
  float dy = mouseY - lastMousePos.y;
  lastMousePos.y += dy * easing;
  
  PVector mouse = new PVector(mouseX, mouseY);
  mouse.sub(lastMousePos);
  
  mouse.normalize();
  
  
  mouseDirection = mousePressed ? new PVector(-mouse.x, mouse.y) : new PVector(0.0, 0.0);
  
  
/*
  float angle = atan(dx/dy);
  mouseDirection = PVector.fromAngle(angle + PI * 0.5);
  */
  
  
}

float[] normalizeToUV(float[] vals)
{
  vals[0] = (vals[0] / float(width) - 0.5) + 1;
  vals[1] = (vals[1] / float(height) - 0.5) + 1;
  return vals;
}

void draw()
{
  background(0);
  
  // Main Matrix Symbol rendering
  if (gfx != null) {gfx.textFont(font);}
  
  gfx.beginDraw();
  gfx.background(0);
  for (int i =0 ; i < streams.length; i++)
  {
    streams[i].update(timeElapsed);
    streams[i].render(timeElapsed);
  }
  gfx.endDraw();
  
  /*
  pre.beginDraw();
  pre.image(gfx, 0,0);
  pre.endDraw();
  */
  
  
  float dis = PVector.dist(new PVector(mouseX, mouseY), lastMousePos);
  float blurAmount = map(dis, 40, 160, 0, 1);
  setBlurAmount(blurAmount);
  
  setMouseDirection();
  
  //if (mousePressed)
  {
    blur.set("mouseDir_x", mouseDirection.x);
    blur.set("mouseDir_y", mouseDirection.y);
  }
  
  blurPass.beginDraw();
  blurPass.image(gfx, 0,0);
  blurPass.shader(blur);
  blurPass.endDraw();
  
    float ar = width / height;
  //orb.set("resolution", float(100), float(100));

  float mx = float(mouseX);// map(mouseX, 0, width, 0, 1);
  float my = float(mouseY);//map(mouseY, 0, height, 1, 0);
  
  orb.set("mousePos", mx, my);
  
  float rad = 0.0;
  
  if (radiusEnvelope.currentState == adsrStates.env_attack ||
      radiusEnvelope.currentState == adsrStates.env_sustain)
  {
    rad = map(radiusEnvelope.getOutput(), 0.0, 1.0, 0, 0.01) ;
    
  }
  orb.set("radius", rad);
  
  
  orbPass.beginDraw();
  orbPass.shader(orb);
  orbPass.image(blurPass, 0,0);
  orbPass.endDraw();
  

  
  float amt = radiusEnvelope.getOutput();
  shine.set("amplitude", amt);
  shine.set("time", time);
  
  float br = mousePressed? map(dis, 0.0, 200.0, 1, 3) : 1.0;
  shine.set("brightness", br);
  
  shinePass.beginDraw();
  shinePass.image(orbPass, 0,0);
  shinePass.shader(shine);
  shinePass.endDraw();


  
  image(shinePass,0,0);
  //image(pre, 0,0);
  //blend(pre, 0,0, width, height, 0,0, width,height, ADD ); 
  
  
  
  timeElapsed = 1 / frameRate;
  time += 0.2;
  
}
