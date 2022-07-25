class Edge{
  
   Point p0,p1;
      
   Edge( Point _p0, Point _p1 ){
     p0 = _p0; p1 = _p1;
   }
   
   void draw(){
     line( p0.p.x, p0.p.y, 
           p1.p.x, p1.p.y );
   }
   
   void drawDotted(){
     float steps = p0.distance(p1)/6;
     for(int i=0; i<=steps; i++) {
       float x = lerp(p0.p.x, p1.p.x, i/steps);
       float y = lerp(p0.p.y, p1.p.y, i/steps);
       //noStroke();
       ellipse(x,y,3,3);
     }
  }
   
   public String toString(){
     return "<" + p0 + "" + p1 + ">";
   }
   
   boolean intersectionTest( Edge other ){
     PVector v1 = PVector.sub( other.p0.p, p0.p );
     PVector v2 = PVector.sub( p1.p, p0.p );
     PVector v3 = PVector.sub( other.p1.p, p0.p );
     
     float z1 = v1.cross(v2).z;
     float z2 = v2.cross(v3).z;
     
     if( (z1*z2)<0 ) return false;  

     PVector v4 = PVector.sub( p0.p, other.p0.p );
     PVector v5 = PVector.sub( other.p1.p, other.p0.p );
     PVector v6 = PVector.sub( p1.p, other.p0.p );

     float z3 = v4.cross(v5).z;
     float z4 = v5.cross(v6).z;
     
     if( (z3*z4<0) ) return false;  
     
     return true;  
   }
   
   Point intersectionPoint( Edge other ){
     PVector P0 = p0.p;
     PVector P1 = other.p0.p;
     PVector D  = PVector.sub( p1.p, p0.p );
     PVector Q  = PVector.sub( other.p1.p, other.p0.p );
     PVector R  = PVector.sub( P1, P0 );
     
     float u = R.cross(D).z / D.cross(Q).z;
     if( u < 0 || u > 1 ) return null;
     
     float t = 0;
     if( abs(D.x) > abs(D.y) )
       t = (R.x + Q.x*u) / D.x;
     else
       t = (R.y + Q.y*u) / D.y;

     if( t < 0 || t > 1 ) return null;
     
     PVector P = PVector.add( P1, PVector.mult( Q, u ) );
     
     return new Point( P );     
   }
   
   Point getMidpoint()
   {
     float midpointX = (this.p1.p.x + this.p0.p.x) / 2;
     float midpointY = (this.p1.p.y + this.p0.p.y) / 2;
     return (new Point(midpointX, midpointY));
   }
   
  // Tests whether two edge objects refer to the same edge despite precision errors up to a threshold 
  boolean sameEdgeTest( Edge other ){
    if (this.p0.p == other.p0.p && this.p1.p == other.p1.p){
        return true;
    }
    if (this.p0.p == other.p1.p && this.p1.p == other.p0.p){
        return true;
    }
    if (this.p0.p.x - other.p0.p.x < 0.01 && this.p0.p.y - other.p0.p.y < 0.01 && this.p1.p.x - other.p1.p.x < 0.01 && this.p1.p.y - other.p1.p.y < 0.01){
        return true;
    }
    if (this.p0.p.x - other.p1.p.x < 0.01 && this.p0.p.y - other.p1.p.y < 0.01 && this.p1.p.x - other.p0.p.x < 0.01 && this.p1.p.y - other.p0.p.y < 0.01){
        return true;
    }
    return false;
  }
}

// ------------------------------------------------------------------------------ Half Plane Line


// Taking in two points, returns the half plane that divides the space between them
// This corresponds to merging two single cell voronoi diagrams
Edge getHalfPlaneLine(Point pointA, Point pointB)
{
  ArrayList<Edge> border = new ArrayList<Edge>();
   
  int MAXSCREEN = 1000000;
  
  Edge siteBridge = new Edge(pointA, pointB);
  float bridgeX = siteBridge.p1.p.x - siteBridge.p0.p.x; 
  float bridgeY = siteBridge.p1.p.y - siteBridge.p0.p.y; 
  float riverX = bridgeY;
  float riverY = - bridgeX;
  
  // Border of the calculation to create the line segment
  Edge top = new Edge(new Point(-MAXSCREEN, MAXSCREEN), new Point(MAXSCREEN,MAXSCREEN));
  Edge right = new Edge(new Point(MAXSCREEN, -MAXSCREEN), new Point(MAXSCREEN,MAXSCREEN));
  Edge bottom = new Edge(new Point(-MAXSCREEN, -MAXSCREEN), new Point(MAXSCREEN,-MAXSCREEN));
  Edge left = new Edge(new Point(-MAXSCREEN, -MAXSCREEN), new Point(-MAXSCREEN,MAXSCREEN));
  
  border.add(top); border.add(right); border.add(bottom); border.add(left); 
  
  Point outlierA = siteBridge.getMidpoint();
  Point outlierB = siteBridge.getMidpoint();
  
  // Keep incrementing by the slope until I pass the box I make to know where I cross it
  while(!(outlierA.p.x < -MAXSCREEN || outlierA.p.y < -MAXSCREEN || outlierA.p.x > MAXSCREEN || outlierA.p.y > MAXSCREEN))
  {
    outlierA = new Point(outlierA.p.x + riverX,outlierA.p.y + riverY);
  }
  
  while(!(outlierB.p.x < -MAXSCREEN || outlierB.p.y < -MAXSCREEN || outlierB.p.x > MAXSCREEN || outlierB.p.y > MAXSCREEN))
  {
    outlierB = new Point(outlierB.p.x - riverX, outlierB.p.y - riverY);
  } 
  
  Edge outlierLine = new Edge(outlierA, outlierB);

  Point borderA = null;
  Point borderB = null;
  
  for(Edge edge : border)
  {
    if (edge.intersectionTest(outlierLine) == true)
    {
      if (borderA == null)
      {
        borderA = edge.intersectionPoint(outlierLine);
      } else {
        borderB = edge.intersectionPoint(outlierLine);
      }
    }
  }
  
  if (borderA == null || borderB == null)
  {
    System.out.println("Finding the border intersections Failed !");
  }

  Edge river = new Edge(borderA, borderB);
  return river;
}
