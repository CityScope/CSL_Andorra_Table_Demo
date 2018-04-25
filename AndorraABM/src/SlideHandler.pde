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
public class SlideHandler {
  JSONArray values;
  JSONObject POIs;
  JSONArray agents;
  JSONObject display; 
  JSONObject cdr;
  JSONObject rnc;
  JSONObject rncCluster;
  JSONObject trafficNetwork;
  int fadeInTime = 0;
  int curSlide = 0;
  boolean initSimulation = false; 
  boolean videoMode = true;
  float lastTime;
  float interval = 120000;
  int hourTimer=0;
  public float currentTime = 0;
  public int curHour;
  public int firstHour=1;
  public int curHourDuration= 1000;
  public int curNationality = 0;
  boolean featureKeyPressed = false;

  SlideHandler(String fileName) {
    lastTime = millis();
    values = loadJSONArray(fileName);
    curHour = firstHour;
  }


  JSONObject getCDRFilesFromId(int id) {
    JSONObject slide = values.getJSONObject(id);
    return slide.getJSONObject("CDR");
  }
  
  JSONObject getRNCFilesFromId(int id) {
    JSONObject slide = values.getJSONObject(id);
    return slide.getJSONObject("RNC");
  }
  
  JSONObject getRNCClusterFilesFromId(int id) {
    JSONObject slide = values.getJSONObject(id);
    return slide.getJSONObject("RNCCluster");
  }
  
  JSONObject getTrafficNetworkFilesFromId(int id) {
    JSONObject slide = values.getJSONObject(id);
    return slide.getJSONObject("TrafficNetwork");
  }

  JSONArray getAgentsFromId(int id) {
    JSONObject slide = values.getJSONObject(id);
    return slide.getJSONArray("Agent");
  }

  JSONArray getPOIsFromId(int id) {
    JSONObject slide = values.getJSONObject(id);
    return slide.getJSONArray("POI");
  }

  JSONObject getDisplaySettingsFromId(int id) {
    JSONObject slide = values.getJSONObject(id);
    return slide.getJSONObject("Display");
  }

  int getNbSlides() {
    return values.size();
  }

  void toogleDifferentFeature(int curHour){
    
    if(curHour==5){
      aggregatedHeatmap.visible(Visibility.TOGGLE);
    }
    if(curHour==10){
      aggregatedHeatmap.visible(Visibility.TOGGLE);
      streetsAND.toggleCrowd();
    }
    if(curHour==15){
      streetsAND.toggleCrowd();
      streetsAND.toggleStreetRendering();
    }
  }
  
  void NextSlide(){
    slideHandler.lastTime = millis();
    slideHandler.curSlide = (slideHandler.curSlide + 1) % (slideHandler.getNbSlides()) ;
    simulationTime = 0;
    slideHandler.curHour=slideHandler.firstHour;
    slideHandler.initSimulation = false;
  }
  
  void update(boolean randomChange){
    if(randomChange){
    }else{
    //Trigger every hour
    if (millis() - slideHandler.hourTimer >= slideHandler.curHourDuration) {
      slideHandler.curHour = slideHandler.curHour+1;
      slideHandler.hourTimer = millis();
      if (slideHandler.initSimulation == true){ 
        //slideHandler.toogleDifferentFeature(slideHandler.curHour);
        if(regulatePop){
          model.regulatePop(slideHandler.curHour,10);
        }
      }  
    }
    if (slideHandler.curHour+1 >=  25) {
      slideHandler.NextSlide();
    }
    simulationTime= millis() - slideHandler.lastTime;
    }
  }
}