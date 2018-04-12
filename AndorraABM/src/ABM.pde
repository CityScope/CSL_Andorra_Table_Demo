 /* 
 * This file is part of the CityScope Organization (https://github.com/CityScope).
 * Copyright (c) 2018 Arnaud Grignard.
 * 
 * This program is free software: you can redistribute it and/or modify  
 * it under the terms of the GNU General Public License as published by  
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of 
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

/* AGENT PROFILE ENUM ---------------------------------------------------*/
public enum Profile {
  // FLAT DESIGN COLOR #FD7400), #004358), #FFE11A), #1F8A70), #BEDB39), #FFA500),#FF9F39), #BBBD7D);
  // GAMA COLOR #F4A528 #165E93 #D94821
  //ANDORRA PLAYER #E5953F #2D34EA #666666
  //KIND OF BLUE #A8C0D0 #6294B0 #548099
  
  SPANISH("Spanish", "ES", #e67e22), 
  FRENCH("French", "FR", #34495e), 
  BELGIUM("Belgium", "BE", #3498db),
  ENGLISH("English", "EN", #f1c40f), 
  RUSSIAN("Russian", "RU", #1abc9c), 
  PORTUGAL("Portugal", "PT", #e74c3c), 
  NETHERLANDS("Netherland", "NE", #2ecc71), 
  GERMANY("Germany", "GE", #c0392b);

  private final String nation;
  private final String language;
  private final color tint;

  private Profile(String nation, String language, color tint) {
    this.nation = nation;
    this.language = language;
    this.tint = tint;
  }

  public String getNation() { 
    return nation;
  }
  public String getLanguage() { 
    return language;
  }
  public color getColor() { 
    return tint;
  }
}

/* ABM CLASS ------------------------------------------------------------*/
public class ABM {

  /* <--- ATTRIBUTES --->*/
  private RoadNetwork map;
  private ArrayList<Agent> agents;
  private int agentsToShow = 0;
  private boolean showAgent = true;
  private boolean stop = false;
  private float speed = demoSpeed;
  private ArrayList colorPalette;

  /* <--- CONSTRUCTOR ---> */
  ABM(RoadNetwork _map) {
    map = _map;
    agents = new ArrayList<Agent>();
    colorPalette = new ArrayList();
    for (Profile pr : Profile.values()) {
      colorPalette.add(pr.getColor());
    }
  }

  /* <--- SETTERS AND GETTERS ---> */
  public float getSpeed() { 
    return speed;
  }
  public int numAgents() { 
    return agents.size();
  }
  public ArrayList<Agent> getAgents() { 
    return agents;
  }
  public void toggle() { 
    //agentsToShow = (agentsToShow + 1) % (Profile.values().length + 1);
    agentsToShow = (agentsToShow + 1) % (4); //FIXME: for demo purpose only 3 nationality
  }
  
  public void toggleShowAgent() { 
   showAgent=!showAgent;
  }
  public void playStop() { 
    stop = !stop;
  }


  /* <--- METHODS ---> */

  public void InitModel(int id) {

    aggregatedHeatmap.clear();
    instantHeatmap.clear();
    rncHeatmap.clear();
      
    //AGENT INIT: Agent are initialized form Slides.json in the Object Agent corresponding to the current Slide. 
    JSONArray pop = slideHandler.getAgentsFromId(id); 
    for (int i = 0; i < pop.size(); i++) {    
      int nb = pop.getJSONObject(i).getInt("number");
      String Type = pop.getJSONObject(i).getString("Type");
      String Nationality = pop.getJSONObject(i).getString("Nationality");
      String Color = pop.getJSONObject(i).getString("Color");
      //TODO: This is not clean but there is no way to instanciate a ENUM from a String so we need to compare first the string and then get the right ENUM...
      if (Nationality.equals("SPANISH")) {
        if (Type.equals("PERSON")) model.createAgents(nb, RoadAgent.PERSON, Profile.SPANISH, unhex(Color));
        if (Type.equals("CAR")) model.createAgents(nb, RoadAgent.CAR, Profile.SPANISH, unhex(Color));
        if (Type.equals("CAR_RESIDENTIAL")) model.createAgents(nb, RoadAgent.CAR_RESIDENTIAL, Profile.SPANISH, unhex(Color));
      }
      if (Nationality.equals("FRENCH")) {
        if (Type.equals("PERSON")) model.createAgents(nb, RoadAgent.PERSON, Profile.FRENCH, unhex(Color));
        if (Type.equals("CAR")) model.createAgents(nb, RoadAgent.CAR, Profile.FRENCH, unhex(Color));
        if (Type.equals("CAR_RESIDENTIAL")) model.createAgents(nb, RoadAgent.CAR_RESIDENTIAL, Profile.FRENCH, unhex(Color));
      }
      if (Nationality.equals("BELGIUM")) {
        if (Type.equals("PERSON")) model.createAgents(nb, RoadAgent.PERSON, Profile.BELGIUM, unhex(Color));
        if (Type.equals("CAR")) model.createAgents(nb, RoadAgent.CAR, Profile.BELGIUM, unhex(Color));
        if (Type.equals("CAR_RESIDENTIAL")) model.createAgents(nb, RoadAgent.CAR, Profile.BELGIUM, unhex(Color));
      }
      if (Nationality.equals("ENGLISH")) {
        if (Type.equals("PERSON")) model.createAgents(nb, RoadAgent.PERSON, Profile.ENGLISH, unhex(Color));
        if (Type.equals("CAR")) model.createAgents(nb, RoadAgent.CAR, Profile.ENGLISH, unhex(Color));
      }
      if (Nationality.equals("RUSSIAN")) {
        if (Type.equals("PERSON")) model.createAgents(nb, RoadAgent.PERSON, Profile.RUSSIAN, unhex(Color));
        if (Type.equals("CAR")) model.createAgents(nb, RoadAgent.CAR, Profile.RUSSIAN, unhex(Color));
      }
      if (Nationality.equals("PORTUGAL")) {
        if (Type.equals("PERSON")) model.createAgents(nb, RoadAgent.PERSON, Profile.PORTUGAL, unhex(Color));
        if (Type.equals("CAR")) model.createAgents(nb, RoadAgent.CAR, Profile.PORTUGAL, unhex(Color));
      }
      if (Nationality.equals("NETHERLANDS")) {
        if (Type.equals("PERSON")) model.createAgents(nb, RoadAgent.PERSON, Profile.NETHERLANDS, unhex(Color));
        if (Type.equals("CAR")) model.createAgents(nb, RoadAgent.CAR, Profile.NETHERLANDS, unhex(Color));
      }
      if (Nationality.equals("GERMANY")) {
        if (Type.equals("PERSON")) model.createAgents(nb, RoadAgent.PERSON, Profile.GERMANY, unhex(Color));
        if (Type.equals("CAR")) model.createAgents(nb, RoadAgent.CAR, Profile.GERMANY, unhex(Color));
      }
    }
  }

  //initializes the agents based off the OD matrix json

  public void InitCDR(String date, int h) {   
    //sets colors
    String newdate = "data/Mobility/CDR/" + date;
    color spanish = color(244, 157, 0); //orange; spanish
    color other = color(214, 84, 255); //purple; other
    color french = color(33, 75, 237); //blue; french
    networkCDR = loadJSONArray(date);
    for (int i = 0; i<networkCDR.size(); i++) {      
      Tower O = towers.get(networkCDR.getJSONObject(i).getJSONArray("O").getInt(0));
      Tower D = towers.get(networkCDR.getJSONObject(i).getJSONArray("D").getInt(0));
        if(networkCDR.getJSONObject(i).getJSONArray("fr").getInt(h)>0){ //<>// //<>// //<>// //<>//
          model.createCDRAgents(networkCDR.getJSONObject(i).getJSONArray("fr").getInt(h), RoadAgent.PERSON, Profile.FRENCH, french, O, D);
        }
        if(networkCDR.getJSONObject(i).getJSONArray("sp").getInt(h)>0){
          model.createCDRAgents(networkCDR.getJSONObject(i).getJSONArray("sp").getInt(h), RoadAgent.PERSON, Profile.SPANISH, spanish, O, D);
        }
        if(networkCDR.getJSONObject(i).getJSONArray("other").getInt(h)>0){
          model.createCDRAgents(networkCDR.getJSONObject(i).getJSONArray("other").getInt(h), RoadAgent.PERSON, Profile.ENGLISH, other, O, D);
        }   
    }
    println("CDR initialized");
  }
 
  public void regulatePop(int curHour, int fraction){
    int curSimPop= numAgents();
    int realPop= aggregatedData.GetCenterPopFromTower()/fraction;
    int diff = curSimPop - realPop;
    //println("curHour" + curHour + " curSimPop: " + curSimPop + " realPop: " + realPop + " diff: " + diff);
    if(diff>0){
      //println("kill " + diff);
      for(int i= 0;i<=diff;i++){
        Agent toKIll = getRandomAgent(agents);
        toKIll.inNode.crowd(-1); 
        agents.remove(toKIll);
      }
    }
    else{
      //println("create " + -diff + "f:" + (aggregatedData.fRatio*0.1)/2*PI + " s:" + (aggregatedData.sRatio*0.1)/2*PI + " :" + (aggregatedData.oRatio*0.1)/2*PI);
      for(int i= 0;i<=-diff*(aggregatedData.fRatio*0.1)/2*PI;i++){
        createAgents(1, RoadAgent.PERSON, Profile.FRENCH, #2D34EA);  
      }
      for(int i= 0;i<=-diff*(aggregatedData.sRatio*0.1)/2*PI;i++){
        createAgents(1, RoadAgent.PERSON, Profile.SPANISH, #e67e22);  
      }
      for(int i= 0;i<=-diff*(aggregatedData.oRatio*0.1)/2*PI;i++){
        createAgents(1, RoadAgent.PERSON, Profile.BELGIUM, #AAAAAA);  
      }
    }
  }
  public Agent getRandomAgent(ArrayList<Agent> list){
    int randomIndex = int(random (0,list.size()-1));
    return list.get(randomIndex);
  }

  // CREATE AGENTS --->
  public void createAgents(int num, RoadAgent t, Profile p, color c) {
    for (int i = 0; i < num; i++) agents.add( new Agent(map, agents.size(), t, p, c));
  } 

  public void createCDRAgents(int num, RoadAgent t, Profile p, color c, Tower O, Tower D) {
    for (int i = 0; i < num; i++) agents.add( new Agent(map, agents.size(), t, p, c, O, D));
  }

  // INCREMENT OR DECREASE AGENTS SPEED --->
  public void speed(float inc) {  
      if (speed >= -inc) speed += inc;
      if(speed == 0){
        speed =0.3;
      }
  }

  public void setSpeed(float speed) {
    this.speed = speed;
    println("set speed" + speed);
  }

  // RUN SIMULATION --->
  public void run(PGraphics p) {
    for (Agent agent : agents) {
      if (!stop) agent.move(speed);
      Profile toShow = agentsToShow > 0 ? Profile.values()[agentsToShow-1] : null;
      if(showAgent){
        if (trafficEquilibrium==false && streetsAND.showRNC == false && streetsAND.showRNCCluster == false)
        agent.draw(p, toShow);
      }
      
    }
    // In order to have a loop running every agent that has been arrived will be replace by new one after a few iteration. 
    for (int i = agents.size() - 1; i >= 0; i--) { 
      Agent a = agents.get(i);
      if (a.arrived) {
        //Kill the agent
        if (millis() - a.timeArrived > 30 * a.destNode.crowdLimit) {
          //Old school black hole but works
          createAgents(1, a.type, a.profile, a.myColor);
          a.destNode.crowd(-1);
          agents.remove(i);  
        } else {
          if (dist(a.posDraw.x, a.posDraw.y, a.destNode.pos.x, a.destNode.pos.y) < a.destNode.crowd/2) {
            a.posDraw.x = a.posDraw.x + random(-0.5, 0.5);
            a.posDraw.y = a.posDraw.y + random(-0.5, 0.5);
          }
        }
      }
      //QUICK AND DIRTY WAY TO FIX ONE OF THE BUG MENTION IN RoadMap (if an agent is waiting I just replaced it)
      if (a.waiting) {
          createAgents(1, a.type, a.profile, a.myColor);
          a.inNode.crowd(-1); 
          agents.remove(i);
      }
    }
  }

  // CHECK IF ANY AGENT IS UNDER MOUSE CLICK AND SAVES IT TO ARRAY --->
  public ArrayList<Agent> select(int x, int y) {
    ArrayList<Agent> selectedAgents = new ArrayList<Agent>();
    for (Agent agent : agents) {
      if ( agent.select(x,y) )selectedAgents.add(agent);
    }
    return selectedAgents;
  }
  
  // CHOOSE A RANDOM AGENT TO DISPLAY ITS TRAJECTORY
  public ArrayList<Agent> selectRandomAgent() {
    ArrayList<Agent> selectedAgents = new ArrayList<Agent>();
    for (Agent agent : agents) {
      agent.selected =false;
    }
    Agent tmp = agents.get(int(random(agents.size()-1)));
    tmp.selected=true;
    selectedAgents.add(tmp);
    return selectedAgents;
  }

  // AGENTS LEGEND --->
  public void printLegend(PGraphics p, int x, int y) {
    int i = 0;
    for (Profile pr : Profile.values()) {
      int pY = y + 15 * i;
      p.fill(pr.getColor()); 
      p.noStroke();
      p.ellipse(x, pY, 7, 7);
      p.fill(#FFFFFF); 
      p.textSize(12); 
      p.textAlign(LEFT, CENTER);
      p.text(""+pr, x+10, pY);
      i++;
    }
  }
}



/* AGENT CLASS ------------------------------------------------------------ */
public class Agent implements Placeable {

  /* <--- ATTRIBUTES --->*/
  private RoadNetwork map;
  private int id;
  private RoadAgent type;
  private Profile profile;
  private color myColor;
  // Movement -->
  private PVector pos, 
    posDraw;
  private PVector dir;
  public Tower OTower, DTower;
  private float distTraveled = 0;
  private ArrayList<Node> path;
  private Node destNode, 
    inNode, 
    toNode;
  private boolean arrived = false, 
    waiting = false, 
    selected = false, 
    dead = false;

  private float timeArrived = 0;

  // Style -->
  private int dotSize;

  /* <--- CONSTRUCTOR ---> */
  Agent(RoadNetwork _map, int _id, RoadAgent _t, Profile _p, color _c) {
    id = _id;
    type = _t;
    map = _map;
    profile = _p;
    initAgent();
    dotSize = type == RoadAgent.PERSON ? 5 : 5;
    myColor = _c;
  }

  Agent(RoadNetwork _map, int _id, RoadAgent _t, Profile _p, color _c, Tower _O, Tower _D) {
    id = _id;
    type = _t;
    map = _map;
    profile = _p;
    dotSize = type == RoadAgent.PERSON ? 5 : 10;
    myColor = _c;
    OTower = _O;
    DTower = _D;
    initAgent();
  }

  public void initAgent() {
    destNode = findDestination();
    Filter filter = new Filter();
    inNode = filter.randomNode( map.getNodes(), type );
    pos = inNode.getPosition();
    posDraw = pos;
    inNode.crowd(1);
    path=null;
    dir = new PVector(0.0, 0.0);
  }

  /* <--- GETTERS & SETTERS ---> */
  public Node dead() { 
    return path.get(0);
  }
  public Node isIn() { 
    return inNode;
  }
  public Node goingTo() { 
    return toNode;
  }
  public RoadAgent getType() { 
    return type;
  }
  public int getId() { 
    return id;
  }
  public PVector getPosition() { 
    return pos;
  }
  public float hasTraveled() { 
    return distTraveled;
  }

  /* <--- METHODS ---> */
  // FIND DESTINATION --->
  private Node findDestination() {
    Filter filter = new Filter();
    ArrayList<POI> possibleDest = filter.allows( map.pois, type );
    possibleDest = filter.speaks(possibleDest, profile.getLanguage() );
    POI destination = filter.randomPOI( possibleDest );
    path = null;
    return destination.node;
  }
  
  // CALCULATE ROUTE --->
  private boolean calcRoute(Node origin, Node dest) {
    // Agent already in destination --->
    if (origin == dest) {
      arrived = true;
      return true;
      // Next node is available --->
    } else if (toNode != null && toNode.walkable) {
      
      inNode.crowd(-1);
      toNode.crowd(1);
      return true;
      // Next node not walkable --->
    } else {
      // Destination is full. Look for another OPEN destination --->
      if (toNode == dest) {
        destNode = findDestination();
        // Find and update (if posible) new route to destination --->
      } else {
        ArrayList<Node> newPath = map.graph.aStar( origin, dest, type );
        if ( newPath != null ) {
          path = newPath;
          inNode.crowd(-1);
          toNode = path.get( path.size()-2 );
          toNode.crowd(1);
          return true;
        }
      }
    }
    return false;
  }


  // AGENT TO NEXT POSITION --->
  public void move(float speed) {
    if (!dead) {
      if (!arrived) {
        if ( path == null || waiting ) { 
          waiting = !calcRoute( inNode, destNode );  // Waiting for route
        } else {  // Route available --->
          dir = PVector.sub(toNode.getPosition(), pos);  // Direction to go
          // Arrived to node -->
          if ( dir.mag() < dir.normalize().mult(speed * type.getSpeed()).mag() ) {
            // Arrived to destination  --->
            if ( path.indexOf(toNode) == 0 ) {  
              posDraw = pos = destNode.getPosition();
              timeArrived = millis();
              arrived = true;
              // Not destination. Look for next node --->
            } else {  
              inNode = toNode;
              toNode = path.get( path.indexOf(toNode)-1 );
              waiting = !calcRoute(inNode, destNode);
            }
            // Not arrived to node --->
          } else {
            distTraveled += dir.mag();
            pos.add( dir );
            posDraw = PVector.add(pos, dir.normalize().mult(type.getStreetOffset()).rotate(HALF_PI));
          }
        }
      }
    }
  }


  // DRAW AGENT POSITION --->
  public void draw(PGraphics p, Profile toShow) {
    if ( toShow == profile || toShow == null ) {
      // Style -->
      color tint = myColor;
      //FIXME: Remove it in order to have blinking red dot but it shoudl be fixed in a better way
      /*color tint = waiting ? #FF0000 : myColor;      
      if (waiting) {
        p.noFill(); 
        p.stroke(tint); 
        p.strokeWeight(1);
        p.ellipse(pos.x, pos.y, dotSize + 3, dotSize + 3);
      }*/
      p.fill(tint); 
      p.noStroke();
      if (type == RoadAgent.PERSON) p.ellipse(posDraw.x, posDraw.y, dotSize, dotSize);
      if (type == RoadAgent.CAR || type == RoadAgent.CAR_RESIDENTIAL) {
        p.stroke(tint);
        //p.strokeWeight(2);
        p.noFill();
        p.ellipse(posDraw.x, posDraw.y, dotSize*2, dotSize*2);
      }
      // Agent is selected --->
      if (selected) {
        p.fill(tint, 50); // Show *glow* --->
        p.ellipse(posDraw.x, posDraw.y, 5*dotSize, 5*dotSize);
        drawPath(p);  // Draw path
      }
    }
  }

  // DRAW AGENT PATH TO DESTINATION --->
  public void drawPath(PGraphics p) {
    if (path != null) {
      for (int i=1; i<path.size(); i++) {
        PVector iNodePos = path.get(i).getPosition(), 
        iPrevNodePos = path.get(i-1).getPosition(), 
        toNodePos = toNode.getPosition();
        int weight = i <= path.indexOf(toNode) ? 3 : 1;  // Already traveled route is thiner than remaining route --->
        p.stroke(myColor); 
        p.strokeWeight(weight); 
        p.noFill();
        p.line( iNodePos.x, iNodePos.y, iPrevNodePos.x, iPrevNodePos.y );
        p.strokeWeight(3);  // Route from pos to next node is always thicker --->
        p.line( pos.x, pos.y, toNodePos.x, toNodePos.y );
      }
    }
  }

  // SELECT AGENT IF UNDER MOUSE CLICK --->
  public boolean select(int x, int y) {
    if(tableView){
      //PVector surfaceMouse = surfacePin3DTable.getTransformedCursor(mouseX, mouseY);
      PVector surfaceMouse= keyStoner.surfacePin3DTable.getTransformedMouse();
      PVector surfacePos = keyStoner.surfacePin3DTable.getTransformedCursor((int)posDraw.x, (int)posDraw.y);
     /* println(" mouseX: " + mouseX + " mouseY: " + mouseY + " posDraw.x: " + posDraw.x + " posDraw.y: " + posDraw.y);
      println( " surfaceMouse.x: " + surfaceMouse.x + " surfaceMouse.y: " + surfaceMouse.y + " surfacePos.x: " + surfacePos.x + " surfacePos.y: " + surfacePos.y);
      println( "x: " + x + "y: " + y );
      println("dist: " + dist(x, y, surfacePos.x, surfacePos.y));*/
     // selected = dist(x, y, surfacePos.x, surfacePos.y) < dotSize;
      selected = dist(x, y, posDraw.x, posDraw.y) < dotSize;
      //selected = dist(surfaceMouse.x, surfaceMouse.y, surfacePos.x, surfacePos.y) < dotSize;
    }else{
       selected = dist(x, y, posDraw.x, posDraw.y) < dotSize;
    }
    return selected;
  }
}

public class Filter {

  public ArrayList<POI> speaks(ArrayList<POI> pois, String language) {
    ArrayList<POI> filtered = new ArrayList<POI>();
    for (POI poi : pois) {
      if ( poi.speaks(language) ) filtered.add(poi);
    }
    return filtered;
  }

  public ArrayList<POI> allows(ArrayList<POI> pois, RoadAgent type) {
    ArrayList<POI> filtered = new ArrayList<POI>();
    for (POI poi : pois) {
      if ( poi.isAllowed(type) ) filtered.add(poi);
    }
    return filtered;
  }

  public POI randomPOI(ArrayList<POI> pois) {
    while (true) {
      POI random = pois.get( round( random(0, pois.size()-1 ) ) );
      if ( random.node.isWalkable() ) return random;
    }
  } 

  public Node randomNode(ArrayList<Node> nodes, RoadAgent type) {
    while (true) {
      Node random = nodes.get( round( random(0, nodes.size()-1 ) ) );
      if ( random.isAllowed(type) ) return random;
    }
  }
}