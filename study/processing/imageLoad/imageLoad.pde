
PImage img;

float rectW = 200;
float rectH = 200;

float theta  = 0;
float scaleX = 1;
float scaleY = 1;

PVector mousePreP = new PVector();
boolean isLButton = false;
boolean isRButton = false;

void mousePressed( )
{
  loop();
  mousePreP.set(mouseX, mouseY);
  if( mouseButton == LEFT ) isLButton = true;
  else if (mouseButton == RIGHT ) isRButton = true;
}

void mouseReleased( )
{
  noLoop();
  isLButton = isRButton = false;
}


/* @pjs preload="imageLoad/cat.png"; */
void setup()
{
  size(600,600, OPENGL);
  img = loadImage("imageLoad/cat.png"); 
  noLoop();
}


void draw()
{
  if( isLButton ){
    theta += 0.02   * ( mouseX - mousePreP.x );
  }
  if( isRButton ){
    scaleX += 0.01  * ( mouseX - mousePreP.x );
    scaleY += 0.01  * ( mouseY - mousePreP.y );
  }

  
  {
  pushMatrix();
    translate(300 - rectW/2,300 - rectH/2);

    translate( rectW/2, rectH/2);
    rotate( theta );
    scale(  scaleX, scaleY);
    translate(-rectW/2,-rectH/2);
      
    background(0,0,0);
    stroke(256,256,256);
    beginShape();
      texture(img);
      vertex(0    , 0    ,   0      ,   0);
      vertex(rectW, 0    , img.width,   0);
      vertex(rectW, rectH, img.width, img.height);
      vertex(0    , rectH,   0      , img.height);
    endShape();
    
    popMatrix();
  } 
  
  mousePreP.set(mouseX, mouseY);
}
