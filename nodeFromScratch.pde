int CANVAS_WIDTH_DEFAULT  = 1400;
int CANVAS_HEIGHT_DEFAULT = 850;

String[] names;
String DATA_FILE_PATH = "dataVis.csv";
/*
 *  data.csv frmat:
 *  By assuming the line index is base 0.
 *  a. Line#(0): NumberOfNodes
 *  b. Line#(1)~#(NumberOfNodes): NodeIndex,NodeMass
 *  c. Line#(NumberOfNodes + 1): NumberOfEdges
 *  d. Line#(NumberOfNodes + 1)~#(NumberOfNodes + 1 + NumberOfEdges): Node1Index,Node2Index,NaturalSpringLength
 */

ForceDirectedGraph forceDirectedGraph;

void setup() {
  int canvasWidth = CANVAS_WIDTH_DEFAULT;
  int canvasHeight = CANVAS_HEIGHT_DEFAULT;
  size(1400,850);
  forceDirectedGraph = createForceDirectedGraphFrom(DATA_FILE_PATH);
  forceDirectedGraph.set(5.0f, 5.0f, (float)canvasWidth*0.99, (float)canvasHeight*0.99);
  //forceDirectedGraph.dumpInformation();
}

void draw() {
  background(0);
  forceDirectedGraph.draw();
}

void mouseMoved() {
  if (forceDirectedGraph.isIntersectingWith(mouseX, mouseY))
    forceDirectedGraph.onMouseMovedAt(mouseX, mouseY);
}
void mousePressed() {
  if (forceDirectedGraph.isIntersectingWith(mouseX, mouseY))
    forceDirectedGraph.onMousePressedAt(mouseX, mouseY);
  //else if(controlPanel.isIntersectingWith(mouseX, mouseY))
  //  controlPanel.onMousePressedAt(mouseX, mouseY);
}
void mouseDragged() {
  if (forceDirectedGraph.isIntersectingWith(mouseX, mouseY))
    forceDirectedGraph.onMouseDraggedTo(mouseX, mouseY);
  //else if(controlPanel.isIntersectingWith(mouseX, mouseY))
  //  controlPanel.onMouseDraggedTo(mouseX, mouseY);
}
void mouseReleased() {
  if (forceDirectedGraph.isIntersectingWith(mouseX, mouseY))
    forceDirectedGraph.onMouseReleased();
}


/////------CODE FOR LOADING DATA HERE -_-_-_-_-_-
//TEST CASE 1 = USING DATA FILE WITH ID, GROUP, HIERARCHY
ForceDirectedGraph createForceDirectedGraphFrom(String dataFilePath) {

  ForceDirectedGraph forceDirectedGraph = new ForceDirectedGraph();

  //LOAD EACH LINE OF FILE AS A STRING
  String[] lines = loadStrings(dataFilePath); 
  //SHOULD TELL THE PROGRAM HOW MANY NODES TO PREPARE USING FIRST LINE
  int numberOfNodes = int(trim(lines[0]));
  println("No. Of Nodes: " + numberOfNodes);

  for (int i = 1; i < 1 + numberOfNodes; i++) {
    //Gives array of three elements - ID(String), GROUP_ID(Int), HIERARCHY(Int)
    //SPLIT DATA FROM THE CSV
    String[] nodeData = splitTokens(trim(lines[i]), ",");
   // println(nodeData.length + " values found");


    //ADD THE DATA TO NEW NODES
    forceDirectedGraph.add(new Noda(trim(nodeData[0]), int(trim(nodeData[1])), int(trim(nodeData[2]))));
   // println(trim(nodeData[0]), int(trim(nodeData[1])), int(trim(nodeData[2])));

    //int numberOfEdges = int(trim(lines[numberOfNodes + 1]));
    //for(int i = numberOfNodes + 2; i < numberOfNodes + 2 + numberOfEdges; i++){
    //  String[] edgeData = splitTokens(trim(lines[i]), ",");
    //  int id1 = int(trim(edgeData[0]));
    //  int id2 = int(trim(edgeData[1]));
    //  float edgeLength = float(trim(edgeData[2]));
    //  //forceDirectedGraph.addEdge(id1, id2, edgeLength);
    //}
  }

  //FIND AND FILTER NODES 
  for(Noda node : forceDirectedGraph.nodes){
    int gID = node.getGroupID();
    int hID = node.getHierarchy();
    
    println(gID + " " + hID);
    
    if(hID==1){
     forceDirectedGraph.addEdge(0,1, 200, true);
     forceDirectedGraph.addEdge(0,2, 200, true);
     forceDirectedGraph.addEdge(0,3, 200, true);
     forceDirectedGraph.addEdge(0,4, 200, true);
     forceDirectedGraph.addEdge(0,5, 200, true);
    } else if (hID == 2){
     // ArrayList<Noda> children = forceDirectedGraph.getNodeWith(gID,hID);
     
     //GET PARENT GROUP NODE FROM #1 Hierarchy
     Noda parent = forceDirectedGraph.getNodeWith(gID, 1);
     forceDirectedGraph.addEdge(parent, node, 200);
      
    }
  }


    ////Need to add code to connect the nodes - manually for now
    // Noda node1 = forceDirectedGraph.nodes.get(i);
    // if(node1.getHierarchy() == 0){

    // } 

       
    // if(node1.getHierarchy() == 2){
    //  forceDirectedGraph.addEdge(node1.getGroupID() 
    // }


  return forceDirectedGraph;
}