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
class RNC_Cluster {
  JSONObject JSON, currentObject;
  JSONArray hoursArray, latArray;
  float[] lat, lon;
  PVector[] positions;
  int[] cluster, nation;
  int currentWindow;
  color[] colors= {color(166,206,227),color(31,120,180),color(178,223,138),color(51,160,44),color(251,154,153),color(227,26,28),color(253,191,111),color(255,127,0),color(202,178,214),color(106,61,154),color(255,255,153),color(177,89,40)};
  RNC_Cluster(JSONObject _JSON){
    JSON = _JSON;
    //hoursArray=JSON.getJSONArray("hours");
    currentWindow=0;
    //currentObject=JSON.getJSONArray("hours").getJSONObject(currentHour);
    //currentObject=JSON.getJSONObject(Integer.toString(currentWindow));
    currentObject=JSON.getJSONArray("data").getJSONObject(currentWindow);
    lat=currentObject.getJSONArray("lat").getFloatArray();
    lon=currentObject.getJSONArray("lon").getFloatArray();
    cluster=currentObject.getJSONArray("Cid").getIntArray();
    //nation=currentObject.getJSONArray("nations").getIntArray();
    positions=new PVector[lat.length];
    for (int i=0;i<lat.length;i=i+1){
      positions[i]=streetsAND.toXY(lat[i], lon[i]);      
    }

  }
  void update(){
    int nMinWindow=(hours*60+minutes)/20;
    if (currentWindow!=nMinWindow){
      currentObject=JSON.getJSONArray("data").getJSONObject(currentWindow);
      lat=currentObject.getJSONArray("lat").getFloatArray();
      lon=currentObject.getJSONArray("lon").getFloatArray();
      cluster=currentObject.getJSONArray("Cid").getIntArray();
      //nation=currentObject.getJSONArray("nations").getIntArray();
      positions=new PVector[lat.length];
      for (int i=0;i<lat.length;i=i+1){
        positions[i]=streetsAND.toXY(lat[i], lon[i]);      
      }
    currentWindow=nMinWindow;
    }    
  }
  
  void draw(PGraphics p){
    
      for (int i=0; i<lat.length; i++){
        int clust=cluster[i];
        color col=colors[clust%colors.length];
        PVector tmpP=positions[i];
        p.fill(col);
        p.ellipse(tmpP.x, tmpP.y, 5, 5);
      }

   }  
 

}