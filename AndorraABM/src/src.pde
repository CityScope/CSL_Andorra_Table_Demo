/* //<>// //<>// //<>// //<>// //<>// //<>// //<>//
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

Drawer keyStoner;
PhysicalInterface buttons;

public int displayWidth = 2000;
public int displayHeight = 1000;
public int playGroundWidth = displayWidth;
public int playGroundHeight = displayHeight;

/* GLOBAL VARIABLES ------------------------------------------------- */
RoadNetwork streetsAND;
String roadNetworkName = "GIS/RoadNetwork/ANDroads.geojson";
ABM model;
RNC rnc, baseRnc;
RNC_Cluster rncCluster;
Equilibrium equilibrium;

ArrayList<Agent> agentsSelected;
Agent agentSelected;

Heatmap instantHeatmap, aggregatedHeatmap, rncHeatmap;

ArrayList<City> externalCities;
ArrayList<Highway> highways;

JSONObject jsonExternalCity;
JSONObject jsonCenterAggregated;
JSONObject jsonRNC, jsonRNCCluster;
JSONObject jsonBaseRNC;
JSONObject links;
JSONObject hierarchy;

PVector UpperLeft;
PVector UpperRight;
PVector LowerRight;
PVector LowerLeft;
//SLIDER Variable
public float demoSpeed = 0.3;
public float simulationTime = 0;
int minutes, hours;
public boolean simulationPaused = false;

boolean tableView = true;
boolean printLegend = true;
PImage backgroundImage;
PImage bgImage;
SlideHandler slideHandler;
AggregatedData aggregatedData;
int externalCityTimerStep=0;
int towerTimerStep=0;
int numLinks, numPeriods;
boolean regulatePop= false;
boolean trafficEquilibrium = false;
boolean btController=true;
boolean multiProj=false;

/*-------- CityMatrix -------------*/
public boolean cityIO = true; //Considering that cityIO is running 
public boolean showCityMatrix = true; 
Grid cityMatrix;
String CityMatrixUrl = "https://cityio.media.mit.edu/api/table/citymatrix";
int blockSize= 10;
boolean isGridHasChanged=true;
JSONObject jsonCityIO = new JSONObject();

/* INIT ------------------------------------------------------------- */
void setup() {
  // Loads Fontss
  loadFonts();
  fullScreen(P3D, 2);
  //size(displayWidth, displayHeight, P3D);

  buttons = new PhysicalInterface(this); 
  streetsAND = new RoadNetwork(roadNetworkName);   
  model = new ABM(streetsAND);
  UpperLeft = streetsAND.toXY(42.505086, 1.509961);
  UpperRight = streetsAND.toXY(42.517066, 1.544024);
  LowerRight = streetsAND.toXY(42.508161, 1.549798);
  LowerLeft = streetsAND.toXY(42.496164, 1.515728);
  keyStoner = new Drawer(this);
  instantHeatmap = new Heatmap(0, 0, width, height);
  instantHeatmap.setBrush("ressources/HeatMap/heatmapBrush.png", 80);
  instantHeatmap.addGradient("cold", "ressources/HeatMap/cold_transp.png");
  instantHeatmap.addGradient("hot", "ressources/HeatMap/hot_transp.png");
  aggregatedHeatmap = new Heatmap(0, 0, width, height);
  aggregatedHeatmap.setBrush("ressources/HeatMap/heatmapBrush.png", 80);
  aggregatedHeatmap.addGradient("cold", "ressources/HeatMap/cold_transp.png");
  rncHeatmap = new Heatmap(0, 0, width, height);
  rncHeatmap.setBrush("ressources/HeatMap/heatmapBrush.png", 80);
  rncHeatmap.addGradient("hot", "ressources/HeatMap/hot_transp.png");
  rncHeatmap.addGradient("cold", "ressources/HeatMap/cold_transp.png");
  backgroundImage = loadImage("data/GIS/Background/earth_blurred.jpg");
  bgImage = loadImage("data/GIS/Background/AndorraBG_HR.jpg");

  if (tableView) {
    keyStoner.initTableView();
  } else {
    keyStoner.initScreenView();
  }
  slideHandler = new SlideHandler("ressources/Slides/slides.json");
  aggregatedData = new AggregatedData();
  cityMatrix = new Grid(new PVector(1300, 700), 16, 16, blockSize);
  if (cityIO) {
    try {
      loadJSONObject(CityMatrixUrl);
      jsonCityIO = loadJSONObject(CityMatrixUrl);
    }
    catch(Exception e) {
      println("The connexion to " + CityMatrixUrl + " failed");
      cityIO = false; //if cityIO crashed at least the simulation can starts withotu linking to cityMatrix
    }
  }
  isGridHasChanged = true;
  hierarchy= loadJSONObject("Mobility/Equilibrium/roadHierarchy.json");
  jsonBaseRNC=loadJSONObject("Mobility/RNC/syntheticRnc10MinStaysCEST2016_07_03.json");
}


/* RUN ------------------------------------------------------------- */
void draw() {

  if (slideHandler.videoMode == true) {
    slideHandler.update(false);
  }
  //initSimulation is set to false by the SlideHandler slideHandler.NextSlide()
  if (slideHandler.initSimulation == false) {
    //POI
    streetsAND = new RoadNetwork(roadNetworkName);
    //AGENT
    model = new ABM(streetsAND); 
    slideHandler.cdr = slideHandler.getCDRFilesFromId(slideHandler.curSlide); 
    jsonExternalCity = loadJSONObject(slideHandler.cdr.getString("cities"));
    jsonCenterAggregated = loadJSONObject(slideHandler.cdr.getString("center"));
    //CDR Tower
    InitTowerFromJSON(jsonCenterAggregated);
    createTowerGraph();
    //External Cities
    initExternalCities();
    //POI
    streetsAND.InitPOIFromJSon(slideHandler.curSlide);
    AssignPOIToTower();
    //CDR
    model.InitModel(slideHandler.curSlide); 
    aggregatedData.Init("Centre");
    slideHandler.initSimulation = true;
    slideHandler.display = slideHandler.getDisplaySettingsFromId(slideHandler.curSlide); 
    streetsAND.showStreetRendering = slideHandler.display.getBoolean("road");
    streetsAND.showPOIs = slideHandler.display.getBoolean("poi");
    //RNC 
    slideHandler.rnc = slideHandler.getRNCFilesFromId(slideHandler.curSlide); 
    slideHandler.rncCluster = slideHandler.getRNCClusterFilesFromId(slideHandler.curSlide);
    jsonRNC = loadJSONObject(slideHandler.rnc.getString("file"));
    jsonRNCCluster = loadJSONObject(slideHandler.rncCluster.getString("file"));
    rnc = new RNC(jsonRNC);
    rncCluster = new RNC_Cluster(jsonRNCCluster);
    baseRnc=new RNC(jsonBaseRNC);      
    //traffic Equilibrium
    slideHandler.trafficNetwork = slideHandler.getTrafficNetworkFilesFromId(slideHandler.curSlide);
    links = loadJSONObject(slideHandler.trafficNetwork.getString("file"));
    equilibrium=new Equilibrium(links, hierarchy);
  }
  drawScene();
  buttons.update();
}


/* Draw ------------------------------------------------------ */
void drawScene() {
  background(0);
  keyStoner.drawFaltTableView();
  keyStoner.draw3DTableView();
}

/* INTERACTION ------------------------------------------------------ */
void mouseReleased() {
  if (tableView==true) {
    //PVector mousePos = keyStoner.surfacePin3DTable.getTransformedMouse();
    //agentsSelected = model.select(int(mousePos.x),int(mousePos.y));  // Select agents under mouse
  } else {
    agentsSelected = model.select(mouseX, mouseY);
  }
}

void keyPressed() {
  switch(key) {
    //Keystone trigger  
  case 'k':
    keyStoner.ks.toggleCalibration();
    break;  
  case 'l':
    keyStoner.ks.load();
    break; 
  case 's':
    keyStoner.ks.save();
    break;
  case ' ':  // pause simulation
    simulationPaused = !simulationPaused;
    if (simulationPaused == true) {
      noLoop();
    } else {
      loop();
    }
    break;
  case '+':  // Increase speed
    model.speed(0.05);
    break;
  case '-':  // Decrease speed
    model.speed(-0.05);
    break;
  case 'x':  // Toggle route typeview
    streetsAND.toggleRoutes();
    break;
  case 'w':  // Toggle route typeview
    streetsAND.toggleRouteTypes();
    break;
  case 'a':  // Toggle agents vi  
    model.toggle();
    break;
  case 'd': // Toggle instant Density heatmap
    instantHeatmap.visible(Visibility.TOGGLE);
    if ( instantHeatmap.isVisible() ) {
      instantHeatmap.clear();
      ArrayList<Agent> people = new ArrayList();
      ArrayList<Agent> cars = new ArrayList();
      for (Agent agent : model.getAgents()) {
        if (agent.getType() == RoadAgent.CAR) cars.add(agent);
        else people.add(agent);
      }
      instantHeatmap.update("People Density", people, "cold", false);
      instantHeatmap.update("Cars Density", cars, "hot", true);
    }
    break;
  case 'h': // Toggle aggregated Heatmap
    aggregatedHeatmap.visible(Visibility.TOGGLE);
    break;    
    /*case 'q': // Toggle rnc Heatmap
     rncHeatmap.visible(Visibility.TOGGLE);
     break;*/
  case 'p':  // Toggle POIs view
    streetsAND.togglePOIs();
    break;
  case 'c':  // Toggle congestion view
    streetsAND.toggleCrowd();
    break;
  case 'b':  // Toggle background view
    streetsAND.toggleBG();
    break; 
  case 'r':  // Toggle Street Rendering
    streetsAND.toggleStreetRendering();
    break;
    //Demo table trigger  
  case 'n':  // Toggle Next Slide
    slideHandler.NextSlide();
    break;
  case 'v':  // Toggle Slide VideoMode
    slideHandler.videoMode = !slideHandler.videoMode;
    break;
  case 'm':  // Toggle CityMatrix
    showCityMatrix = !showCityMatrix;
    break;
  case 't':  // Toggle tower view
    streetsAND.toggleTower();
    model.toggleShowAgent();
    break;
  case 'z':  // Toggle Pop Regulation
    regulatePop=!regulatePop ;
    break;
  case 'e':
    trafficEquilibrium=!trafficEquilibrium;
    break;
  case 'y':
    streetsAND.toggleRNC();
    if (streetsAND.showRNCCluster) streetsAND.toggleRNCCluster();
    break;
  case 'u':
    streetsAND.toggleRNCCluster();
    if (streetsAND.showRNC) streetsAND.toggleRNC();
    break;
  case 'f':
    model.selectRandomAgent();
    break;
  }
}