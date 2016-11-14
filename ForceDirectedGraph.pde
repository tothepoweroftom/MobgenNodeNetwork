 class ForceDirectedGraph extends Viewport{

  private static final float TOTAL_KINETIC_ENERGY_DEFAULT = MAX_FLOAT;
  public static final float SPRING_CONSTANT_DEFAULT       = 1.4f;
  public static final float COULOMB_CONSTANT_DEFAULT      = 1000.0f;
  public static final float DAMPING_COEFFICIENT_DEFAULT   = 0.8f;
  public static final float TIME_STEP_DEFAULT             = 0.8f;

  private ArrayList<Noda> nodes;
  private float totalKineticEnergy;
  private float springConstant;
  private float coulombConstant;
  private float dampingCoefficient;
  private float timeStep;

  private Noda lockedNode;
  private Noda dummyCenterNode; //for pulling the graph to center

  public ForceDirectedGraph(){
    super(0, 0, 1400,850);
    this.nodes = new ArrayList<Noda>();
    this.totalKineticEnergy = TOTAL_KINETIC_ENERGY_DEFAULT;
    this.springConstant = SPRING_CONSTANT_DEFAULT;
    this.coulombConstant = COULOMB_CONSTANT_DEFAULT;
    this.dampingCoefficient = DAMPING_COEFFICIENT_DEFAULT;
    this.timeStep = TIME_STEP_DEFAULT;

    this.lockedNode = null;
    this.dummyCenterNode = new Noda("dummy", -1, -1);
  }

  public void add(Noda node){
    this.nodes.add(node);
  }
  public void addEdge(int id1, int id2, float naturalSpringLength, boolean gOrH){
    Noda node1 = this.getNodeWith(id1, gOrH);
    Noda node2 = this.getNodeWith(id2, gOrH);
    node1.add(node2, naturalSpringLength);
    node2.add(node1, naturalSpringLength);
  }
  
    public void addEdge(int group1, int group2,int hier1, int hier2, float naturalSpringLength){
    Noda node1 = this.getNodeWith(group1, hier1);
    Noda node2 = this.getNodeWith(group2, hier2);
    node1.add(node2, naturalSpringLength);
    node2.add(node1, naturalSpringLength);
  }
  
  //METHOD BETWEEN NODES
    public void addEdge(Noda node1, Noda node2, float naturalSpringLength){
    node1.add(node2, naturalSpringLength);
    node2.add(node1, naturalSpringLength);
  }
  
  //Fetching nodes with desired values Group & Hierarchy, Boolean Flag Group==True, Hierarchy==False
  private Noda getNodeWith(int id, boolean gOrH){
    Noda node = null;
    for(int i = 0; i < this.nodes.size(); i++){
      Noda target = this.nodes.get(i);
      if(gOrH){
        if(target.getGroupID() == id){
          node = target;
          break;
        }
      } else {
          if(target.getHierarchy() == id){
           node = target;
           break;
        }
      }
    }
    return node;
  }
  
  //Fetching nodes with Names if needed?
  private Noda getNodeWith(String name){
    Noda node = null;
    for(int i = 0; i < this.nodes.size(); i++){
      Noda target = this.nodes.get(i);
      if(target.getNodeName() == name){
        node = target;
        break;
      }
    }
    return node;
  }
  
    //Fetching nodes with Group and Hierarchy if needed? - RETURNS AN
  private ArrayList<Noda> getNodesWith(int group, int hierarchy){
    ArrayList<Noda> nodes = new ArrayList();
    for(int i = 0; i < this.nodes.size(); i++){
      Noda target = this.nodes.get(i);
      if(target.getGroupID() == group && target.getHierarchy() == hierarchy){
        nodes.add(target);
        break;
      }
    }
    return nodes;
  }
  
  
   private Noda getNodeWith(int group, int hierarchy){
    Noda node = null;
    for(int i = 0; i < this.nodes.size(); i++){
      Noda target = this.nodes.get(i);
      if(target.getGroupID() == group && target.getHierarchy() == hierarchy){
        node = target;
        break;
      }
    }
    return node;
  }

  //@Override
  public void set(float viewX, float viewY, float viewWidth, float viewHeight){
    super.set(viewX, viewY, viewWidth, viewHeight);
    if(this.dummyCenterNode != null){
      this.dummyCenterNode.set(this.getCenterX(), this.getCenterY(), 1.0f);
      this.initializeNodeLocations();
    }
  }
  private void initializeNodeLocations(){
    float maxMass = 0.0f;
    for(int i = 0; i < this.nodes.size(); i++){
      float mass = this.nodes.get(i).getHierarchy()*10;
      if(mass > maxMass)
        maxMass = mass;
    }
    float nodeSizeRatio;
    if(this.getWidth() < this.getHeight())
      nodeSizeRatio = this.getWidth() / (maxMass * 15.0f); //ad-hoc
    else
      nodeSizeRatio = this.getHeight() / (maxMass * 15.0f); //ad-hoc
    float offset = nodeSizeRatio * maxMass;
    float minXBound = this.getX() + offset;
    float maxXBound = this.getX() + this.getWidth() - offset;
    float minYBound = this.getY() + offset;
    float maxYBound = this.getY() + this.getHeight() - offset;
    for(int i = 0; i < this.nodes.size(); i++){
      Noda node = this.nodes.get(i);
      float x = random(minXBound, maxXBound);
      float y = random(minYBound, maxYBound);
      float d = node.getSize() * nodeSizeRatio;
      node.set(x, y, d);
    }
  }

  public void draw(){
    this.totalKineticEnergy = this.calculateTotalKineticEnergy();

    strokeWeight(1.5f);
    this.drawEdges();
    for(int i = 0; i < this.nodes.size(); i++)
      this.nodes.get(i).draw();

    //fill(0);
    //textAlign(LEFT, TOP);
    //float offset = textAscent() + textDescent();
    //text("Total Kinetic Energy: " + this.totalKineticEnergy, this.getX(), this.getY());
    //text("Spring Constant: " + this.springConstant, this.getX(), this.getY() + offset);
    //text("Coulomb Constant: " + this.coulombConstant, this.getX(), this.getY() + offset * 2.0f);
    //text("Damping Coefficient: " + this.dampingCoefficient, this.getX(), this.getY() + offset * 3.0f);
    //text("Time Step: " + this.timeStep, this.getX(), this.getY() + offset * 4.0f);
  }

  private void drawEdges(){
    stroke(255, 100, 0);
    for(int i = 0; i < this.nodes.size(); i++){
      //Node in question
      Noda node1 = this.nodes.get(i);
      
      //Search for adjacents
      for(int j = 0; j < node1.getSizeOfAdjacents(); j++){
        Noda node2 = node1.getAdjacentAt(j);
                  pushMatrix();

        if(node2.getHierarchy()==1){
         strokeWeight(3) ;
        } else if(node2.getHierarchy()==1) {
          strokeWeight(1);
        }
        line(node1.getX(), node1.getY(), node2.getX(), node2.getY());
        popMatrix();
      }
    }
  }

  private float calculateTotalKineticEnergy(){ //ToDo:check the calculation in terms of Math...
    float totalKineticEnergy = 0.0f;
    for(int i = 0; i < this.nodes.size(); i++){
      Noda target = this.nodes.get(i);
      if(target == this.lockedNode)
        continue;

      float forceX = 0.0f;
      float forceY = 0.0f;
      for(int j = 0; j < this.nodes.size(); j++){ //Coulomb's law
        Noda node = this.nodes.get(j);
        if(node != target){
          float dx = target.getX() - node.getX();
          float dy = target.getY() - node.getY();
          float rSquared = dx * dx + dy * dy + 0.0001f; //to avoid zero deviation
          float coulombForceX = this.coulombConstant * dx / rSquared;
          float coulombForceY = this.coulombConstant * dy / rSquared;
          forceX += coulombForceX;
          forceY += coulombForceY;
        }
      }

      if(this.dummyCenterNode != null){ //for centering the graph //super ad-hoc
        float dummyDx = target.getX() - this.dummyCenterNode.getX();
        float dummyDy = target.getY() - this.dummyCenterNode.getY();
        if(dummyDx > 10.0f || dummyDy > 10.0f){
          float dummyRSquared = dummyDx * dummyDx + dummyDy * dummyDy + 0.0001f; //to avoid zero deviation
          float dummyCoulombForceX = this.coulombConstant * dummyDx / dummyRSquared;
          float dummyCoulombForceY = this.coulombConstant * dummyDy / dummyRSquared;
          forceX -= dummyCoulombForceX / 10.0f;
          forceY -= dummyCoulombForceY / 10.0f;
        }
      }

      for(int j = 0; j < target.getSizeOfAdjacents(); j++){ //Hooke's law
        Noda node = target.getAdjacentAt(j);
        float springLength = target.getNaturalSpringLengthAt(j);
        float dx = node.getX() - target.getX();
        float dy = node.getY() - target.getY();

        float l = sqrt(dx * dx + dy * dy) + 0.0001f; //to avoid zero deviation
        float springLengthX = springLength * dx / l;
        float springLengthY = springLength * dy / l;
        float springForceX = this.springConstant * (dx - springLengthX);
        float springForceY = this.springConstant * (dy - springLengthY);

        forceX += springForceX;
        forceY += springForceY;
      }

      float accelerationX = forceX / target.getSize();
      float accelerationY = forceY / target.getSize();

      float velocityX = (target.getVelocityX() + this.timeStep * accelerationX) * this.dampingCoefficient;
      float velocityY = (target.getVelocityY() + this.timeStep * accelerationY) * this.dampingCoefficient;

      float x = target.getX() + this.timeStep * velocityX + accelerationX * pow(this.timeStep, 2.0f) / 2.0f;
      float y = target.getY() + this.timeStep * velocityY + accelerationY * pow(this.timeStep, 2.0f) / 2.0f;

      float radius = target.getDiameter() / 2.0f; //for boundary check
      if(x < this.getX() + radius)
        x = this.getX() + radius;
      else if(x > this.getX() + this.getWidth() - radius)
        x =  this.getX() + this.getWidth() - radius;
      if(y < this.getY() + radius)
        y = this.getY() + radius;
      else if(y > this.getY() + this.getHeight() - radius)
        y =  this.getX() + this.getHeight() - radius;

      target.set(x, y);
      target.setVelocities(velocityX, velocityY);

      totalKineticEnergy += (target.getSize() * pow((velocityX + velocityY), 2.0f));
    }
    return totalKineticEnergy;
  }

  public void onMouseMovedAt(int x, int y){
    for(int i = 0; i < this.nodes.size(); i++){
      Noda node = this.nodes.get(i);
      if(node.isIntersectingWith(x, y))
        node.highlight();
      else
        node.dehighlight();
    }
  }
  public void onMousePressedAt(int x, int y){
    for(int i = 0; i < this.nodes.size(); i++){
      Noda node = this.nodes.get(i);
      if(node.isIntersectingWith(x, y)){
        this.lockedNode = node;
        this.lockedNode.setVelocities(0.0f, 0.0f);
        break;
      }
    }
  }
  public void onMouseDraggedTo(int x, int y){
    if(this.lockedNode != null){
      float radius = this.lockedNode.getDiameter() / 2.0f; //for boundary check
      if(x < this.getX() + radius)
        x = (int)(this.getX() + radius);
      else if(x > this.getX() + this.getWidth() - radius)
        x =  (int)(this.getX() + this.getWidth() - radius);
      if(y < this.getY() + radius)
        y = (int)(this.getY() + radius);
      else if(y > this.getY() + this.getHeight() - radius)
        y =  (int)(this.getX() + this.getHeight() - radius);

      this.lockedNode.set(x, y);
      this.lockedNode.setVelocities(0.0f, 0.0f);
    }
  }
  public void onMouseReleased(){
    this.lockedNode = null;
  }

  //@Override
  public void onSpringConstantChangedTo(float value){
    this.springConstant = value;
  }
  //@Override
  public void onCoulombConstantChangedTo(float value){
    this.coulombConstant = value;
  }
  //@Override
  public void onDampingCoefficientChangedTo(float value){
    this.dampingCoefficient = value;
  }
  //@Override
  public void onTimeStepChangedTo(float value){
    this.timeStep = value;
  }

  public void dumpInformation(){
    println("--------------------");
    for(int i = 0; i < this.nodes.size(); i++)
      println(this.nodes.get(i).toString());
    println("--------------------");
  }

}