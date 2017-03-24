import java.util.*;

//Mesh sructure//

void setup() {
  size(250, 250);
  noLoop();
  frameRate(20);

}

void draw() 
{
  fill( 0,256, 0);
  ellipse(mouseX, mouseY, 50, 50);
  fill( 256,0,0);
  textSize(14 );
  text( "drag mouse ", 10,10,10 );
}

void mousePressed(){
  loop();
}
void mouseReleased(){
  noLoop();
}
