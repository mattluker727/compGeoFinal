

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
   
   // ------------------------------ Art Gallery ------------------------------
   ArrayList<Triangle> solution = new ArrayList<Triangle>();
   ArrayList<Edge> dual = new ArrayList<Edge>();
   
   // adjacency list of solution based on if Triangles are neighbors
   LinkedList<Integer> adjList[];
   
   // result of dfs on adjList
   ArrayList<Integer> dfsOrder = new ArrayList<Integer>();
   
   // lists to hold solution of coloring
   ArrayList<Point> red = new ArrayList<Point>();
   ArrayList<Point> green = new ArrayList<Point>();
   ArrayList<Point> blue = new ArrayList<Point>();
   ArrayList<Point> colorSolution = new ArrayList<Point>();
   
   int pointType(int prev, int current, int next){
     Triangle test = new Triangle(p.get(prev), p.get(current), p.get(next));

     if (test.ccw() == true) print("ccw \n");
     if (test.cw() == true) print("cw \n");
     
     // check if current triangle is convex
     if ((this.ccw() && test.ccw() == true) || (this.cw() && test.cw() == true)){
       Edge testEar = new Edge(p.get(prev), p.get(next));
       Point midpoint = new Point((testEar.p0.p.x + testEar.p1.p.x)/2, (testEar.p0.p.y + testEar.p1.p.y)/2);
       if (crossesBoundary(testEar) == false && pointInPolygon(midpoint) == true){
         return 2; // ear
       }
       else{
        return 1; // convex
       }
     }
     else {
       return 0; // relfex
     }
   }
   
   void earClipping(){
     print("--------------------------------------\n");
     
     solution.clear();
     
     // indexs of indexes in currPolygon we are testing
     int current = 0, prev, next;
     
     // list of indexes relevant to original polygon
     ArrayList<Integer> currPolygon = new ArrayList();
     for (int i = 0; i < p.size(); i++){
       currPolygon.add(i);
     }

     // lists of indexes relevant to original polygon 
     ArrayList<Integer> C = new ArrayList(); // convex
     ArrayList<Integer> R = new ArrayList(); // reflex
     ArrayList<Integer> E = new ArrayList(); // ear
     
     // categorize initial points
     for (int i = 0; i < currPolygon.size(); i++){
       prev = (i - 1);
       if (prev == -1) prev = currPolygon.size() - 1;
       next = (i + 1) % currPolygon.size();
       
       int pointType = pointType(prev, i, next);
       
       if (pointType == 0){ // reflex
         R.add(i);
       }
       else if (pointType == 1){ // convex
         C.add(i);
       }
       else if (pointType == 2){ // ear
         C.add(i);
         E.add(i); 
       }
     }
     
     // perform ear cutting
     while (currPolygon.size() > 3){
       print("R:" + R);     
       print(" C:" + C);
       print(" E:" + E);
       print("\n");
       
       
       // get next ear to cut
       current = E.get(0);
       current = currPolygon.indexOf(current);
       
       prev = (current - 1);
       if (prev < 0) prev = currPolygon.size() - 1;
       next = (current + 1) % currPolygon.size();
       
       print("Remove ");
       print(currPolygon.get(prev) + " ");     
       print(currPolygon.get(current) + " ");     
       print(currPolygon.get(next) + " ");     
       print("\n");

       // export ear to be cut
       solution.add(new Triangle(p.get(currPolygon.get(prev)), 
       p.get(currPolygon.get(current)), 
       p.get(currPolygon.get(next))));

       //remove ear from E list and currPolygon
       C.remove(new Integer(currPolygon.get(current)));
       E.remove(0);
       currPolygon.remove(current);
       
       // correct index after resizing 
       next = current;
       if (next >= currPolygon.size() || next < 0) next = 0;
       if (prev >= currPolygon.size()) prev = currPolygon.size() - 1;

       // update prev point type
       int prevPrev = (prev - 1);
       if (prevPrev == -1) prevPrev = currPolygon.size() - 1;
       int prevNext = next;
       
       print("Testing " + currPolygon.get(prevPrev) + currPolygon.get(prev) + currPolygon.get(prevNext) + " ");
       int pointType = pointType(currPolygon.get(prevPrev), currPolygon.get(prev), currPolygon.get(prevNext));
       
       if (pointType == 0){ // reflex
         if (R.contains(currPolygon.get(prev)) == false) R.add(currPolygon.get(prev));
         C.remove(new Integer(currPolygon.get(prev)));
         E.remove(new Integer(currPolygon.get(prev)));
       }
       else if (pointType == 1){ // convex
         if (C.contains(currPolygon.get(prev)) == false)  C.add(currPolygon.get(prev));
         R.remove(new Integer(currPolygon.get(prev)));
         E.remove(new Integer(currPolygon.get(prev)));
       }
       else if (pointType == 2){ // ear
         if (C.contains(currPolygon.get(prev)) == false) C.add(currPolygon.get(prev));
         if (E.contains(currPolygon.get(prev)) == false) E.add(currPolygon.get(prev));
         R.remove(new Integer(currPolygon.get(prev)));
       }
       
       // update next point type
       int nextPrev = prev;
       int nextNext = (next + 1) % currPolygon.size();
       
       print("Testing " + currPolygon.get(nextPrev) + currPolygon.get(next) + currPolygon.get(nextNext) + " ");
       pointType = pointType(currPolygon.get(nextPrev), currPolygon.get(next), currPolygon.get(nextNext));
       
       if (pointType == 0){ // reflex         
         if (R.contains(currPolygon.get(next)) == false) R.add(currPolygon.get(next));
         C.remove(new Integer(currPolygon.get(next)));
         E.remove(new Integer(currPolygon.get(next)));
       }
       else if (pointType == 1){ // convex         
         if (C.contains(currPolygon.get(next)) == false)  C.add(currPolygon.get(next));
         R.remove(new Integer(currPolygon.get(next)));
         E.remove(new Integer(currPolygon.get(next)));
       }
       else if (pointType == 2){ // ear
         if (C.contains(currPolygon.get(next)) == false) C.add(currPolygon.get(next));
         if (E.contains(currPolygon.get(next)) == false) E.add(0, currPolygon.get(next));
         R.remove(new Integer(currPolygon.get(next)));
       }
     }
     
     // add remaining
     if (currPolygon.size() > 2){
       solution.add(new Triangle(p.get(currPolygon.get(0)), p.get(currPolygon.get(1)), p.get(currPolygon.get(2))));
     }
     
     //print(solution.size());
   }
    
   boolean neighborTriangle(Triangle A, Triangle B){
     int count = 0;
     
     // check how many vertices are shared
     if ((A.p0 == B.p0) || (A.p0 == B.p1) || (A.p0 == B.p2)) count++;
     if ((A.p1 == B.p0) || (A.p1 == B.p1) || (A.p1 == B.p2)) count++;
     if ((A.p2 == B.p0) || (A.p2 == B.p1) || (A.p2 == B.p2)) count++;
     
     if (count == 2){
       return true; 
     }
     return false;
   }
   
   void getDual(){
     if (solution.size() == 0) return;
     
     dual.clear();
     
     // setup linked list
     adjList = new LinkedList[solution.size() + 1]; 
     
     for (int i = 0; i < adjList.length; i ++){
       adjList[i] = new LinkedList<Integer>();
     } 
     
     // find triangles in dual which share two vertices and draw a line betwen them
     for (int i = 0; i < solution.size(); i++ ){
       for (int j = i + 1; j < solution.size(); j++ ){
         if (neighborTriangle(solution.get(i), solution.get(j)) == true){
           // add to dual drawing
           dual.add(new Edge(solution.get(i).center(), solution.get(j).center()));
           
           // add to linked list
           adjList[i].add(j); 
           adjList[j].add(i); 
         }
       }
     }
     
     //print(solution.size());
     
     // choose node to start dfs on and identify parent node
     int node = 0;
     int parent = adjList.length;
     
     print("\n");
     for(int i = 0; i < adjList.length; i++ ){
       print(i + ":" + adjList[i] + " ");
       // keep track of "parent" node and start node (any )
       if (adjList[i].size() > parent) parent = i;
       if (adjList[i].size() < node) node = i;
     }
     print("\n");
     
     dfsOrder.clear();
     
     dfs(adjList, node, parent);
     
     for(int i = 0; i < dfsOrder.size(); i++ ){
       print(dfsOrder.get(i) + " ");
     }
     print("\n");
     
     coloring();
   }
   
   // use dfs to find coloring order
   void dfs(LinkedList<Integer> list[], int node, int arrival) { 
     // Printing traversed node 
     //System.out.println(node); 
     
     dfsOrder.add(node);
     
     // Traversing adjacent edges 
     for (int i = 0; i < list[node].size(); i++) {
       // Not traversing the parent node 
       if (list[node].get(i) != arrival){
         dfs(list, list[node].get(i), node);
       }
     } 
   }
   
   // use dfs order to color triangulated polygon
   void coloring(){
     red.clear();
     green.clear();
     blue.clear();
     
     // color initial triangle
     red.add(solution.get(dfsOrder.get(0)).p0);
     green.add(solution.get(dfsOrder.get(0)).p1);
     blue.add(solution.get(dfsOrder.get(0)).p2);
     
     for(int i = 1; i < dfsOrder.size(); i++ ){
       Point A = solution.get(dfsOrder.get(i)).p0;
       Point B = solution.get(dfsOrder.get(i)).p1;
       Point C = solution.get(dfsOrder.get(i)).p2;
       
       Point toColor;
       
       // A is point needed to be colored
       if (!red.contains(A) && !green.contains(A) && !blue.contains(A)){
         toColor = A;
         // check if toColor should be red
         if ((green.contains(B) && blue.contains(C)) || (green.contains(C) && blue.contains(B))){
           red.add(toColor);
         }
         // check if toColor should be green
         if ((red.contains(B) && blue.contains(C)) || (red.contains(C) && blue.contains(B))){
           green.add(toColor);
         }
         // check if toColor should be blue
         if ((red.contains(B) && green.contains(C)) || (red.contains(C) && green.contains(B))){
           blue.add(toColor);
         }
       }
       // B is point needed to be colored
       else if (!red.contains(B) && !green.contains(B) && !blue.contains(B)){
         toColor = B;
         // check if toColor should be red
         if ((green.contains(A) && blue.contains(C)) || (green.contains(C) && blue.contains(A))){
           red.add(toColor);
         }
         // check if toColor should be green
         if ((red.contains(A) && blue.contains(C)) || (red.contains(C) && blue.contains(A))){
           green.add(toColor);
         }
         // check if toColor should be blue
         if ((red.contains(A) && green.contains(C)) || (red.contains(C) && green.contains(A))){
           blue.add(toColor);
         }
       }
       // C is point needed to be colored
       else{
         toColor = C;
         // check if toColor should be red
         if ((green.contains(B) && blue.contains(A)) || (green.contains(A) && blue.contains(B))){
           red.add(toColor);
         }
         // check if toColor should be green
         if ((red.contains(B) && blue.contains(A)) || (red.contains(A) && blue.contains(B))){
           green.add(toColor);
         }
         // check if toColor should be blue
         if ((red.contains(B) && green.contains(A)) || (red.contains(A) && green.contains(B))){
           blue.add(toColor);
         }
       }
     }
     
     // find smallest solution set
     colorSolution = (ArrayList<Point>) red.clone();
     
     if (blue.size() < colorSolution.size()){
       colorSolution = (ArrayList<Point>) blue.clone();
     }
     
     if (green.size() < colorSolution.size()){
       colorSolution = (ArrayList<Point>) green.clone();
     }
     
     // print solution
     print("\nSolution:\t");
     for(int i = 0; i < colorSolution.size(); i++ ){
       print(colorSolution.get(i) + " ");
     }
     
   }
   
   void drawTriangulation(){
     // draw triangles
     for(int i = 0; i < solution.size(); i++ ){
        noFill();
        solution.get(i).draw();
        noFill();
     }
   }
   
   void drawDual(){
     // draw dual
     for(int i = 0; i < dual.size(); i++ ){
       dual.get(i).draw();
     }
     
     // draw points on dual
     for(int i = 0; i < solution.size(); i++ ){
        fill(0, 0, 0);
        solution.get(i).center().draw();
        noFill();
     }
   }
   
   void drawColoring(){
     // red 
     print("\nRed:\t");
     fill(255, 0, 0);
     for(int i = 0; i < red.size(); i++ ){
       print(red.get(i) + " ");
       ellipse(red.get(i).p.x, red.get(i).p.y, 20, 20);
     }
     print("\nGreen:\t");
     fill(0, 255, 0);
     
     // green 
     for(int i = 0; i < green.size(); i++ ){
       print(green.get(i) + " ");
       ellipse(green.get(i).p.x, green.get(i).p.y, 20, 20);
     }
     print("\nBlue:\t");
     fill(0, 0, 255);
     
     // blue 
     for(int i = 0; i < blue.size(); i++ ){
       print(blue.get(i) + " ");
       ellipse(blue.get(i).p.x, blue.get(i).p.y, 20, 20);
     }
     print("\n");
   }


}
