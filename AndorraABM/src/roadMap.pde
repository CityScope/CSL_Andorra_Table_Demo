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

// ----------------------------------------------------------------------------------------------------------
// Roadmap classes by Marc Vilella - May 2016 
//
// Generation of the roadmap and POIs from data stored in GeoJSON ans tsv files
//
// ToDo: - (Bug) Oneway streets not supposed to be and viceversa
//       - (Bug) Why is PEOPLE still going into tunnel?
//       - (Bug) Why do some agents unexpectedly stop and/or wait?
// ----------------------------------------------------------------------------------------------------------

public enum RoadAgent {
  PERSON(1, 2, "primary,residential,pedestrian,living_street,steps,footway,cycleway,service"),
  CAR(3, 1, "primary,residential"),
  CAR_RESIDENTIAL(3, 1, "residential");
  
  private final int speed;
  private final int streetOffset;
  private final StringList allowedTo;
  
  private RoadAgent(int speed, int streetOffset, String allowedTo) {
    this.streetOffset = streetOffset;
    this.speed = speed;
    this.allowedTo = new StringList( split(allowedTo, ",") );
  }
  
  public int getStreetOffset() { return streetOffset; }
  public int getSpeed() { return speed; };
  public boolean isAllowed(String streetType) {
    if(allowedTo.hasValue(streetType)) return true;
    else return false;
  }
  
}

/* ROADNETWORK CLASS --------------------------------------------------------------------------------------- */
public interface Placeable {
    public PVector getPosition();
}

public class RoadNetwork {
  
  /* <--- ATTRIBUTES ---> */
  private PVector size;
  private float scale;
  private PVector[] bounds;  // [0] Left-Top  [1] Right-Bottom
  private Pathfinder graph;
  private boolean showCrowd = false,
                  showTower=false,
                  showRNC = false,
                  showRNCCluster = false,
                  hideBackground = false,
                  showPOIs = true,
                  showStreetRendering= false,
                  showBG =false;
  
  private StringList roadType = new StringList();                
  private int showRouteType = 0,      
              showRoutes = 0;
                  
  private int crowdLimit = 50;  // Max people per node
  ArrayList<POI> pois;
  
  /* <--- CONSTRUCTOR ---> */
  RoadNetwork(String GeoJSONfile) {
     
    ArrayList<Node> nodes = new ArrayList<Node>();
    
    // Load file -->
    JSONObject JSON = loadJSONObject(GeoJSONfile);
    JSONArray JSONlines = JSON.getJSONArray("features");
    
    // Set map bounds -->
    setBoundingBox(JSONlines);
    
    // Import all nodes -->
    Node prevNode = null;
    for(int i=0; i<JSONlines.size(); i++) {
      
      JSONObject props = JSONlines.getJSONObject(i).getJSONObject("properties");
      String type = props.isNull("type") ? "null" : props.getString("type");
      String name = props.isNull("name") ? "null" : props.getString("name");
      boolean oneWay = props.isNull("oneway") ? false : props.getBoolean("oneway");
      
      if(!roadType.hasValue(type)) roadType.append(type);
      
      ArrayList<RoadAgent> allowedAccess = new ArrayList<RoadAgent>();
      ArrayList<RoadAgent> allowedAccessBack = new ArrayList<RoadAgent>();
      //if( !type.equals("tunnel") ) allowedAccess.add(RoadAgent.PERSON);
      //if( type.equals("tunnel") || type.equals("primary") || type.equals("residential") ) allowedAccess.add(RoadAgent.CAR);
      for(RoadAgent a : RoadAgent.values()) {
        if(a.isAllowed(type)) {
          allowedAccess.add(a);
          if(a != RoadAgent.CAR || !oneWay) allowedAccessBack.add(a);
        }
      }
      
      JSONArray points = JSONlines.getJSONObject(i).getJSONObject("geometry").getJSONArray("coordinates");
      for(int j=0; j<points.size(); j++) {
        
        // Point coordinates to XY screen position -->
        PVector pos = toXY(points.getJSONArray(j).getFloat(1), points.getJSONArray(j).getFloat(0));
        
        // Node already exists (same X and Y pos). Connect  -->
        Node existingNode = nodeExists(pos.x, pos.y, nodes, allowedAccess);
        if(existingNode != null) {
          if(j>0) {
            prevNode.connect( existingNode, type, name, allowedAccess);
            existingNode.connect(prevNode, type, name, allowedAccessBack);
            //prevNode.connectBoth( existingNode, type, name, allowedAccess );
            //if(oneWay) existingNode.forbid(prevNode, RoadAgent.CAR);
          }
          prevNode = existingNode;
          
        // Node doesn't exist yet. Create it and connect -->
        } else {
          Node newNode = new Node(nodes.size(), pos.x, pos.y, crowdLimit, allowedAccess);
          if(j>0) {
            prevNode.connect( newNode, type, name, allowedAccess );
            newNode.connect( prevNode, type, name, allowedAccessBack);
            //prevNode.connectBoth( newNode, type, name, allowedAccess );
            //if(oneWay) newNode.forbid(prevNode, RoadAgent.CAR);
          }
          nodes.add(newNode);
          prevNode = newNode;
          
        }
        
      }
    }
    
    graph = new Pathfinder(nodes);    
  }
  
  public void InitPOIFromJSon(int curSlide){
    
    JSONArray POIS = slideHandler.getPOIsFromId(curSlide); 
    for (int i = 0; i < POIS.size(); i++) { 
      String file = POIS.getJSONObject(i).getString("file");
      String type = POIS.getJSONObject(i).getString("type");
      String agentType = POIS.getJSONObject(i).getString("AgentType");
      if(agentType.equals("PERSON")){
        streetsAND.loadPOIs(file, type, RoadAgent.PERSON);
      }
      if(agentType.equals("CAR")){
        streetsAND.loadPOIs(file, type, RoadAgent.CAR);
      }
      if(agentType.equals("CAR_RESIDENTIAL")){
        streetsAND.loadPOIs(file, type, RoadAgent.CAR_RESIDENTIAL);
      }   
    }
  }
     //<>// //<>// //<>// //<>// //<>// //<>// //<>//
  /* <--- SETTERS AND GETTERS ---> */
  public void background(String image) { bgImage = loadImage(image); }
  public PVector mapSize() { return size; }
  public void toggleBG() { showBG = !showBG; }
  public void toggleStreetRendering() { showStreetRendering = !showStreetRendering; }
  public boolean isBackgroundVisible() { return showBG; }
  public void toggleRoutes() { showRoutes = (showRoutes + 1) % (RoadAgent.values().length + 1); }
  public void toggleRouteTypes() { showRouteType = (showRouteType + 1) % (roadType.size() + 1); }
  public void toggleTower() { 
    showTower = !showTower;
    hideBackground = ! hideBackground; 
  }
  public void toggleRNC() { showRNC = !showRNC;}
  public void toggleRNCCluster() { showRNCCluster = !showRNCCluster;}
  public void toggleCrowd() { showCrowd = !showCrowd; }
  public void togglePOIs() { showPOIs = !showPOIs; }
  public int size() { return graph.nodesSize(); }
  public ArrayList<Node> getNodes() { return graph.getNodes(); }
  public Node getNode(int i) { return graph.getNodes().get(i); }
  public float getScale() { return scale; }
  
  
  /* <--- METHODS ---> */
 
  
  // FIND NODES BOUNDS -->
  public void setBoundingBox(JSONArray JSONlines) {
    float minLat = Float.MAX_VALUE,
          minLng = Float.MAX_VALUE,
          maxLat = -Float.MAX_VALUE,
          maxLng = -Float.MAX_VALUE;
    for(int i=0; i<JSONlines.size(); i++) {
      JSONArray points = JSONlines.getJSONObject(i).getJSONObject("geometry").getJSONArray("coordinates");
      for(int j=0; j<points.size(); j++) {
        float Lat = points.getJSONArray(j).getFloat(1);
        float Lng = points.getJSONArray(j).getFloat(0);
        if( Lat < minLat ) minLat = Lat;
        if( Lat > maxLat ) maxLat = Lat;
        if( Lng < minLng ) minLng = Lng;
        if( Lng > maxLng ) maxLng = Lng;
      }
    }
    
    // Conversion to Mercator projection -->
    PVector coordsTL = toWebMercator(minLat, minLng);
    PVector coordsBR = toWebMercator(maxLat, maxLng);
    this.bounds = new PVector[] { coordsTL, coordsBR };
    
    // Resize map keeping ratio -->
    float mapRatio = (coordsBR.x - coordsTL.x) / (coordsBR.y - coordsTL.y);
    this.size = mapRatio < 1 ? new PVector( height * mapRatio, height ) : new PVector( width , width / mapRatio ) ;
    this.scale = (coordsBR.x - coordsTL.x) / size.x;
    
  }
  
  
  // RETURN EXISTING NODE (SAME COORDINATES) IF EXISTS -->
  private Node nodeExists(float x, float y, ArrayList<Node> nodes, ArrayList<RoadAgent> allowedAgents) {
    for(Node node : nodes) {
      PVector nodePos = node.getPosition();
      if(nodePos.x == x && nodePos.y == y) {
        node.allow(allowedAgents);
        return node;
      }
    }
    return null;
  }
  
  
  // CONVERT TO WEBMERCATOR PROJECTION
  private PVector toWebMercator( float lat, float lng ) {
    float RADIUS = 6378137f; // Earth Radius
    float sin = sin( radians(lat) );
    return new PVector(lng * radians(RADIUS), ( RADIUS / 2 ) * log( ( 1.0 + sin ) / ( 1.0 - sin ) ));
  }
  
  
  // LAT, LNG COORDINATES TO XY SCREEN POINTS -->
  private PVector toXY(float lat, float lng) {
    PVector projectedPoint = toWebMercator(lat, lng);
    return new PVector(
      map(projectedPoint.x, bounds[0].x, bounds[1].x, 0, size.x),
      map(projectedPoint.y, bounds[0].y, bounds[1].y, size.y, 0)
    );
  }
  
  
  // LOAD POIs FROM FILE -->
  public void loadPOIs(String file, String type, RoadAgent... allowedAgents) { //<>// //<>//
    if(pois == null) pois = new ArrayList<POI>();
    Table _pois = loadTable(file, "header, tsv");
    for(TableRow _poi : _pois.rows()) {
      PVector pos = toXY(_poi.getFloat("LAT"), _poi.getFloat("LNG"));
      // Point inside map bounds -->
      //FIXME: I have to remove this if because of some data where I have some value that are not in 
      //if(pos.x > 0 && pos.x < width && pos.y > 0 && pos.y < height) {
        ArrayList<RoadAgent> allowedClients = new ArrayList<RoadAgent>(); 
        for(RoadAgent a : allowedAgents) allowedClients.add(a);
        pois.add( new POI(this, pois.size(), _poi.getString("NAME"), type, pos, _poi.getInt("CAPACITY"), _poi.getString("LANGUAGES"), 0, allowedClients) );
    }
  }
  
   
  // DRAW ROADMAP -->
  public void draw(PGraphics p) {
    
    if(showBG){
      p.image(bgImage, 0, 0, size.x, size.y);
      g.removeCache(bgImage);
    }
    if(showStreetRendering){
      for(Node n1 : graph.getNodes()) {
        for(Node n2 : n1.connectedNodes()) {
          p.stroke(#AAAAAA); p.strokeWeight(1);
          PVector n1Pos = n1.getPosition(),
                  n2Pos = n2.getPosition();
          p.strokeWeight(3);
          p.line(n1Pos.x, n1Pos.y, n2Pos.x, n2Pos.y);
        } 
      }
    }
    
    if(showCrowd) {
      for(Node n1 : graph.getNodes()) {
        PVector n1Pos = n1.getPosition();
        color c1 = lerpColor(#028E2C, #C23B22, n1.occupancy()*10);
        for(Node n2 : n1.connectedNodes()) {
          PVector n2Pos = n2.getPosition();
          color c2 = lerpColor(#028E2C, #C23B22, n2.occupancy()*10);
          gradientLine(p, n1Pos.x, n1Pos.y, n2Pos.x, n2Pos.y, c1, c2, 3);
        }
      }
    }
    if(showRouteType > 0) {
      String toShow = roadType.get(showRouteType-1);
      for(Node n1 : graph.getNodes()) {
        for(Edge edge : n1.connections()) {
          if( edge.is(toShow) ) {
            PVector n1Pos = n1.getPosition(),
                    n2Pos = edge.getNode().getPosition();
            p.stroke(#FFFFFF, 125); p.strokeWeight(3);
            p.line(n1Pos.x, n1Pos.y, n2Pos.x, n2Pos.y);
          }
        }
      }
    }  
    if(showRoutes > 0) {
      RoadAgent toShow = RoadAgent.values()[showRoutes-1];
      for(Node n1 : graph.getNodes()) {
        for(Edge edge : n1.connections()) {
          //if(edge.isAllowed(toShow)) {
            
            PVector n1Pos = n1.getPosition(),
                    n2Pos = edge.getNode().getPosition();
            
            // DRAW ROADS AND SIDEWALKS
            PVector streetOffset = PVector.sub(n2Pos, n1Pos).normalize().mult(toShow.getStreetOffset()).rotate(HALF_PI);
            p.stroke(edge.isAllowed(toShow) ? #028E2C : #C23B22); p.strokeWeight(1);
            p.line(n1Pos.x + streetOffset.x, n1Pos.y + streetOffset.y, n2Pos.x + streetOffset.x, n2Pos.y + streetOffset.y);
            
            //stroke(#FFFFFF, 125); strokeWeight(1);
            //line(n1Pos.x, n1Pos.y, n2Pos.x, n2Pos.y);
            
          //}
        }
      }
    }
    if(slideHandler.display.getBoolean("tdf")) {
      for(Node n1 : graph.getNodes()) {
        for(Edge edge : n1.connections()) {
          if(edge.name.equals("Avinguda de Tarragona") || edge.name.equals("Avinguda de Salou") || edge.name.equals("Ctra. de l'Obac")){
            PVector n1Pos = n1.getPosition(),
                    n2Pos = edge.getNode().getPosition();
            p.stroke(#FFFF00, 125); p.strokeWeight(3);
           // p.line(n1Pos.x, n1Pos.y, n2Pos.x, n2Pos.y);
          }
            
        }
      }
      p.strokeWeight(1);
    }  
    
    
    
    // Draw POIs -->
    if(showPOIs && pois!=null && model.showAgent == true) {
      for(POI poi : pois) {       
        poi.draw(p);
      }
    }
    
  }
  
  
  // CREATE NODE TO CLOSEST STREET OR ASSIGN CLOSEST ONE --> 
  public Node streetNode(PVector p) {
    Node streetNode = null, n1 = null, n2 = null;
    boolean newNode = false;
    float D = Float.MAX_VALUE;
    
    for( Node n : graph.getNodes() ) {
      PVector n2p = PVector.sub( p, n.getPosition() );
      float n2pD = n2p.mag();
      
      for( Node c : n.connectedNodes() ) {
        PVector n2c = PVector.sub( c.getPosition(), n.getPosition() );
        float n2cD = n2c.mag();
        float a = PVector.angleBetween( n2c, n2p );
        float n2spD = n2pD * cos(a);
        
        // Pos is perpecndicular to street segment -->
        if( n2spD > 0 && n2spD < n2cD) {
          float Di = n2pD * sin(a);
          
          // Point closer to street section --> 
          if( Di < D ) {
            D = Di;
            PVector sp = n.getPosition().add( n2c.setMag( n2spD ) );
            
            ArrayList<RoadAgent> allowedAgents = new ArrayList<RoadAgent>(n.connectionTo(c).getAllowed());
            if(c.connectionTo(n) != null) {
              for(RoadAgent agent : c.connectionTo(n).getAllowed()) {
                if(allowedAgents.indexOf(agent) == -1) allowedAgents.add(agent);
              }
            }
            
            streetNode = new Node(graph.nodesSize(), sp.x, sp.y, crowdLimit, allowedAgents );
            n1 = n;
            n2 = c;
            newNode = true;
          }
        
        // Pos is outside street segment -->
        } else {
          PVector c2p = PVector.sub( p, c.getPosition() );
          float c2pD = c2p.mag();
          
          // Point closer to any extreme node assign it -->
          if( n2pD < D ) {
            D = n2pD;
            streetNode = n;
            newNode = false;
          }
          if( c2pD < D ) {
            D = c2pD;
            streetNode = c;
            newNode = false;
          }
          
        }
      }
    }
    
    // New node is created. Connect to neighbors and disconnect between them -->
    if(newNode) {
      
      Edge link1 = n1.connectionTo(n2);
      Edge link2 = n2.connectionTo(n1);
      
      n1.connect(streetNode, link1.type, link1.name, link1.getAllowed());
      streetNode.connect(n2, link1.type, link1.name, link1.getAllowed());
      if(link2 != null) {
        streetNode.connect(n1, link2.type, link2.name, link2.getAllowed());
        n2.connect(streetNode, link2.type, link2.name, link2.getAllowed());
      }

      n1.disconnect(n2);
      n2.disconnect(n1);
      graph.addNode(streetNode);
    }
    
    return streetNode;
  }
  
  
  // DRAW LINE WITH GRADIENT COLOR -->
  private void gradientLine(PGraphics p, float x1, float y1, float x2, float y2, int c1, int c2, int W) {
    p.noFill(); p.strokeWeight(W);
    p.beginShape(LINES);
      p.stroke(c1);
      p.vertex(x1, y1);
      p.stroke(c2);
      p.vertex(x2, y2);
    p.endShape();
  }
  
 
}



/* POI CLASS ----------------------------------------------------------------------------------------------- */
public class POI {
  /* <--- ATTRIBUTES ---> */
  private RoadNetwork map;
  private int id;
  public String name;
  public String type;
  private PVector pos;
  private Node node;
  private StringList languages;
  public int curRadius = 0;
  public int towerId;
  
  /* <--- CONSTRUCTOR ---> */
  POI(RoadNetwork _map, int _id, String _name, String _type, PVector _pos, int _cap, String _langs, int _towerId, ArrayList<RoadAgent> allowedClients ) {
    map = _map;
    id = _id;
    name = _name;
    type = _type;
    pos = _pos;
    towerId = _towerId;
    
    String[] spoken =  split(_langs,",");
    if(spoken.length == 1 && spoken[0].equals("")) spoken = new String[] {"All"};
    languages = new StringList(spoken);
    
    // Connect POI to roadmap -->
    Node streetNode = map.streetNode(pos);
    node = new Node(map.size(), pos.x, pos.y, _cap, allowedClients);
    node.connectBoth(streetNode, "POI access", name + " access", allowedClients);
    map.graph.addNode(node);
    
  }
  
  
  /* <--- METHODS ---> */
  
  // DRAW POI -->
  public void draw(PGraphics p) {
    if (trafficEquilibrium==false && streetsAND.showRNC == false ){
      // POI marker. From yellow to red depending on crowd -->
      //color stroke = color( 255, map(node.crowd, 0, node.crowdLimit, 255, 0) , 0);
      //Green to red
      //color c = lerpColor(color(0,255,0), color(255,0,0), node.occupancy());
     //Blue tint 
      //color c = lerpColor(#6294B0, #548099, node.occupancy());
      color c= color(255,255,255);
      p.fill(c, 100); p.stroke(c); p.strokeWeight(1); p.rectMode(CENTER);
      //rect(pos.x, pos.y, 6, 6);
      if(type.equals("TopSpots_tdf")){
        p.fill(#FFFF00);
        p.ellipse(pos.x, pos.y, node.crowd, node.crowd);
        if(frameCount % 2 == 0 ){
          curRadius = curRadius+1;
        }
        if(curRadius > node.crowd/2){
          curRadius = 10;
        }
        p.fill(#FFFF00, 50);
        p.ellipse(pos.x, pos.y, curRadius*2, curRadius*2);
      }
      if(type.equals("TopSpots")){
        p.ellipse(pos.x, pos.y, node.crowd, node.crowd);
        if(frameCount % 2 == 0 ){
          curRadius = curRadius+1;
        }
        if(curRadius > node.crowd/2){
          curRadius = 10;
        }
        p.fill(c, 50);
        p.ellipse(pos.x, pos.y, curRadius*2, curRadius*2);
      }
      if(type.equals("Restaurants")){
        //p.ellipse(pos.x, pos.y, 2 + node.occupancy()*sizeFactor, 2 + node.occupancy()*sizeFactor);
        p.ellipse(pos.x, pos.y, 10 + node.crowd, 10 + node.crowd);
      }
      if(type.equals("Parking")){
        p.rect(pos.x, pos.y, 2 + node.crowd*5, 2 + node.crowd*5);
      }  
      if(type.equals("Parking_tdf")){
        p.rect(pos.x, pos.y, 10 + node.crowd*2, 10 + node.crowd*2);
      }  
      // Mouse over POI. Show label -->
      if( dist(mouseX, mouseY, pos.x, pos.y) < 2 + node.occupancy()) {
        String labelText = type + ":  " + name + " " + node.crowd + "/" + node.crowdLimit + "  ";
        p.fill(c); p.noStroke(); p.textSize(10);
        p.rect(pos.x, pos.y-15, p.textWidth(labelText), 17);
        p.fill(#000000); p.textAlign(CENTER,CENTER);
        p.text(labelText, pos.x, pos.y-17);
      }
    } 
  }
  
  
  public boolean isAllowed(RoadAgent type) {
    for(RoadAgent a : node.getAllowed()) {
      if(a == type) return true;
    }
    return false;
  }
  
  // LANGUAGE IS SPOKEN IN POI -->
  public boolean speaks(String lang) {
    if( languages.hasValue("All") || languages.hasValue(lang) ) return true;
    else return false;
  }
  
}