import java.util.*;


class TEdge{
  int[] v = new int[2];
  TEdge(int v0, int v1){
    v[0] = v0;
    v[1] = v1;
  }
};


class TTriangle{
  int[] idx = new int[3];
  TTriangle(int v0, int v1, int v2){
    idx[0] = v0; 
    idx[1] = v1; 
    idx[2] = v2;
  }
}


//SIZE//
final int WINDOW_SIZE = 600;
final int POINT_SIZE  = 8  ;

//Mesh sructure (note Vector is not available in processing.js)//
int       vNum    = 0  ;
final int vNumMax = 40;
PVector[] verts   = new PVector[vNumMax + 3]; // + 3 for super triangle

int       pNum    = 0;
final int pNumMax = 600;
TTriangle polys[]   = new TTriangle[pNumMax];


//mouse//
int  dragVtxID = -1; // -1 --> non dragging  




void setup()
{
  size(WINDOW_SIZE, WINDOW_SIZE);
  colorMode(RGB,256);

  if( vNum < vNumMax ){  
    for( int i = 0; i < 15; ++i) verts[vNum++] = new PVector( random( WINDOW_SIZE ), random( WINDOW_SIZE ));
  }
  
  t_computeDelaunayTriangle() ;   
  frameRate(20); 
  noLoop();
}


void draw()
{
  updatePoints();  
  background(0,0,0);

  textSize(18);
  textAlign(LEFT);
  fill(0,255,255);
  text("Click to add new points", 20, 20); 

  
  stroke( 255,255,0);
  for( int i=0; i < pNum; ++i) {
    PVector p0 = verts[ polys[i].idx[0] ];
    PVector p1 = verts[ polys[i].idx[1] ];
    PVector p2 = verts[ polys[i].idx[2] ];
    
    line( p0.x, p0.y, p1.x, p1.y); 
    line( p1.x, p1.y, p2.x, p2.y);
    line( p2.x, p2.y, p0.x, p0.y);
  }

  //draw vertices
  ellipseMode( CENTER );
  stroke( 255,0,0);
  fill  ( 255,0,255);
  
  for( int i = 0; i < vNum; ++i) ellipse( verts[i].x, verts[i].y, POINT_SIZE, POINT_SIZE);
  
  
    
} 

void mouseReleased()
{
  dragVtxID = -1;
  noLoop();
}







void mousePressed()
{
  if( mouseButton == LEFT ) {
    dragVtxID = pickPoint( mouseX, mouseY );
    if( dragVtxID == -1 && vNum < vNumMax) 
    {
      verts[vNum++] = new PVector( mouseX, mouseY );
      dragVtxID = vNum - 1;
    } 
  } else if( mouseButton == CENTER ) { 
  } else if( mouseButton == RIGHT ) {
  }
  loop();
}


double distSq(final double x0, final double y0, final double x1, final double y1)
{
  return (x0 - x1) * (x0 - x1) + (y0 - y1) * (y0 - y1); 
}

int pickPoint( final int x, final int y)
{
  for( int i=0; i < vNum; ++i)
    if( distSq( x, y, verts[i].x, verts[i].y ) < POINT_SIZE * POINT_SIZE) return i;
  return -1;  
}



void updatePoints()
{
  if( dragVtxID == -1 ) return;
  verts[ dragVtxID ].set(mouseX, mouseY) ;
  
  t_computeDelaunayTriangle() ;  
}




void t_computeDelaunayTriangle( )
{
  //super triangle //
  verts[ vNum     ] = new PVector(-10000, 0     );
  verts[ vNum + 1 ] = new PVector( 10000,-10000 );
  verts[ vNum + 2 ] = new PVector( 10000, 10000 );
  
  //delaunay triangulation//
  DelaunayEdge halfEdge = new DelaunayEdge( vNum + 3 );
  halfEdge.setTriangle( vNum, vNum + 1, vNum + 2);

  for( int vi = 0; vi <vNum; ++vi) halfEdge.updateEdgeByAddingPoint( verts, vi );

  //extract triangles//
  pNum = 0;
  for(int ii=0   ; ii<vNum ; ++ii)
  for(int jj=ii+1; jj<vNum ; ++jj) if( halfEdge.m_edges[ii][jj] != -1 && ii < halfEdge.m_edges[ii][jj] && halfEdge.m_edges[ii][jj] <= vNum - 1 && pNum < pNumMax) 
  {
    polys[ pNum++ ] = new TTriangle( ii, jj, halfEdge.m_edges[ii][jj] ); 
  }
}






//  --------- DelaunayTriangle (half edge) ---------- //
class DelaunayEdge
{
  int     m_size;
  int[][] m_edges; //m_size*m_size 
  //half edge[i][j] = -1,       
  //half edge[i][j] =  i != -1, i is a ID of vertex which positioned at left side of edge ij
  //half edge[i][j] >  n        edge for out most triangle

  DelaunayEdge (int size){ 
    m_size  = size ;
    m_edges = new int[m_size][];
    for( int i = 0; i < m_size; ++i){
      m_edges[i] = new int[m_size];
      for( int j = 0 ; j < m_size; ++j ) m_edges[i][j] = -1;
    }    
  }

  void setTriangle( int i, int j, int k)
  {  
    m_edges[i][j] = k;
    m_edges[j][k] = i;
    m_edges[k][i] = j;
  }
  void removeEdge ( int i, int j       ){  
    m_edges[i][j] = -1;
    m_edges[j][i] = -1;
  }
  
  void decomposeTriangles_InTriangle( int i, int j, int k, int newPoint, ArrayList SusEs ){
    setTriangle(i, j, newPoint); 
    setTriangle(j, k, newPoint);
    setTriangle(k, i, newPoint);  
    SusEs.add(new TEdge(i, j) );
    SusEs.add(new TEdge(j, k) );
    SusEs.add(new TEdge(k, i) );
  }
  
  // new point is on the edge ij, (ij is not one of the outmost edge)
  void decomposeTriangle_OnTriangleEdge( int i, int j, int k, int newPoint, ArrayList SusEs )
  {
    int m = m_edges[j][i]; 
    removeEdge(j,i);
    setTriangle( i, m, newPoint);  setTriangle( m, j, newPoint);  
    setTriangle( j, k, newPoint);  setTriangle( k, i, newPoint);  
    SusEs.add(new TEdge(i, m) ); SusEs.add(new TEdge(m, j) );
    SusEs.add(new TEdge(j, k) ); SusEs.add(new TEdge(k, i) );
  }
  
  void flip_edge(int i, int j, ArrayList SusEs) 
  {   
    int r = m_edges[i][j];
    int k = m_edges[j][i]; 
    removeEdge(i,j);         
    setTriangle(i,k,r); 
    setTriangle(k,j,r);   
    SusEs.add( new TEdge(i, k) );
    SusEs.add( new TEdge(k, j) );
  }
  
  void updateEdgeByAddingPoint( PVector[] points, int addPtIdx)
  {
    
    ArrayList SuspisEs = new ArrayList();

    {
      boolean found = false;
      int ii = 0, jj = 0, kk = 0;
      for(int i=0   ; i<m_size; ++i)
      { 
        if( found ) break;
        for(int j=i+1; j<m_size; ++j) if( i < m_edges[i][j])
        {
          ii = i;
          jj = j; 
          kk = m_edges[ii][jj];
          if( tDel_bInTriangle( points[ii], points[jj], points[kk], points[ addPtIdx ] ) ){ found = true; break; }
        }
      }
                
      if(      tDel_bOnTriangleEdge( points[ii], points[jj], points[ addPtIdx ] ) ) decomposeTriangle_OnTriangleEdge( ii, jj, kk, addPtIdx, SuspisEs );
      else if( tDel_bOnTriangleEdge( points[jj], points[kk], points[ addPtIdx ] ) ) decomposeTriangle_OnTriangleEdge( jj, kk, ii, addPtIdx, SuspisEs );
      else if( tDel_bOnTriangleEdge( points[kk], points[ii], points[ addPtIdx ] ) ) decomposeTriangle_OnTriangleEdge( kk, ii, jj, addPtIdx, SuspisEs );
      else                                                                          decomposeTriangles_InTriangle   ( ii, jj, kk, addPtIdx, SuspisEs );
    }
    
    {
      while( SuspisEs.size() != 0 )
      {
        TEdge edge = (TEdge) SuspisEs.get( SuspisEs.size() - 1 );  
        SuspisEs.remove( SuspisEs.size() - 1 );
        int ii = edge.v[0];
        int jj = edge.v[1];
        int kk = m_edges[ii][jj];
        int rr = m_edges[jj][ii];
        if( kk != -1 && rr != -1 && tDel_bInOuterCircle( points[ii], points[jj], points[kk], points[rr] ) ) flip_edge( ii, jj, SuspisEs );
      }
    }
  }
};







boolean tDel_bInTriangle(
                  final PVector x0,
                 final PVector x1,
                final PVector x2,
               final PVector P ) 
{
  if( x0.x < P.x && x1.x < P.x &&  x2.x < P.x ) return false;
  if( x0.x > P.x && x1.x > P.x &&  x2.x > P.x ) return false;
  if( x0.y < P.y && x1.y < P.y &&  x2.y < P.y ) return false;
  if( x0.y > P.y && x1.y > P.y &&  x2.y > P.y ) return false;

  if( (x1.x-x0.x) * (P.y - x0.y) - (x1.y-x0.y) * (P.x - x0.x)  < 0 ) return false; //normal0 = x1-x0 ^ P - x0
  if( (x2.x-x1.x) * (P.y - x1.y) - (x2.y-x1.y) * (P.x - x1.x)  < 0 ) return false; //normal0 = x2-x1 ^ P - x1
  if( (x0.x-x2.x) * (P.y - x2.y) - (x0.y-x2.y) * (P.x - x2.x)  < 0 ) return false; //normal0 = x0-x2 ^ P - x2
  return true;
}

boolean tDel_bOnTriangleEdge( final PVector x0,
                              final PVector x1,
                              final PVector pivot){
  //calc (x1 - x0) ^ (pivot - x0)
  return ( (x1.x - x0.x) * (pivot.y - x0.y) - 
           (x1.y - x0.y) * (pivot.x - x0.x) < 0.00000001 ) ;
}


double LengthSq( final PVector p)
{
  return p.x * p.x + p.y * p.y; 
}



//    | a b | |s|    w1
//    | c d | |t|  = w2
boolean t_solve2by2LinearEquation(final double a,  final double b, 
                                  final double c,  final double d,  final double w1, final double w2, 
                                  double[] s, double[] t) // Are there alternative ways for this fucking arguments??
{
  double det = (a*d - b*c); 
  if(det == 0) return false;
  det = 1.0 / det;
  s[0] = (  d*w1 - b*w2 ) * det;
  t[0] = ( -c*w1 + a*w2 ) * det;
  return true;
}

boolean tDel_bInOuterCircle( final PVector x0,
                             final PVector x1,
                             final PVector x2,
                             final PVector pivot)
{
  double b0 = 0.5 * ( LengthSq( x0 ) - LengthSq( x1 ) );
  double b1 = 0.5 * ( LengthSq( x1 ) - LengthSq( x2 ) );

  double[] x = new double[1];
  double[] y = new double[1];
  if(! t_solve2by2LinearEquation( x0.x - x1.x, x0.y - x1.y, 
                                  x1.x - x2.x, x1.y - x2.y, b0, b1, x,y) ) return false;

  return  (pivot.x - x[0]) * (pivot.x - x[0]) + (pivot.y - y[0]) * (pivot.y - y[0]) < 
          (   x0.x - x[0]) * (   x0.x - x[0]) + (   x0.y - y[0]) * (   x0.y - y[0]);
}
