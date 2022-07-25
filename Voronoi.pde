
class Cell{
  Point site;
  ArrayList<vEdge> cellEdges = new ArrayList<vEdge>();
  
   Cell( Point _site ){
     site = _site; 
   }
}

class vEdge{
 
  Edge e;
  Cell c1, c2;
      
   vEdge( Edge _e, Cell _c1, Cell _c2 ){
     e = _e;
     c1 = _c1; c2 = _c2;
   }

   public String toString(){
     return this.e.toString();
   }
}

// The recursive section of the voronoi calculation function
ArrayList<Cell> calculateVoronoi(ArrayList<Point> sites){
  ArrayList<Cell> voronoi = new ArrayList<Cell>();
  
  // Base Cases
  if(sites.size() < 1){return new ArrayList<Cell>();}
  if(sites.size() == 1)
  {
    Cell single = new Cell(sites.get(0));
    voronoi.add(single);
    return voronoi;
  }
  
  ArrayList[] split = splitPoints(sites);
  ArrayList<Cell> left = calculateVoronoi(split[0]);
  ArrayList<Cell> right = calculateVoronoi(split[1]);
  
  voronoi = mergeVoronoi(left, right);
  return voronoi;
}

// The magic part of the voronoi function
ArrayList<Cell> mergeVoronoi(ArrayList<Cell> left, ArrayList<Cell> right){
  
  ArrayList<Cell> voronoi = new ArrayList<Cell>();
  ArrayList<Point> leftPoints = new ArrayList<Point>();
  ArrayList<Point> rightPoints = new ArrayList<Point>();
  
  // Point Lists of each voronoi diagrams of left and right cell lists
  for(Cell c : left){
    leftPoints.add(c.site);
    voronoi.add(c);
  }
  
  for(Cell c : right){
    rightPoints.add(c.site);
    voronoi.add(c);
  } 
  
  System.out.println("\n");
  
  // Take the convex hull of each side and create the list of points that I will be iterating through until I hit the lowest of each side
  // I.e., the "right" points ( from the highest to lowest point )  of the left convex hull
  ArrayList<Point> leftChain = rightChain(ConvexHullGraham(leftPoints));
  ArrayList<Point> rightChain = leftChain(ConvexHullGraham(rightPoints));
  
  Point leftLow = findMinY(leftChain);
  Point leftHigh = findMaxY(leftChain);
  Point rightLow = findMinY(rightChain);
  Point rightHigh = findMaxY(rightChain);
  
  // Create the first edge that I will be changing every time I increment through one of the chains
  Edge high = new Edge(leftHigh, rightHigh);
  Edge low = new Edge(leftLow, rightLow);
  
  int leftIndex = leftChain.size() - 1;
  int rightIndex = rightChain.size() - 1;
  int tempSide = -1;
  Edge tempNewSegment = null;
  Point ignoreThis = null;
  
  // Find the intersections, the next border segments and iterate edge 'high'
  while(!high.sameEdgeTest(low))
  {
    if(leftIndex == 0 && rightIndex == 0){break;}
    
    Cell LeftCell = getCell(left, high.p0);
    Cell RightCell = getCell(right, high.p1);
    
    Edge nextHalf = getHalfPlaneLine(high.p0, high.p1);
    if (ignoreThis!= null){
     nextHalf = returnBottomCut(nextHalf, ignoreThis); 
    }
    
    // Returns the new Segment, the side the segment ends on (left 0, right 1), and the ending point
    returnBorder returnData = checkIntersections(LeftCell, RightCell, nextHalf, ignoreThis);
    tempSide = returnData.side;
    tempNewSegment = returnData.newBorder;
    ignoreThis = returnData.endPoint;
    
    // Added to get circles
    // These four lines have no impact on the merging process
    Circle TempCircle = new Circle(ignoreThis, ignoreThis.getEuclidDistance(high.p0));
    Circle TempTwoCircle = new Circle(ignoreThis, ignoreThis.getEuclidDistance(high.p1));
    circles.add(TempCircle);
    circles.add(TempTwoCircle);
    
    Cell removeA = null;
    Cell removeB = null;
    
    // Based on which cell's edge I hit, "increment" (or really decrement) the corresonding point of the chain 
    if (tempSide == 0){
      removeA = getCell(voronoi, leftChain.get(leftIndex));
      if(leftIndex > 0){removeB = getCell(voronoi,leftChain.get(leftIndex - 1));}
      leftIndex--;
    } else if (tempSide == 1){
      removeA = getCell(voronoi, rightChain.get(rightIndex));
      if(rightIndex > 0){removeB = getCell(voronoi, rightChain.get(rightIndex - 1) );}
      rightIndex--;
    } else {
       System.out.println("Error - 847"); 
    }
    
    // Update the edges in the data structures or add them if they odn;t exist
    vEdge newSegment = new vEdge(tempNewSegment, LeftCell, RightCell);
    LeftCell.cellEdges.add(newSegment);
    RightCell.cellEdges.add(newSegment);
  
    if(!checkCellExists(voronoi, LeftCell)){ voronoi.add(LeftCell); }
    else {
      Cell exists_left = getCell(voronoi, LeftCell.site);
      exists_left.cellEdges = LeftCell.cellEdges;
    }
    
    if(!checkCellExists(voronoi, RightCell)){ voronoi.add(RightCell); }
    else {
      Cell exists_right = getCell(voronoi, RightCell.site);
      exists_right.cellEdges = RightCell.cellEdges;
    }
    
    voronoi = updateEdges(voronoi, removeA, removeB, ignoreThis, tempSide, tempNewSegment);
    high = new Edge(leftChain.get(leftIndex), rightChain.get(rightIndex));
  }
  
  // Do the same but for the lowest points of the two voronoi diagrams being merged
  Cell LeftCell = getCell(left, high.p0);
  Cell RightCell = getCell(right, high.p1);
  
  Edge finalEdgeSegment = getHalfPlaneLine(leftLow, rightLow);
  
  if(left.size() > 1 || right.size() > 1){
    finalEdgeSegment = returnBottomCut(finalEdgeSegment, ignoreThis);
  }
  
  vEdge finalSegment = new vEdge(finalEdgeSegment, LeftCell, RightCell);
  LeftCell.cellEdges.add(finalSegment);
  RightCell.cellEdges.add(finalSegment);
  
  voronoi = removeDuplicates(voronoi);
  return voronoi;
}

// Given the two current cells, using their half plane line (starting from where I cut the last one off), 
// and figure out which cells border it crosses first
returnBorder checkIntersections(Cell Left, Cell Right, Edge current, Point ignore)
{
  ArrayList<Point> leftIntersections = new ArrayList<Point>();
  ArrayList<Point> rightIntersections = new ArrayList<Point>();
  
  // Getting all intersections of each next cells
  for(vEdge cellEdge : Left.cellEdges)
  {
    if(cellEdge.e.intersectionTest(current)){ 
      Point cross = cellEdge.e.intersectionPoint(current); 
      if(ignore == null || !cross.samePoint(ignore)){
        leftIntersections.add(cross);
      }
    }
  }
  
  for(vEdge cellEdge : Right.cellEdges)
  {
    if(cellEdge.e.intersectionTest(current)){ 
      Point cross = cellEdge.e.intersectionPoint(current);
      if(ignore == null || !cross.samePoint(ignore)){
        rightIntersections.add(cross);
      }
    }
  }
  
  // Sort the intersections
  if (!leftIntersections.isEmpty()){Collections.sort(leftIntersections, new SortbyY());}
  if (!rightIntersections.isEmpty()){Collections.sort(rightIntersections, new SortbyY());}
  
  returnBorder temp;
  Point intersect;
  if( leftIntersections.size() != 0 && rightIntersections.size() == 0 )
  {  
    temp = new returnBorder(0);
    intersect = leftIntersections.get(leftIntersections.size() - 1);
  } 
  else if( leftIntersections.size() == 0 && rightIntersections.size() != 0 )
  { 
    temp = new returnBorder(1);
    intersect = rightIntersections.get(rightIntersections.size() - 1);
  }
  else if( leftIntersections.size() == 0 && rightIntersections.size() == 0 )
  {
    System.out.println("Error - 583");
    temp = new returnBorder(-1);
    intersect = new Point(160,199);
  }
  else if( leftIntersections.get(leftIntersections.size() - 1).p.y > rightIntersections.get(rightIntersections.size() - 1).p.y)
  {
    temp = new returnBorder(0);
    intersect = leftIntersections.get(leftIntersections.size() - 1);
  }
  else if( leftIntersections.get(leftIntersections.size() - 1).p.y < rightIntersections.get(rightIntersections.size() - 1).p.y)
  {
    temp = new returnBorder(1);
    intersect = rightIntersections.get(rightIntersections.size() - 1);
  } else {
    System.out.println("Error 495");
    temp = new returnBorder(-1);
    intersect = new Point(0,0);
  }
    
  temp.newBorder = returnTopCut(current, intersect);
  temp.endPoint = intersect;
  return temp;
}

// I noticed there was a pattern, every time you increment the left chain, you keep the left side of the edge you interesected and vice versa
// This is the function implementing that
ArrayList<Cell> updateEdges(ArrayList<Cell> voronoi, Cell A, Cell B, Point p, int side, Edge ignore)
{
  Edge cut = null;
  Edge Cross = new Edge(new Point(p.p.x - 1, p.p.y), new Point(p.p.x + 1, p.p.y));
  
  Cell a = getCell(voronoi, A.site); // Error, No intersections
  Cell b = null;
  if(B != null){b = getCell(voronoi, B.site);}
  
  Edge e = null;
  
  for(vEdge vE : a.cellEdges){
    if(vE.e.intersectionTest(Cross) && !vE.e.sameEdgeTest(ignore))
    {
        e = vE.e;
        if (side == 0){
          cut = returnLeftCut(e, p);
        } else if (side == 1){
          cut = returnRightCut(e, p); 
        } else {
          System.out.println("Error - 395"); 
        }
        vE.e = cut;
    }
  }
  
  if(b != null){
    for(vEdge vE : b.cellEdges){
      if(vE.e.intersectionTest(Cross) && !vE.e.sameEdgeTest(ignore))
      {
          e = vE.e;
          if (side == 0){
            cut = returnLeftCut(e, p);
          } else if (side == 1){
            cut = returnRightCut(e, p); 
          } else {
            System.out.println("Error - 201"); 
          }
          vE.e = cut;
      }
    }
  }
  
  return voronoi;
}


ArrayList<Cell> removeDuplicates(ArrayList<Cell> voronoi)
{
  for(int i = 0; i < voronoi.size() - 1; i++)
  {
    for(int j = 0; j < voronoi.size() - 1; j++)
    {
      if(i != j)
      {
        if(voronoi.get(i).site.samePoint(voronoi.get(j).site)){ voronoi.remove(j); return voronoi; }
      }
    }
  }
  
  return voronoi;
}

Point findMinY(ArrayList<Point> pointList)
{
  Collections.sort(pointList, new SortbyY());
  return pointList.get(0);
}

Point findMaxY(ArrayList<Point> pointList)
{
  Collections.sort(pointList, new SortbyY());
  return pointList.get(pointList.size() - 1);
}
