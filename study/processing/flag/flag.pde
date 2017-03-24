void setup()
{
  size( 700, 250 );
  background( 64,64,64); 
  noLoop();
}
  
  
void draw()
{
  translate( 30,30 );
  drawJapan();
  translate( 320,0 );
  drawAmerica();
}





void drawJapan()
{
  final int FLAG_W = 300;
  final int FLAG_H = 200;
  float R = FLAG_H / 2.0;
  
  stroke( 0,0,0 );
  fill  ( 255,255,255 );
  rect  ( 0,0, FLAG_W, FLAG_H);
  
  noStroke();
  fill( 288,0,45 );
  
  ellipse( FLAG_W / 2.0, FLAG_H / 2.0, R,R);
}



void drawAmerica()
{
  final int FLAG_W = 300;
  final int FLAG_H = 200;
 
 
  stroke(0,0,0,0);
  fill  (256,256,256);
  rect( 0,0, FLAG_W, FLAG_H );
  
  noStroke();
  for( int i=0; i < 13; ++i)
  {
    float h = FLAG_H / 13.0;
    if( i % 2 == 0 ) fill( 228,0,55);
    else             fill( 256,256,256);
    rect( 0, i * h, FLAG_W, h );   
  }
  
  final float RECT_W = FLAG_W * 6.0 / 13.0 ; 
  final float RECT_H = FLAG_H * 7.0 / 13.0;
  fill( 0,66,128 );
  rect( 0,0,RECT_W, RECT_H );

  float sh = RECT_H /  9.0 ;
  float sw = RECT_W / 10.0 ;
  
  fill( 256,256,256) ;
  for( int y=0; y < 9; ++y)
  {
      for( int x=0; x < 10; ++x)
      {
        if( y % 2 == 0 && x % 2 == 0 ) drawStar( x*sw, y*sh, sh );
        if( y % 2 == 1 && x % 2 == 1 ) drawStar( x*sw, y*sh, sh );
      }
  } 
}

final PVector str0 = new PVector( cos(PI/2             ), -sin(PI/2) );
final PVector str1 = new PVector( cos(PI/2 + PI/5.0*2.0), -sin(PI/2 + PI/5.0*2.0) );
final PVector str2 = new PVector( cos(PI/2 + PI/5.0*4.0), -sin(PI/2 + PI/5.0*4.0) );
final PVector str3 = new PVector( cos(PI/2 + PI/5.0*6.0), -sin(PI/2 + PI/5.0*5.0) );
final PVector str4 = new PVector( cos(PI/2 + PI/5.0*8.0), -sin(PI/2 + PI/5.0*8.0) );
void drawStar( float x, float y, float r )
{
  pushMatrix();
  translate(x + .5 * r, y + .5 * r);
  scale( 0.5 * r, 0.5 * r);
  beginShape();
  vertex(str0.array());
  vertex(str2.array());
  vertex(str4.array());
  vertex(str1.array());
  vertex(str3.array());
  endShape( CLOSE );
  popMatrix();
}
