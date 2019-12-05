
import java.util.*;

ArrayList<Point>    points     = new ArrayList<Point>();
ArrayList<Edge>     edges      = new ArrayList<Edge>();
ArrayList<Triangle> triangles  = new ArrayList<Triangle>();
Polygon             poly       = new Polygon();


boolean saveImage = false;
boolean showPotentialDiagonals = false;
boolean showDiagonals = false;
boolean showArtGallery = false;
boolean showVision = false;
boolean showExtensions = false;
boolean showIntersections = false;
boolean showColors = false;

boolean solveArtGallery = true;
boolean showTriangulation = false;
boolean showDual = false;
boolean showColoring = true;

boolean nowColor = false;
boolean changeColor = false;
boolean debugInfo = false;


void setup(){
  size(750,750,P3D);
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

  noStroke();
  for( Triangle t : triangles ){
    fill( 100, 100, 100 );
    if( t.ccw() ) fill( 200, 100, 100 );
    if( t.cw()  ) fill( 100, 200, 100 );
    t.draw();
  }

  stroke( 100, 100, 100 );
  //if( poly.ccw() ) stroke( 100, 200, 100 );
  //if( poly.cw()  ) stroke( 200, 100, 100 );
  poly.draw();


  if( showPotentialDiagonals ){
    strokeWeight(1);
    stroke(100,100,100);
    fill(0,0,200);
    for( Edge e : poly.getPotentialDiagonals() ){
        e.drawDotted();
    }
  }

  if( showDiagonals ){
    strokeWeight(4);
    stroke(100,100,200);
    for( Edge e : poly.getDiagonals() ){
        e.draw();
    }
  }

  fill(0);
  stroke(0);
  textSize(18);

  textRHC( "Controls", 10, height-20 );
  textRHC( "r: Reset", 10, height-40 );
  textRHC( "t: Show triangulation", 10, height-60 );
  textRHC( "d: Show dual", 10, height-80 );
  textRHC( "c: Show coloring", 10, height-100 );
  textRHC( "g: Show guard covering (current guard shown by black crosshairs)", 10, height-120 );
  textRHC( "v: Show view from a different guard", 10, height-140 );



  textRHC( "Clockwise: " + (poly.cw()?"True":"False"), 550, 80 );
  textRHC( "Counterclockwise: " + (poly.ccw()?"True":"False"), 550, 60 );
  textRHC( "Closed Boundary: " + (poly.isClosed()?"True":"False"), 550, 40 );
  textRHC( "Simple Boundary: " + (poly.isSimple()?"True":"False"), 550, 20 );

  for( int i = 0; i < points.size(); i++ ){
    textRHC( i, points.get(i).p.x+5, points.get(i).p.y+15 );
  }

  if( saveImage ) saveFrame( );
  saveImage = false;

  // ---------- Art Gallery ---------------
  if (solveArtGallery && poly.isSimple()){
    poly.earClipping();
    ArrayList<Point> colorAnswer = poly.getDual();
    if (showTriangulation){
     poly.drawTriangulation();
    }
    if (showDual){
     poly.drawDual();
    }
    if (showColoring){
     poly.drawColoring();
    }
   //----------- Coloring ----------   
    if (nowColor){
      poly.viewColor(colorAnswer);
    }
  }
}

void keyPressed(){
  // reset
  if( key == 'r' ) {
    poly.p.clear();
    poly.bdry.clear();
    points.clear();
    triangles.clear();
    edges.clear();
    showDual = false;
    showColors = false;
    nowColor = false;
    showPotentialDiagonals = false;
    showDiagonals = false;
    showTriangulation = false;
  }
  if( key == 't' ) showTriangulation = !showTriangulation;
  if( key == 'd' ) showDual = !showDual;
  if( key == 'c' ) showColors = !showColors;
  // change to different guard
  if( key == 'v' ) changeColor = !changeColor;
  // show guard view
  if( key == 'g' ) {
    nowColor = !nowColor;
  }
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
    poly.addPoint( sel );
  }
}

void mouseDragged(){
  int mouseXRHC = mouseX;
  int mouseYRHC = height-mouseY;
  if( sel != null ){
    sel.p.x = mouseXRHC;
    sel.p.y = mouseYRHC;
  }
}

void mouseReleased(){
  sel = null;
}
