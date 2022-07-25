class delaunay {
  ArrayList<Edge> triEdges = new ArrayList<Edge>();
}

class Circle{
   float radius;
   Point center;
   
    public Circle(Point _center, float _radius ){
     center = _center;
     radius = _radius;
   }
}

// Generates all of the edges to a delaunay triangulation from the corresponding voronoi diagram
ArrayList<Edge> getDelaunayEdges(ArrayList<Point> points){
   ArrayList<Cell> voronoi = calculateVoronoi(points);
   ArrayList<Edge> delaunayEdges = new ArrayList<Edge>();
   
   // Make an edge for every cell site and its neighbors
   for(Cell c : voronoi)
   {
     for(vEdge vE : c.cellEdges)
     {
       if(!vE.c1.site.samePoint(c.site)){
         delaunayEdges.add(new Edge(c.site, vE.c1.site));
       } else {
         delaunayEdges.add(new Edge(c.site, vE.c2.site));
       }
     }
   }
   
   return delaunayEdges;
}
