
// Given a set of points return the convex hull polygon
Polygon ConvexHullGraham( ArrayList<Point> points ){
  ArrayList<Point> x_sorted = new ArrayList<Point> (points);
  ArrayList<Point> clock_sorted = new ArrayList<Point> (points);
  
  // If there are less than 3 points, there is no polygon possible
  Polygon cHull = new Polygon();
  if(points.size() < 3)
  { 
    for (Point p : points){
      cHull.addPoint(p);
    }
    return cHull; 
  }
  
  // Find the left most point to use as a reference
  Collections.sort(x_sorted, new SortbyX());
  Point minX = x_sorted.get(0);
  leftMost = minX;
  
  // Sort by the slope of the line between each point and the leftmost point
  clock_sorted.remove(leftMost);
  Collections.sort(clock_sorted, new SortbySlope());
  clock_sorted.add(0, leftMost);
  
  Stack<Point> stack = new Stack<Point>();
  stack.push(clock_sorted.get(0));
  stack.push(clock_sorted.get(1));
  
  // Iterate through the points only taking left turns
  for (int i = 2; i < clock_sorted.size(); i++) {
  
    Point next = clock_sorted.get(i);
    Point curr = stack.pop();
    Point prev = stack.peek();
    
    Triangle Temp = new Triangle(prev, curr, next);
    Boolean dir = Temp.ccw();
 
    if(dir){
      stack.push(curr);
      stack.push(next);
    } else {
      i--;
    }
  }
  
  stack.push(clock_sorted.get(0));
  
  for(Point p : stack)
  {
    cHull.addPoint(p);
  }
  
  return cHull;
}
