# Vorononoi Diagram & Delaunay Triangulation :adult: :small_red_triangle:
An interactive program to create and visualize voronoi diagrams, delaunay triangulations, and some aspects of their relationship.

## Voronoi 
A voronoi diagram is at most simple description a set of points we will call "sites" and cells, each corresponding to a particular "site".<br />
Each cell is a section of a partition that contains all pixels that are closest to the corresponding site.

<kbd>
  <img src="https://user-images.githubusercontent.com/48863485/180677061-8ad45535-82aa-4a9d-b23f-65a04105f5db.png" width="800">
</kbd>

## Delaunay
First - A triangulation is where you take a polygon and add diagonals until you cut it into pieces only consisting of triangles.<br />
A Delaunay Triangulation in particular, is a special triangulation where the interior angles is minimized. <br />Additionally, another defining feature is that no point, or site, lies within a circumcircle of the triangulation. The Delaunay Triangulation is unique, if and only if there is no 4 points that lie on the same circumcircle.

<kbd>
  <img src="https://user-images.githubusercontent.com/48863485/180679978-4a86511d-b3e9-439f-b085-2dd62f4692a6.png" width="800">
</kbd>

## Relationship
These two diagrams are related in the following ways:
- Sites of the Voronoi diagram are the Delaunay nodes
- Each Voronoi vertex corresponds to a Delaunay face
- Each Voronoi edge corresponds to a Delaunay edge

<kbd>
  <img src="https://user-images.githubusercontent.com/48863485/180680080-e23acb30-6c6c-4d6c-b200-6d53382f0e92.png" width="800">
</kbd>

## Getting Started

Run  by using programming language Processing. Created and version 3.5.4.
Downloaded here https://processing.org/download

## Notes

This program was created for my Computational Geometry project at the University of South Florida and was uploaded here in retrospect.
