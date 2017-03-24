boolean isLButton = false;
boolean isRButton = false;

TriangleMesh  model = new TriangleMesh();

PVector mousePreP = new PVector();
float   theta  = PI;
float   phi    = 0 ;
float   lightX = 0;
float   lightY = 0;
float   BOX_SIZE = 1500;


void setup()
{
    println( "HELLO WORLD!!!!!!");
    size(600, 600, P3D);
    model.LoadStl( "bunny3D/bunny.stl" );
    model.Normalize( BOX_SIZE );
    noLoop();
}


void draw()
{
    if( isLButton ){
        phi    -=  (mouseX - mousePreP.x ) * 0.005;
        theta  -=  (mouseY - mousePreP.y ) * 0.005;
        mousePreP.set( mouseX, mouseY );
    }
    if( isRButton ){
        lightX = mouseX;
        lightY = mouseY;
    }

    background(0,0,0);
    ambientLight(63, 31, 31); 
    directionalLight(255,255,255,-1,0,0); 
    pointLight( 63, 127, 255, lightX, lightY, 200); 
    spotLight (100, 100, 100, lightX, lightY, 200, 0, 0, -1, PI, 2); 
    
    
    pushMatrix();
    {
        translate( width / 2, height/2, -1000);
        rotateX( theta );
        rotateY( phi   );    
        translate( -BOX_SIZE/2, -BOX_SIZE/2, -BOX_SIZE/2);
        
        drawCubeFrame( BOX_SIZE );
        
        noStroke();
        fill(255,190,200,255);
        sphere( 300 );
        model.Draw();
    }
    popMatrix();
  
    noLights();
    fill(256,256,0);
    textSize( 18 );
    int n = model.polys.size();
    String str = "polygon num : " + n;
    text( "Left  drag -- rotation"      , 10,15 ); 
    text( "Right drag -- light position" , 10,35 );
    text( str, 10,55 );
}




void mousePressed()
{
    mousePreP.set( mouseX, mouseY );
    if( mouseButton == LEFT  ) isLButton = true;
    if( mouseButton == RIGHT ) isRButton = true;
    loop();
}

void mouseReleased(){
  isLButton = isRButton = false;
  noLoop();
}











void drawCubeFrame(float r)
{
    stroke(256,256,256);  
    line( 0,0,0,  r,0,0);  line( r,0,0,  r,r,0);  line( r,r,0,  0,r,0);  line( 0,r,0,  0,0,0);
    line( 0,0,r,  r,0,r);  line( r,0,r,  r,r,r);  line( r,r,r,  0,r,r);  line( 0,r,r,  0,0,r);
    line( 0,0,0,  0,0,r);  line( r,0,0,  r,0,r);  line( r,r,0,  r,r,r);  line( 0,r,0,  0,r,r);    
}




class TTriangle{
  PVector   norm ;
  PVector[] verts;
  
  TTriangle(){
    norm = new PVector();
    verts = new PVector[3];
    for( int i=0; i < 3; ++i) verts[i] = new PVector();
  }
  
  TTriangle myClone(){
      TTriangle a = new TTriangle();
      a.norm.set( norm );
      for( int i=0; i < 3; ++i) a.verts[i].set( verts[i] );
      return a;
  }
}

class TriangleMesh
{
    ArrayList  polys  = new ArrayList();
    void LoadStl(String fpath)
    {
        polys.clear();
        TTriangle      tmpTri = new TTriangle();
        int            vNum   = 0;        
        String lines[] = loadStrings( fpath );

            for( int i=0; i < lines.length; ++i) 
            {
                String line = trim(lines[i]);
                String stl_line[] = splitTokens(line, " ,\t");
                
                if (stl_line[0].equals("facet") && stl_line[1].equals("normal")) tmpTri.norm.set( float( stl_line[2]), float( stl_line[3]), float( stl_line[4]) );                
                if (stl_line[0].equals("outer") && stl_line[1].equals("loop"  )) vNum = 0;
                if (stl_line[0].equals("vertex"  ) ) if(vNum <= 2) tmpTri.verts[ vNum++ ].set( float(stl_line[1]), float(stl_line[2]), float(stl_line[3]) ); 
                if (stl_line[0].equals("endloop" ) ) vNum =0;
                if (stl_line[0].equals("endfacet") ) polys.add( tmpTri.myClone() ); 
            }           
  
        
    }
    
    
    void Normalize( float scale)
    {
      
        PVector minP = new PVector( MAX_FLOAT, MAX_FLOAT, MAX_FLOAT);
        PVector maxP = new PVector(-MAX_FLOAT,-MAX_FLOAT,-MAX_FLOAT);

        for(int i = 0; i < polys.size(); i++)
        {  
            TTriangle t = (TTriangle) polys.get(i); 
            PVector v0 = t.verts[0], v1 = t.verts[1], v2 = t.verts[2];
            minP.x = min( minP.x, min( v0.x, v1.x, v2.x) );
            minP.y = min( minP.y, min( v0.y, v1.y, v2.y) );
            minP.z = min( minP.z, min( v0.z, v1.z, v2.z) );
            maxP.x = max( maxP.x, max( v0.x, v1.x, v2.x) );
            maxP.y = max( maxP.y, max( v0.y, v1.y, v2.y) );
            maxP.z = max( maxP.z, max( v0.z, v1.z, v2.z) );
        }
        println( minP.toString() );
        println( maxP.toString() );
        scale = scale / max(maxP.x - minP.x, maxP.y - minP.y, maxP.z - minP.z );

        for(int i = 0; i < polys.size(); i++)
        {  
            TTriangle t = (TTriangle) polys.get(i);
            for(int j = 0; j < 3; ++j){
                t.verts[j].x = scale * (t.verts[j].x - minP.x);
                t.verts[j].y = scale * (t.verts[j].y - minP.y);
                t.verts[j].z = scale * (t.verts[j].z - minP.z);
            }
        }              
        
    }
 
    void Draw(  )
    {
        ambientLight(153, 102, 0);
        ambient(51, 26, 0);
        translate(70, 50, 0);
        
        beginShape(TRIANGLES);
        for(int i = 0; i < polys.size(); i++)
        {  
            TTriangle t = (TTriangle) polys.get(i);
 
                normal( t.norm.x, t.norm.y, t.norm.z);
                vertex( t.verts[0].x, t.verts[0].y, t.verts[0].z );
                vertex( t.verts[1].x, t.verts[1].y, t.verts[1].z );
                vertex( t.verts[2].x, t.verts[2].y, t.verts[2].z );
        }
        endShape();
     
    }    
}
