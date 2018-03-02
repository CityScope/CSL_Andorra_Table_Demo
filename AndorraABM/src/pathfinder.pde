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
// Pathfinder class by Aaron Steed 2007 http://www.robotacid.com/PBeta/AILibrary/Pathfinder/index.html
// Modified by Marc Vilella to adapt the Andorra ABM - May 2016
//
// Generation and manipulation of a graph for a street network.
// A* search for optimal pathfinding algorithm is performed
// ----------------------------------------------------------------------------------------------------------

/* PATHFINDER CLASS --------------------------------------------------------------------------------------- */
public class Pathfinder{

  /* <--- ATTRIBUTES --->*/
  public ArrayList<Node> nodes; // Storage ArrayList for the Nodes
  public boolean manhattan = false; // Setting for using Manhattan distance measuring method (false uses Euclidean method)


  /* <--- CONSTRUCTOR ---> */
  public Pathfinder(ArrayList<Node> nodes){
    this.nodes = nodes;
  }


  /* <--- METHODS --->*/
  
  public void addNode(Node node) { this.nodes.add(node); }
  public void addNodes(ArrayList<Node> nodes){ this.nodes.addAll(nodes); }
  public ArrayList<Node> getNodes() { return nodes; }
  public int nodesSize() { return nodes.size(); }
  
  // A* SEARCH --->
  public ArrayList<Node> aStar(Node start, Node finish, RoadAgent type){
    
    for(Node node : nodes) node.reset();
    
    ArrayList<Node> open = new ArrayList(); // Possible Nodes for consideration
    ArrayList<Node> closed = new ArrayList(); // Best of the Nodes
  
    open.add(start);
    while(open.size() > 0){
      
      float lowestF = Float.MAX_VALUE;
      Node currNode = null;
      
      for(Node node : open) {
        if(node.getF() < lowestF) {
          lowestF = node.getF();
          currNode = node;
        }
      }
      
      open.remove(currNode);
      closed.add(currNode);

      if(currNode == finish) break;

      for(Edge edge : currNode.connections()) {
        if(edge.isAllowed(type)) {
          Node neighbor = edge.getNode();
          if( neighbor.isWalkable() && neighbor.isAllowed(type) && !arrayListContains(closed, neighbor) ) {
            if(!arrayListContains(open, neighbor)) {
              open.add(neighbor);
              neighbor.setParent(currNode);
              neighbor.setG(edge);
              if(manhattan) neighbor.MsetF(finish);
              else neighbor.setF(finish);
            } else {
              if( neighbor.getG() > currNode.getG() + edge.getDist() ) {
                neighbor.setParent(currNode);
                neighbor.setG(edge);
                if(manhattan) neighbor.MsetF(finish);
                else neighbor.setF(finish);
              }
            }
          }
        }
      }      
    }
    
    ArrayList<Node> path = getPath(finish);
    
    /*
    // Hack to provide a compromise path when a route to the finish node is
    // unavailable
    Node test = (Node) path.get(path.size() - 1);
    if(test == finish){
      float leastDist = Float.MAX_VALUE;
      Node bestNode = null;
      for(int i = 0; i < closed.size(); i++){
        Node n = (Node) closed.get(i);
        float nDist = n.dist(finish);
        if(nDist < leastDist){
          leastDist = nDist;
          bestNode = n;
        }
      }
      if(bestNode.parent != null){
        pathNode = bestNode;
        path = new ArrayList<Node>();
        while(pathNode != null){
          path.add(pathNode);
          pathNode = pathNode.parent;
        }
      }
    }
    */

    return path.size() > 1 ? path : null;
    
  }


  // RETRIEVE PATH FOR A DESTINATION NODE --->
  public ArrayList<Node> getPath(Node pathNode){
    ArrayList<Node> path = new ArrayList<Node>();
  
    while(pathNode != null) {
      path.add(pathNode);
      pathNode = pathNode.parent;
    }
    return path;
  }

  
  // DISCONNECT UNWALKABLE NODES --->
  public void disconnectUnwalkables(){
    for(Node node : nodes) {
      if(!node.isWalkable()) node.disconnect();
    }
  }


  // UTILITIES -->

  // Faster than running ArrayList.contains - we only need the reference, not an object match
  public boolean arrayListContains(ArrayList<Node> c, Node n){
    for(int i = 0; i < c.size(); i++){
      Node o = (Node) c.get(i);
      if(o == n) return true;
    }
    return false;
  }

  // Faster than running ArrayList.indexOf - we only need the reference, not an object match
  public int indexOf(Node n){
    for(int i = 0; i < nodes.size(); i++){
      Node o = (Node) nodes.get(i);
      if(o == n) return i;
    }
    return -1;
  }

}


   
/* NODE CLASS ---------------------------------------------------------------------------------------------- */
public class Node {

  /* <--- ATTRIBUTES ---> */
  private int id;
  private PVector pos;
  private Node parent = null; // Parent Node setting
  private float f = 0.0f; // Sum of goal and heuristic calculations
  private float g = 0.0f; // Cost of reaching goal
  private float h = 0.0f; // Heuristic distance calculation
  private ArrayList<Edge> links = new ArrayList<Edge>(); // Edges to other Nodes
  private boolean walkable = true; // Is this Node to be ignored?
  private ArrayList<RoadAgent> allowedAgents;
  private int crowd = 0,
              crowdLimit; 

  /* <--- CONSTRUCTORS ---> */
  public Node(int id, float x, float y, int crowdLimit, ArrayList<RoadAgent> allowedAgents){
    this.id = id;
    this.pos = new PVector(x, y);
    this.crowdLimit = crowdLimit;
    this.allowedAgents = allowedAgents;
  }


  /* <--- SETTERS AND GETTERS ---> */
  public PVector getPosition() { return new PVector(pos.x, pos.y); }
  
  public boolean isWalkable() {
    return walkable;
  }
  
  public ArrayList<RoadAgent> getAllowed() {
    return allowedAgents;
  }
  
  // FIELD TOOLS --->
  public void setG(Edge o) { g = parent.g + o.distance; }
  public float getG() { return g; }
  public void setH(Node finish) { h = distance(finish); }  // Euclidean distance heuristic
  public void setF(Node finish) {
    setH(finish);
    f = g + h;
  }
  public float getF() { return f; }
  public void MsetF(Node finish){
    MsetH(finish);
    f = g + h;
  }
  public void MsetH(Node finish) { h = manhattan(finish); }  // Manhattan distance heuristic
  public void setParent(Node node) { parent = node; }
  
  public void reset(){
    parent = null;
    f = g = h = 0;
  }


  /* <--- METHODS ---> */
  
  // CONNECTIONS TOOLS ---------->
  
  // CONNECT NODE --->
  public void connect(Node node, String type, String name, ArrayList<RoadAgent> allowedAgents) {
    links.add(new Edge(node, distance(node), type, name, allowedAgents));
  }

  public void connectBoth(Node node, String type, String name, ArrayList<RoadAgent> allowedAgents) {
    connect(node, type, name, allowedAgents);
    node.connect(this, type, name, allowedAgents);
  }
  
  
  // CHECK CONNECTIONS (ALL, OR TO OTHER NODES) --->
  public ArrayList<Edge> connections() { return links; }
  
  public ArrayList<Node> connectedNodes() {
    ArrayList<Node> conn = new ArrayList<Node>();
    for(Edge edge : connections()) conn.add(edge.getNode());
    return conn;
  }
  
  public boolean connectedTo(Node node) {
    for(Node n : connectedNodes()) {
      if(n == node) return true;
    }
    return false;
  }

  public boolean connectedTogether(Node node) {
    for(Node n : connectedNodes()) {
      if(n == node) {
        for(Node n2 : n.connectedNodes()) {
          if(n2 == this) return true;
        }
      }
    }
    return false;
  }

  // DISCONNECT --->
  public void disconnect(Node node) {
    for(Edge edge : connections()) {
      if(edge.getNode() == node) {
        connections().remove(edge);
        break;
      }
    }
  }
  
  // DISCONNECT (INCOMING) NODE FROM NEIGHBOURS --->
  public void disconnect() {
    for(Node node : connectedNodes()) {
      node.disconnect(this);
    }
  }
  

  // LOCATION TOOLS ------>

  // Euclidean distance measuring for accuracy --->
  public float distance(Node node) {
    PVector nodePos = node.getPosition();
    return dist(pos.x, pos.y, nodePos.x, nodePos.y);
  }

  // Manhattan distance measuring for avoiding jagged paths --->
  public float manhattan(Node node) {
    PVector nodePos = node.getPosition();
    return ((pos.x - nodePos.x) * (pos.x - nodePos.x)) + ((pos.y - nodePos.y) * (pos.y - nodePos.y));
  }
  
  
  // CUSTOM TOOLS --->
  
  public void allow(ArrayList<RoadAgent> allowed) {
    for(RoadAgent a : allowed) {
      if(!isAllowed(a)) allowedAgents.add(a);
    }
  }
  
  public boolean isAllowed(RoadAgent type) {
    for(RoadAgent a : allowedAgents) {
      if(a == type) return true;
    }
    return false;
  }
  
  public void forbid(Node node, RoadAgent agent) {
    for(Edge edge : connections()) {
      if(edge.getNode() == node) edge.forbid(agent);
    }
  }
  
  public Edge connectionTo(Node node) {
    for(Edge edge : connections()) {
      if(edge.getNode() == node) return edge;
    }
    return null;
  } 
  
  public void crowd(int inc) {
    crowd += inc;
    walkable = crowd >= crowdLimit ? false : true;
  }
  
  public float occupancy() { return float(crowd) / crowdLimit; }
  
  public void capacity( int c ) { crowdLimit = c; }


  // UTILITY TOOLS --->
  
  // Faster than ArrayList indexOf's --->
  public int indexOf(Node n){
    for(int i = 0; i < connections().size(); i++) {
      Edge c = (Edge) connections().get(i);
      if(c.node == n) return i;
    }
    return -1;
  }
  
}



/* EDGE CLASS ----------------------------------------------------------------------------------------------- */
public class Edge {

  public Node node;
  public float distance;
  public String type;
  public String name;
  public ArrayList<RoadAgent> allowedAgents;

  public Edge(Node node, float dist, String type, String name, ArrayList<RoadAgent> allowed) {
    this.node = node;
    this.distance = dist;
    this.type = type;
    this.name = name;
    this.allowedAgents = allowed;
  }
  
  public float getDist() { return distance; }
  public Node getNode() { return node; }
  
  public boolean is(String what) {
    return type.equals(what);
  }
  
  public void forbid(RoadAgent type) {
    allowedAgents.remove(type);
    println("  FORBIDDEN CARS IN " + name + " TO " +node.id);
  }
  
  public boolean isAllowed(RoadAgent type) {
    for(RoadAgent a : allowedAgents) {
      if(a == type) return true;
    }
    return false;
  }
  
  public ArrayList<RoadAgent> getAllowed() {
    return allowedAgents;
  }
  
}