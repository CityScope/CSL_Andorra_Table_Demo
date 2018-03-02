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

/////////////////////////////////////////// AGGREGATED DATA //////////////////
public class AggregatedData {
  ArrayList<Integer> frenchPops;
  ArrayList<Integer> spanishPops;
  ArrayList<Integer> otherPops;
  int[] totFrenchPops = new int[24];
  int[] totSpanishPops = new int[24];
  int[] totOtherPops = new int[24];
  float fRatio;
  float sRatio;
  float oRatio;
  float popSize;
  int barSize=10;
  int barHeight= 5;
  int topPop;
  AggregatedData() {  
    frenchPops = new ArrayList<Integer>();
    spanishPops = new ArrayList<Integer>();
    otherPops = new ArrayList<Integer>();
  }

  public void Init(String cityName) {
    topPop = GetCenterPopFromTower();
    setPopFromCenter(cityName);
    setTotalPop();
  }
  //FIXME: Remove this one
  public int GetCenterPopFromTower() {
    int size=0;
    for (Tower t : towers) {
      size = size + t.frenchPops.get(slideHandler.curHour-1)+ t.spanishPops.get(slideHandler.curHour-1)+ t.otherPops.get(slideHandler.curHour-1);
    }
    return size;
  }
  
  public int GetTotalCenterPoPFromJSon(String cityName) {
    int totPop = 0;
    JSONObject curCity = jsonExternalCity.getJSONObject(cityName);
    JSONArray curPop = curCity.getJSONArray("hourly_pop");
    //Update daily pop
    for (int i = 0; i < curPop.size(); i++) {
      JSONArray pop = curPop.getJSONArray(i);
      totPop = totPop + pop.getInt(0) + pop.getInt(1) + pop.getInt(2);
    }
    return totPop;
  }

  public int GetTotalCallFromCenter(String cityName) {
    int totPop = 0;
    JSONObject curCity = jsonExternalCity.getJSONObject(cityName);
    JSONArray curPop = curCity.getJSONArray("hourly_pop");
    //Update daily pop
    for (int i = 0; i < curPop.size(); i++) {
      JSONArray pop = curPop.getJSONArray(i);
      totPop = totPop + pop.getInt(0) + pop.getInt(1) + pop.getInt(2);
    }
    return totPop;
  }


  public void setPopFromCenter(String cityName) {
    totFrenchPops = new int[24];
    totSpanishPops = new int[24];
    totOtherPops = new int[24];
    JSONObject curCity = jsonExternalCity.getJSONObject(cityName);
    JSONArray curPop = curCity.getJSONArray("hourly_pop");
    //Update daily pop
    frenchPops.clear();
    spanishPops.clear();
    otherPops.clear();
    for (int i = 0; i < curPop.size(); i++) {
      JSONArray pop = curPop.getJSONArray(i);
      frenchPops.add(pop.getInt(0));
      spanishPops.add(pop.getInt(1));
      otherPops.add(pop.getInt(2));
    }
  } 
  
  public void setTotalPop() {
    for (City c: externalCities){
    JSONObject curCity = jsonExternalCity.getJSONObject(c.name);
    JSONArray curPop = curCity.getJSONArray("hourly_pop");
    for (int i = 0; i < curPop.size(); i++) {
      JSONArray pop = curPop.getJSONArray(i);
      totFrenchPops[i] = totFrenchPops[i] + pop.getInt(0);
      totSpanishPops[i] = totSpanishPops[i] + pop.getInt(1);
      totOtherPops[i] = totOtherPops[i] + pop.getInt(2);
    }
    }
  } 

  public void updatePopList() {
    popSize = frenchPops.get(slideHandler.curHour-1)+ spanishPops.get(slideHandler.curHour-1)+ otherPops.get(slideHandler.curHour-1);
    fRatio = frenchPops.get(slideHandler.curHour-1)/popSize*2*PI;
    sRatio = spanishPops.get(slideHandler.curHour-1)/popSize*2*PI;
    oRatio = otherPops.get(slideHandler.curHour-1)/popSize*2*PI;
  }

   public void drawTotalPopHistogram(PGraphics p, float x, float y, int step, int depth) {
    p.fill(#FFFFFF);
    p.noStroke();
    for (int i= 0; i<24; i++) {
      p.rect(x+i*step, y, step, -(totFrenchPops[i]+ totSpanishPops[i]+ totOtherPops[i])/depth);
    }

    p.fill(#000000);
    p.rect(x+slideHandler.curHour*step, y, step, -(totFrenchPops[slideHandler.curHour]+ totSpanishPops[slideHandler.curHour]+ totOtherPops[slideHandler.curHour])/depth);
  }
  
  
  public void drawTotalPopHistogramByPop(PGraphics p, float x, float y, int step, int depth) {
    for (int i= 0; i<24; i++) {      
      p.stroke(#2D34EA);
      p.fill(#2D34EA);
      p.rect(x+i*step, y, step, -(totFrenchPops[i])/depth);
      p.stroke(#e67e22);
      p.fill(#e67e22);
      p.rect(x+i*step, y-(totFrenchPops[i]/depth), step, -(totSpanishPops[i])/depth);
      p.stroke(#AAAAAA);
      p.fill(#AAAAAA);
      p.rect(x+i*step, y - (totFrenchPops[i]+ totSpanishPops[i])/depth, step, -(totOtherPops[i])/depth);
    }
    p.fill(#FF0000);
    p.noStroke();
  }

  //FIXME: factorize with Exernal City
  public void drawExternalPopHistogram(PGraphics p, float x, float y, int step) {
    p.fill(#FFFFFF);
    p.noStroke();
    for (int i= 0; i<24; i++) {
      p.rect(x+i*step, y, step, -(frenchPops.get(i)+ spanishPops.get(i)+ otherPops.get(i))/200);
    }
    p.textAlign(LEFT);
    //p.text(int((frenchPops.get(slideHandler.curHour)+ spanishPops.get(slideHandler.curHour)+ otherPops.get(slideHandler.curHour))),x+85,y-100);
    p.fill(#000000);
    p.rect(x+slideHandler.curHour*step, y, step, -(frenchPops.get(slideHandler.curHour)+ spanishPops.get(slideHandler.curHour)+ otherPops.get(slideHandler.curHour))/200);
  }
  //FIXME: factorize with Exernal City
  public void drawCurrentStackedBAr(PGraphics p, float x, float y ) {
    updatePopList();
    p.stroke(#2D34EA);
    p.fill(#2D34EA);
    p.rect(x, y, fRatio*barSize, -barHeight);
    p.stroke(#e67e22);
    p.fill(#e67e22);
    p.rect(fRatio*barSize+x, y, sRatio*barSize, -barHeight);
    p.stroke(#AAAAAA);
    p.fill(#AAAAAA);
    p.rect(fRatio*barSize+sRatio*barSize+x, y, oRatio*barSize, -barHeight);
  }
}