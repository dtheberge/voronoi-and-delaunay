import java.util.*;

ArrayList<Point>   points              = new ArrayList<Point>();
ArrayList<Edge>    edges               = new ArrayList<Edge>();

ArrayList<Edge>    delaunayEdges       = new ArrayList<Edge>();
ArrayList<Circle>    circles        =  new ArrayList<Circle>();
ArrayList<Cell>    voronoiDiagram      = new ArrayList<Cell>();
ArrayList<Edge>    voronoiEdges        =  new ArrayList<Edge>();

int MAXSCREEN = 1000000;

Polygon             convexHull = new Polygon();
Point               leftMost   = new Point(-MAXSCREEN, -MAXSCREEN);

boolean saveImage = false;
boolean hull = false;
boolean vdiagram = false;
boolean triangulation = false;
boolean circlesShow = false;
int numOfPoints = 4;

void generateRandomPoints(){
  for( int i = 0; i < numOfPoints; i++){
    points.add( new Point( random(100,width-50), random(100,height-50) ) );
  }
}

void calculateConvexHull(){
  convexHull = ConvexHullGraham( points );
}

void calculateDelaunayTriangulation(){
  delaunayEdges = getDelaunayEdges( points );
}

void calculateVoronoiDiagram(){
  voronoiDiagram = calculateVoronoi( points );
  voronoiEdges.clear();
  for(Cell c : voronoiDiagram){
    for(vEdge vE : c.cellEdges){
      voronoiEdges.add(vE.e);
    }
  }
}

void setup(){
  size(800,800,P3D);
  frameRate(30);
}

void draw(){
 
  background(255);
  translate( 0, height, 0);
  scale( 1, -1, 1 );
  
  strokeWeight(3);
  
  fill(0);
  noStroke();
  for( Point p : points ){
    p.draw();
  }
  
  noFill();
  stroke(100);
  for( Edge e : edges ){
    e.draw();
  }
  
   if( hull ){
    stroke( 100, 100, 100 );
    if( convexHull.ccw() ) stroke( 100, 200, 100 );
    if( convexHull.cw()  ) stroke( 200, 100, 100 ); 
    convexHull.draw();
   }
 
   stroke( 100, 200, 100 );
   if( vdiagram ){
      for( Edge e : voronoiEdges ){
        e.draw();
      }
   }
   
    stroke( 200, 100, 100 ); 
   if( triangulation ){
      for( Edge e : delaunayEdges ){
        e.draw();
      }
   }
   
   stroke( 100 );
    if( circlesShow ){
      for( Circle c : circles ){
        circle(c.center.p.x, c.center.p.y, c.radius * 2);
      }
   }
   
   stroke( 100, 100, 100 );
  
  fill(0);
  stroke(0);
  textSize(18);
  
  textRHC( "Controls", 10, height-20 );
  textRHC( "c: Clear Points", 10, height-40 );
  textRHC( "s: Save Image", 10, height-60 );
  textRHC( "h: Toggle Convex Hull", 10, height-80 );
  textRHC( "v: Toggle Voronoi Diagram", 10, height-100 );
  textRHC( "d: Toggle Delaunay Triangulation", 10, height-120 );
  textRHC( "e: Toggle Circle Relationship", 10, height-140 );
  
  //for( int i = 0; i < points.size(); i++ ){
  //  textRHC( i+1, points.get(i).p.x+5, points.get(i).p.y+15 );
  //}
  
  if( saveImage ) saveFrame( ); 
  saveImage = false;
}


void keyPressed(){
  if( key == 's' ) saveImage = true;
  if( key == 'h' ){ hull = !hull; }
  if( key == 'c' ){ points.clear(); delaunayEdges.clear(); voronoiEdges.clear(); edges.clear(); circles.clear(); 
                    hull = false; vdiagram = false; triangulation = false;}
  if( key == 'v' ){ vdiagram = !vdiagram; }
  if( key == 'd' ){ triangulation = !triangulation; }
  if( key == 'e' ){ circlesShow = !circlesShow; }
}

void textRHC( int s, float x, float y ){
  textRHC( Integer.toString(s), x, y );
}


void textRHC( String s, float x, float y ){
  pushMatrix();
  translate(x,y);
  scale(1,-1,1);
  text( s, 0, 0 );
  popMatrix();
}

Point sel = null;

void mousePressed(){
  int mouseXRHC = mouseX;
  int mouseYRHC = height-mouseY;
  
  float dT = 6;
  for( Point p : points ){
    float d = dist( p.p.x, p.p.y, mouseXRHC, mouseYRHC );
    if( d < dT ){
      dT = d;
      sel = p;
    }
  }
  
  if( sel == null ){
    sel = new Point(mouseXRHC,mouseYRHC);
    points.add( sel );
    calculateConvexHull();
    calculateVoronoiDiagram();
    calculateDelaunayTriangulation();
  }
}

void mouseDragged(){
  int mouseXRHC = mouseX;
  int mouseYRHC = height-mouseY;
  if( sel != null ){
    sel.p.x = mouseXRHC;   
    sel.p.y = mouseYRHC;
    circles.clear();
    calculateConvexHull();
    calculateVoronoiDiagram();
    calculateDelaunayTriangulation();
  }
}

void mouseReleased(){
  sel = null;
}
