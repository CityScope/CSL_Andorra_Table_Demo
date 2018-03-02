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
class Equilibrium {
  JSONObject JSON;
  JSONArray latArray, lonArray, nationArray;
  PVector[] aNode, bNode;
  float[][] congArray;
  float maxCong=0.5;
  float[] linkHierarchy;
  Equilibrium(JSONObject links_JSON, JSONObject hierarchy_JSON){
     linkHierarchy=hierarchy_JSON.getJSONArray("roadTypes").getFloatArray();
     JSON = links_JSON;
     float[] aNodeLat=JSON.getJSONArray("aNodeLat").getFloatArray();
     float[] bNodeLat=JSON.getJSONArray("bNodeLat").getFloatArray();
     float[] aNodeLon=JSON.getJSONArray("aNodeLon").getFloatArray();
     float[] bNodeLon=JSON.getJSONArray("bNodeLon").getFloatArray();
     JSONArray linkCong=JSON.getJSONArray("linkCong");
     numLinks=aNodeLat.length;
     numPeriods=linkCong.getJSONArray(0).getFloatArray().length;
     aNode=new PVector[numLinks];
     bNode=new PVector[numLinks];
     congArray= new float[numLinks][numPeriods];
     
     for (int l=0; l < numLinks; l = l+1){
     aNode[l]=streetsAND.toXY(aNodeLat[l], aNodeLon[l]);
     bNode[l]=streetsAND.toXY(bNodeLat[l], bNodeLon[l]);
     float[] floatArray=linkCong.getJSONArray(l).getFloatArray();
        for (int j = 0; j < floatArray.length; j = j+1){
          congArray[l][j]=floatArray[j];
        }
     }

  }  
  void draw(PGraphics p){
    keyStoner.offscreen3DTable.colorMode(HSB, 100);
    for (int l=0; l < numLinks; l = l+1){
      float congRatio=((congArray[l][slideHandler.curHour-1])/maxCong);
      float hue=33-sqrt(congRatio)*33;
      p.strokeWeight(linkHierarchy[l]);
      p.stroke(hue,99,100);
      p.line(aNode[l].x, aNode[l].y, bNode[l].x, bNode[l].y);
   }
   p.noStroke();
   p.colorMode(RGB,255);
  }
}