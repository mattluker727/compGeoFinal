

class Polygon {
  
   ArrayList<Point> p     = new ArrayList<Point>();
   ArrayList<Edge>  bdry = new ArrayList<Edge>();
     
   Polygon( ){  }
   
   
   boolean isClosed(){ return p.size()>=3; }
   
   int sumBdry(){
     int sumEdges =0;
     
     for (int i = 0; i < bdry.size(); i++) {
       sumEdges += (bdry.get(i).p1.p.x - bdry.get(i).p0.p.x)*(bdry.get(i).p1.p.y + bdry.get(i).p0.p.y);
     }
     
     return sumEdges;
   }
   
   
   boolean isSimple(){
     // TODO: Check the boundary to see if it is simple or not.
     ArrayList<Edge> bdry = getBoundary();
     
     // check if any boundary edges overlap
     for (int i = 0; i < bdry.size(); i++) {
       for (int j = i + 1; j < bdry.size(); j++) {
         // if non adjacent
         if(i != (j + 1) % bdry.size() && j != (i + 1) % bdry.size()){
           if (bdry.get(i).intersectionTest(bdry.get(j)) == true){
             println(i + " intersects " + j);
             return false;
           }
         }
       }
     }
     
     return true;
   }
   
   boolean degenerateLine(Edge line){
     for (int i = 0; i < p.size(); i++) {
       if (dist(line.p0.p.x, line.p0.p.y, p.get(i).p.x, p.get(i).p.y) + dist(line.p1.p.x, line.p1.p.y, p.get(i).p.x, p.get(i).p.y) == dist(line.p0.p.x, line.p0.p.y, line.p1.p.x, line.p1.p.y)){
         return true;
       }
     }
     return false;
   }
   
   
   boolean pointInPolygon( Point point ){
     // TODO: Check if the point p is inside of the 
     ArrayList<Edge> bdry = getBoundary();
     
     Point infinity = new Point(0, point.p.y);
     
     Edge lineTest = new Edge(point, infinity);
     
     // if lineTest is a degenerate case. create new lineTest, repeate until not degenerate
     while(degenerateLine(lineTest) == true){
       Point random = new Point(0, 0 + (int)(Math.random() * ((800 - 0) + 1)));
       
       lineTest = new Edge(point, random);
     }
     
     int countCrosses = 0;
     
     // count how many times line intersects boundary
     for (int i = 0; i < bdry.size(); i++) {
       if (bdry.get(i).intersectionTest(lineTest) == true){
         countCrosses++;
       }
     }
     
     if ((countCrosses & 1) == 0){
       // even
       return false;
     }
     else {
       // odd
       return true;
     }
   }
   
   boolean crossesBoundary(Edge diagonal){
     
     for (int i = 0; i < bdry.size(); i++){
       if (bdry.get(i).intersectionTest(diagonal) == true){
         if (bdry.get(i).commonPoint(diagonal) == false){
           return true;
         }
       }
     }
     
     return false;
   }
   
   
   ArrayList<Edge> getDiagonals(){
     // TODO: Determine which of the potential diagonals are actually diagonals
     ArrayList<Edge> bdry = getBoundary();
     ArrayList<Edge> diag = getPotentialDiagonals();
     ArrayList<Edge> ret  = new ArrayList<Edge>();
     
     for (int i = 0; i < diag.size(); i++) {
       // if line is outside of polygon
       Point midpoint = new Point((diag.get(i).p0.p.x + diag.get(i).p1.p.x)/2, (diag.get(i).p0.p.y + diag.get(i).p1.p.y)/2);
       
       // if diagonal doesn't cross boundary and isn't outside of polygioon, add to list of valid diagonals
       if (crossesBoundary(diag.get(i)) == false && pointInPolygon(midpoint) == true){
         ret.add(diag.get(i));
       }
     }

     return ret;
   }
   
   
   boolean ccw(){
     // TODO: Determine if the polygon is oriented in a counterclockwise fashion
     if( !isClosed() ) return false;
     if( !isSimple() ) return false;
     
     if (sumBdry() < 0){
       return true;
     }
     else{
       return false;
     }
   }
   
   
   boolean cw(){
     // TODO: Determine if the polygon is oriented in a clockwise fashion
     if( !isClosed() ) return false;
     if( !isSimple() ) return false;
     
     if (sumBdry() > 0){
       return true;
     }
     else{
       return false;
     }
   }
      
   
   
   
   ArrayList<Edge> getBoundary(){
     return bdry;
   }


   ArrayList<Edge> getPotentialDiagonals(){
     ArrayList<Edge> ret = new ArrayList<Edge>();
     int N = p.size();
     for(int i = 0; i < N; i++ ){
       int M = (i==0)?(N-1):(N);
       for(int j = i+2; j < M; j++ ){
         ret.add( new Edge( p.get(i), p.get(j) ) );
       }
     }
     return ret;
   }
   

   void draw(){
     //println( bdry.size() );
     for( Edge e : bdry ){
       e.draw();
     }
   }
   
   
   void addPoint( Point _p ){ 
     p.add( _p );
     if( p.size() == 2 ){
       bdry.add( new Edge( p.get(0), p.get(1) ) );
       bdry.add( new Edge( p.get(1), p.get(0) ) );
     }
     if( p.size() > 2 ){
       bdry.set( bdry.size()-1, new Edge( p.get(p.size()-2), p.get(p.size()-1) ) );
       bdry.add( new Edge( p.get(p.size()-1), p.get(0) ) );
     }
   }

}
