class Point {
  
   public PVector p;

   public Point( float x, float y ){
     p = new PVector(x,y);
   }

   public Point(PVector _p0 ){
     p = _p0;
   }
   
   public void draw(){
     ellipse( p.x,p.y, 12,12);
   }
   
   float getX(){ return p.x; }
   float getY(){ return p.y; }
   
   float x(){ return p.x; }
   float y(){ return p.y; }
   
   public float distance( Point o ){
     return PVector.dist( p, o.p );
   }
   
   public String toString(){
     return p.toString();
   }
   
   public Boolean samePoint(Point other){
     if (abs(this.p.x - other.p.x) < 0.1 && abs(this.p.y - other.p.y) < 0.1){ return true;}
     return false;
   }
   
   public float getEuclidDistance(Point other){
     return sqrt(pow((this.p.x - other.p.x),2) + pow((this.p.y - other.p.y),2));
   }
   
}

// Returns two Arraylists of points. The left points and the right points fairly evenly in size
ArrayList[] splitPoints(ArrayList<Point> whole){
  ArrayList<Point> former = new ArrayList<Point>();
  ArrayList<Point> latter = new ArrayList<Point>();
  
  Collections.sort(whole, new SortbyX());
  for(int i = 0; i < floor(whole.size() / 2); i++){
    former.add(whole.get(i));
  }
  for(int j = floor(whole.size() / 2); j < whole.size(); j++){
    latter.add(whole.get(j));
  }
  
  ArrayList[] split = {former, latter};
  return split;
}

// A comparator to sort points by their X coordinate
class SortbyX implements Comparator<Point>
{
  public int compare(Point a, Point b)
  {
    float temp = (a.p.x - b.p.x);
    if (temp > 0.001){ return 1; }
    if (temp < -0.001){ return -1; }
    return 0;
  }
}

// A comparator to sort points by their Y coordinate
class SortbyY implements Comparator<Point>
{
  public int compare(Point a, Point b)
  {
    
    float temp = (a.p.y - b.p.y);
    if (temp > 0.001){ return 1; }
    if (temp < -0.001){ return -1; }
    return 0;
  }
}

// A comparator to sort points by their slope based on a given point 
class SortbySlope implements Comparator<Point>
{
  public int compare(Point a, Point b)
  {
    float slopeA = (a.p.y - leftMost.p.y) / ( a.p.x - leftMost.p.x );
    float slopeB = (b.p.y - leftMost.p.y) / ( b.p.x - leftMost.p.x );
    
    float temp = (slopeA - slopeB);
    if (temp > 0.001){ return 1; }
    if (temp < -0.001){ return -1; }
    return 0;
  }
}
