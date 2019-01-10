

float symbolSize = 18;
float timeElapsed = 0;
float time = 0;

float frequency = 12;

PVector lastMousePos;
PVector mouseDirection;

PGraphics gfx;
PGraphics blurPass;
PGraphics shinePass;
PGraphics orbPass;

PGraphics orbMask;

PShader blur;
PShader shine;
PShader orb;

PFont font;

Stream[] streams;

Envelope radiusEnvelope;

OrbSound oSound;




int rows;

void setup()
{
  //size(1024, 720, P2D);
  fullScreen(P2D);
  
  frameRate(60);
  
  setupGraphics();
  
  lastMousePos = new PVector(mouseX, mouseY, 0);
  mouseDirection = new PVector (1.0, 1.0);
  
  rows = (int)width / (int)symbolSize;
  streams = new Stream[rows];
  radiusEnvelope = new Envelope(
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
  
  oSound = new OrbSound(this);
  
}

void setupGraphics()
{
  gfx = createGraphics(width, height, P2D);
  
  blur = loadShader("blur.glsl");
  shine = loadShader("sineShine.glsl");
  orb = loadShader("orb.glsl");
  
  blurPass = createGraphics(width, height, P2D);
  blurPass.noSmooth();  
 
  shinePass = createGraphics(width, height, P2D);
  shinePass.noSmooth();
  
  orbPass = createGraphics(width, height, P2D);
  orbPass.noSmooth();
  
  orbMask = createGraphics(width, height, P2D);
  
}

void mousePressed()
{
  for (int i =0 ; i < streams.length; i++)
  {
    streams[i].mouseIsPressed();
  }
  
  oSound.mouseIsPressed();
  noCursor();
}

void mouseReleased()
{
  for (int i =0 ; i < streams.length; i++)
  {
    streams[i].mouseIsReleased();
  }
  
  oSound.mouseIsReleased();
  
  cursor(HAND);
}

float getPhaseIncrement(float hz)
{
  return hz / 60; 
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
  float easing = 0.13;
  float dx = mouseX - lastMousePos.x;
  lastMousePos.x += dx * easing;
  
  float dy = mouseY - lastMousePos.y;
  lastMousePos.y += dy * easing;
  
  PVector mouse = new PVector(mouseX, mouseY);
  mouse.sub(lastMousePos);
  mouse.normalize();
  
  mouseDirection = mousePressed ? new PVector(-mouse.x, mouse.y) : new PVector(0.0, 0.0);
}



void draw()
{
  background(0);
  
  // Main Matrix Symbol rendering
  gfx.beginDraw();
  gfx.textFont(font);
  gfx.background(0);
  
  for (int i =0 ; i < streams.length; i++)
  {
    streams[i].update(timeElapsed);
    streams[i].render(timeElapsed);
  }
  
  gfx.endDraw();
 
 
  
  float dis = PVector.dist(new PVector(mouseX, mouseY), lastMousePos);
  float blurAmount = map(dis, 40, 160, 0, 1);
  setBlurAmount(blurAmount);
  
  setMouseDirection();
   
  blur.set("mouseDir_x", mouseDirection.x);
  blur.set("mouseDir_y", mouseDirection.y);


  blurPass.beginDraw();
  blurPass.shader(blur);
  blurPass.image(gfx, 0,0);
  blurPass.endDraw();

  float mx = float(mouseX);// map(mouseX, 0, width, 0, 1);
  float my = float(mouseY);//map(mouseY, 0, height, 1, 0);
  
  orb.set("mousePos", mx, my);
  
  float rad = 0.0;
  
  if (radiusEnvelope.currentState == adsrStates.env_attack ||
      radiusEnvelope.currentState == adsrStates.env_sustain)
  {
    rad = map(radiusEnvelope.getOutput(), 0.0, 1.0, 0, width/100.) ;
  }
  
  
  orb.set("radius", rad);
  orb.set("time", time);
   
  orbPass.beginDraw();
  orbPass.shader(orb);
  orbPass.image(blurPass, 0,0);
  orbPass.endDraw();
  

  
  float amt = radiusEnvelope.getOutput();
  shine.set("amplitude", amt);
  shine.set("time", time);
  
  float br = mousePressed? map(dis, 0.0, 200.0, 1, 3) : 1.0;
  shine.set("brightness", br);
  
  shine.set("resolution", float(width), float(height));
  
  shinePass.beginDraw();
  shinePass.image(orbPass, 0,0);
  shinePass.shader(shine);
  shinePass.endDraw();


  
  image(shinePass,0,0);


  
  oSound.setIntensity(dis);
  oSound.render(timeElapsed);
  
  timeElapsed = 1 / frameRate;
  frequency = oSound.currentFreq;
  time += getPhaseIncrement(frequency);
  
  fill(255, 12, 12);
  text(frameRate, 40, 40);
  
  
}
