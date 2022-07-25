class returnBorder{
  int side;
  Edge newBorder;
  Point endPoint;
  
  int intersectedIndex;
  int secondaryIndex;
  Edge intersected;
  
   returnBorder(int _side ){
     side = _side;
   }
}

// -------------------------------------------------------------------------------- Cuts

// Return the top side of an edge based on a point
Edge returnTopCut(Edge edge, Point point)
{
  Point higher;
  if (edge.p0.p.y > edge.p1.p.y){ higher = edge.p0; }
  else { higher = edge.p1; }
  
  Edge top = new Edge(higher, point);
  return top;
}

// Return the bottom side of an edge based on a point
Edge returnBottomCut(Edge edge, Point point)
{
  Point lower;
  if (edge.p0.p.y < edge.p1.p.y){ lower = edge.p0; }
  else { lower = edge.p1; }
  
  Edge top = new Edge(point, lower);
  return top;
}

// Return the left side of an edge based on a point
Edge returnLeftCut(Edge edge, Point point)
{
  Point left;
  if (edge.p0.p.x < edge.p1.p.x){ left = edge.p0; }
  else { left = edge.p1; }
  
  Edge leftSide = new Edge(left, point);
  return leftSide;
}

// Return the right side of an edge based on a point
Edge returnRightCut(Edge edge, Point point)
{
  Point right;
  if (edge.p0.p.x > edge.p1.p.x){ right = edge.p0; }
  else { right = edge.p1; }
  
  Edge leftSide = new Edge(point, right);
  return leftSide;
}

// -------------------------------------------------------------------------------- Get Cell and Check Cell

// Retrieve a Cell with a particular given site
Cell getCell(ArrayList<Cell> cells, Point site)
{
  for(Cell c : cells)
  {
     if(c.site.samePoint(site)){
       return c;
     }
  }
  
  // This should never be run
  System.out.println("Error - 374");
  Scanner scanner = new Scanner(System.in);
  String error = scanner.next();
  scanner.close();
  return new Cell(new Point(0,0));
}

// Check if a cell exists with a given particular site
Boolean checkCellExists(ArrayList<Cell> voronoi, Cell cell)
{
  for(Cell c : voronoi)
  {
    if (c.site.samePoint(cell.site))
    {
      return true;
    }
  }
  
  System.out.println("Error - 801");
  return false;
}

// -------------------------------------------------------------------------------- Left and Right Chains of ConvexHull

// Given a polygon, compute the convex polygon, return the chain from the top point to the lowest on the left side of the polygon
ArrayList<Point> leftChain(Polygon poly){
  ArrayList<Point> Hull = new ArrayList<Point>(poly.p);
  ArrayList<Point> SortY = new ArrayList<Point>(poly.p);
  ArrayList<Point> leftChain = new ArrayList<Point>();
  
  // Sort Hull Points by Y Value and get the highest and lowest points wo changing the order of the hull
  Collections.sort(SortY, new SortbyY());
  Point high = SortY.get(SortY.size() - 1);
  Point low = SortY.get(0);
  
  // Remove the duplicate point
  for(int k = 0; k < Hull.size(); k++){
   Point current = Hull.get(k);
   
   for (int m = 0; m < Hull.size(); m++){
      Point dup = Hull.get(m);
      if(k != m && current.samePoint(dup)){
        Hull.remove(k); 
      }
   }
  }
  
  int indexHigh = 0;
  int indexLow = 0;
  
  for(int i = 0; i < Hull.size(); i++ ){
    if (Hull.get(i).samePoint(high)){ indexHigh = i; }
    if (Hull.get(i).samePoint(low)){ indexLow = i; }
  }
  
  //Triangle up = new Triangle(Hull.get(indexHigh), Hull.get((indexHigh + 1) % Hull.size()), Hull.get((indexHigh + 2) % Hull.size()));
  //Triangle down = new Triangle(Hull.get(indexHigh), Hull.get((indexHigh - 1 + Hull.size()) % Hull.size()), Hull.get((indexHigh - 2 + Hull.size()) % Hull.size()));
  
  for(int j = indexHigh; j != indexLow ; j = (j + 1) % Hull.size()){
    leftChain.add(Hull.get(j));
  }
  
  leftChain.add(Hull.get(indexLow));
  return leftChain;
}

// Given a polygon, compute the convex polygon, return the chain from the top point to the lowest on the right side of the polygon
ArrayList<Point> rightChain(Polygon poly){
  ArrayList<Point> Hull = new ArrayList<Point>(poly.p);
  ArrayList<Point> SortY = new ArrayList<Point>(poly.p);
  ArrayList<Point> rightChain = new ArrayList<Point>();
  
  // Sort Hull Points by Y Value and get the highest and lowest points wo altering the order of the Hull
  Collections.sort(SortY, new SortbyY());
  Point high = SortY.get(SortY.size() - 1);
  Point low = SortY.get(0);
  
  // Remove the duplicate point
  for(int k = 0; k < Hull.size(); k++){
   Point current = Hull.get(k);
   
   for (int m = 0; m < Hull.size(); m++){
      Point dup = Hull.get(m);
      if(k != m && current.samePoint(dup)){
        Hull.remove(k); 
      }
   }
  }
  
  int indexHigh = 0;
  int indexLow = 0;
  
  for(int i = 0; i < Hull.size(); i++ ){
    if (Hull.get(i).samePoint(high)){ indexHigh = i; }
    if (Hull.get(i).samePoint(low)){ indexLow = i; }
  }
  
  //Triangle up = new Triangle(Hull.get(indexHigh), Hull.get((indexHigh + 1) % Hull.size()), Hull.get((indexHigh + 2) % Hull.size()));
  //Triangle down = new Triangle(Hull.get(indexHigh), Hull.get((indexHigh - 1 + Hull.size()) % Hull.size()), Hull.get((indexHigh - 2 + Hull.size()) % Hull.size()));
  
  for(int j = indexHigh; j != indexLow ; j = (j - 1 + Hull.size()) % Hull.size()){
    rightChain.add(Hull.get(j));
  }
  rightChain.add(Hull.get(indexLow));
  return rightChain;
}

void drawChain(ArrayList<Point> chain){
    for(int i = 0; i < chain.size() - 1; i++){
      Edge temp = new Edge(chain.get(i), chain.get(i+1));
      edges.add(temp);
    }
}

// -------------------------------------------------------------------------------- Display Voronoi

void displayVoronoi(ArrayList<Point> pointList)
{
  ArrayList<Cell> voronoi = calculateVoronoi(pointList);
  for(Cell c : voronoi){
    
    System.out.println("%%%% Corresponding Cell: " + c.site);
    for(vEdge vE : c.cellEdges){
      System.out.println("*** Final Cell Edge: " + vE.e + ", sites : " + vE.c1.site + ", " + vE.c2.site);
      edges.add(vE.e);
    }
  }
}
