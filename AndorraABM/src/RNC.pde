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
class RNC {
  JSONObject JSON;
  JSONArray latArray, lonArray, nationArray, expiryArray;
  ArrayList<PVector> positions;
  ArrayList<Integer> expiry, nation;
  int currentWindow;
  RNC(JSONObject _JSON){
    JSON = _JSON;
    latArray = JSON.getJSONArray("lat");
    lonArray = JSON.getJSONArray("lon");
    nationArray = JSON.getJSONArray("nations");
    expiryArray = JSON.getJSONArray("end");
    positions=new ArrayList<PVector>();
    expiry=new ArrayList<Integer>();
    nation=new ArrayList<Integer>();
    currentWindow=0;
  }
  void update(){
    // only do the update if the time has advanced to the next 10 minute window
    int tenMinWindow=(hours*60+minutes)/10;
    if (currentWindow!=tenMinWindow){
    // find agent positions which are expired and remove them
    for (int i=0; i<expiry.size(); i++){
      if (expiry.get(i)<=tenMinWindow){
      expiry.remove(i);
      nation.remove(i);
      positions.remove(i);
      }
      
    }
    // add the new agent positions for this period
    float[] curLatArray=latArray.getJSONArray(tenMinWindow).getFloatArray();
    float[] curLonArray=lonArray.getJSONArray(tenMinWindow).getFloatArray();
    int[] curNationArray=nationArray.getJSONArray(tenMinWindow).getIntArray();
    int[] curExpiryArray=expiryArray.getJSONArray(tenMinWindow).getIntArray();
    int numNewEntries=curNationArray.length;
    for(int i=0; i<numNewEntries; i++) {
      PVector tmp=streetsAND.toXY(curLatArray[i], curLonArray[i]);
      positions.add(tmp);
      expiry.add(curExpiryArray[i]);
      nation.add(curNationArray[i]);      
    }
    currentWindow=tenMinWindow;
    }
  }
  
  void draw(PGraphics p){
      for (int i=0; i<expiry.size(); i++){
        
        int tmpN=nation.get(i);
        if(tmpN==214){
          if ((model.agentsToShow==0)||(model.agentsToShow==1)){
          PVector tmpP=positions.get(i);
          p.fill(#E67E22);
          p.ellipse(tmpP.x, tmpP.y, 5, 5);
          }
        }
        else if(tmpN==208){
          if ((model.agentsToShow==0)||(model.agentsToShow==2)){
          PVector tmpP=positions.get(i);
          p.fill(#0000FF);
          p.ellipse(tmpP.x, tmpP.y, 5, 5);
          }
        }
        else if(tmpN==213){
          //PVector tmpP=positions.get(i);
          //p.fill(#FFFF00);
          //p.ellipse(tmpP.x, tmpP.y, 5, 5);
        } 
        else {
        if ((model.agentsToShow==0)||(model.agentsToShow==3)){
        PVector tmpP=positions.get(i);
        p.fill(#DDDDDD);
        p.ellipse(tmpP.x, tmpP.y, 5, 5);
        }
      }
      
   }   
 }

}