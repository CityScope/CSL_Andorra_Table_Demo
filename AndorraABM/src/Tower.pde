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
 
public class Tower {
  ArrayList<POI> amenities;
  PVector loc;
  int id;
  String name;
  PVector screenLoc;
  int size;
  ArrayList<ExternalAgent> pop;
  ArrayList<Integer> frenchPops;
  ArrayList<Integer> spanishPops;
  ArrayList<Integer> otherPops;
  public int curRadius = 0;
  float fRatio;
  float sRatio;
  float oRatio;
  float popSize;
  int barSize=10;
  int barHeight= 5;
  ArrayList<PVector> connectedTowers;

  Tower(PVector _location, int _id, String _name) {
    amenities = new ArrayList<POI>();
    loc = _location;
    id = _id; 
    name = _name;
    screenLoc = streetsAND.toXY(loc.x, loc.y);
    size=50;
    pop = new ArrayList<ExternalAgent>(); 
    frenchPops = new ArrayList<Integer>();
    spanishPops = new ArrayList<Integer>();
    otherPops = new ArrayList<Integer>();
    connectedTowers = new ArrayList<PVector>();
  }

  public  ArrayList<POI> getAmenities() {
    return amenities;
  }

  public POI getAmenity(int i) {
    return amenities.get(i);
  }

  void draw(PGraphics p) {
    p.noFill();
    p.stroke(#AAAAAA);
    p.ellipse(screenLoc.x, screenLoc.y, size, size);
    p.fill(255, 125);
    p.ellipse(screenLoc.x, screenLoc.y, size/1.4, size/1.4);
    p.textFont(font12);
    p.text("id:"+id, screenLoc.x, screenLoc.y, size/1.4, size/1.4);  
    p.ellipse(screenLoc.x, screenLoc.y, size, size);    
    for (int i = pop.size()-1; i >= 0; i--) {
      pop.get(i).draw(p, true);
    }
    
  }

  void drawAssociatedAmenities(PGraphics p) {
    for (POI a : amenities) {
      p.fill(125);
      PVector tmp = streetsAND.toXY(a.pos.x, a.pos.y);
      p.rect(tmp.x, tmp.y, size, size);
    }
  }
}


JSONArray networkCDR; 
ArrayList<Tower> towers;

public void InitTowerFromJSON(JSONObject obj) {
  towers = new ArrayList<Tower>();
  String[] properties;
  properties = (String[]) obj.keys().toArray(new String[obj.size()]);
  for (int i= 0; i<obj.size(); i++) {
    JSONObject curTower = obj.getJSONObject(properties[i]);
    Tower tower = new Tower(new PVector(curTower.getJSONArray("location").getFloat(0), curTower.getJSONArray("location").getFloat(1)), curTower.getInt("label"), properties[i]);
    towers.add(tower);
    JSONArray curPop = curTower.getJSONArray("hourly_pop");
    //Update daily pop
    for (int j = 0; j < curPop.size(); j++) {
      JSONArray pop = curPop.getJSONArray(j);
      tower.frenchPops.add(pop.getInt(0));
      tower.spanishPops.add(pop.getInt(1));
      tower.otherPops.add(pop.getInt(2));
    }
  }
}

public void createTowerGraph(){
  for (Tower t : towers) {
    t.connectedTowers.clear();
    int degree = int(random(0,towers.size()));
    for(int i=0;i<=degree;i++){
      towers.get(int(random(0,towers.size()-1)));
      t.connectedTowers.add(towers.get(int(random(0,towers.size()-1))).screenLoc); 
    }
  }
}


//FIXME: Need to factorize with updateExternalCity
public void updateTowerPop() {
  //UPDATE City POP every hour (2500ms)
  float numberOFClick= 100;
  float curAngle;
  float curRadius;

  if (millis() - towerTimerStep >= slideHandler.curHourDuration/numberOFClick) {
    towerTimerStep = millis();
    //Create people in the city 
    for (Tower t : towers) {
      //Draw a proportion of the actual population
      t.popSize = t.frenchPops.get(slideHandler.curHour-1)+ t.spanishPops.get(slideHandler.curHour-1)+ t.otherPops.get(slideHandler.curHour-1);
      t.fRatio = t.frenchPops.get(slideHandler.curHour-1)/t.popSize*2*PI;
      t.sRatio = t.spanishPops.get(slideHandler.curHour-1)/t.popSize*2*PI;
      t.oRatio = t.otherPops.get(slideHandler.curHour-1)/t.popSize*2*PI;
      for (int i=0; i<t.frenchPops.get(slideHandler.curHour-1)/numberOFClick*0.01; i++) {
        curAngle= random(0, t.fRatio);
        curRadius = random(0, t.size/2);
        t.pop.add(new ExternalAgent(new PVector(t.screenLoc.x + curRadius * cos(curAngle), t.screenLoc.y + curRadius * sin(curAngle)), #2D34EA, "PERSON", new PVector(0, 0)));
      } 
      for (int i=0; i<t.spanishPops.get(slideHandler.curHour-1)/numberOFClick*0.01; i++) {
        curAngle= random(t.fRatio, t.fRatio+t.sRatio);
        curRadius = random(0, t.size/2);
        t.pop.add(new ExternalAgent(new PVector(t.screenLoc.x + curRadius * cos(curAngle), t.screenLoc.y + curRadius * sin(curAngle)), #e67e22, "PERSON", new PVector(0, 0)));
      } 
      for (int i=0; i<t.otherPops.get(slideHandler.curHour-1)/numberOFClick*0.01; i++) {
        curAngle= random(t.fRatio+t.sRatio, t.fRatio+t.sRatio+t.oRatio);
        curRadius = random(0, t.size/2);
        t.pop.add(new ExternalAgent(new PVector(t.screenLoc.x + curRadius * cos(curAngle), t.screenLoc.y + curRadius * sin(curAngle)), #AAAAAA, "PERSON", new PVector(0, 0)));
      }
      t.size = t.pop.size()/10;
      for (int i = t.pop.size() - 1; i >= 0; i--) {
        if (t.pop.get(i).lifespan <=0) {
          t.pop.remove(i);
        }
      }
    }
  }
}

public void AssignPOIToTower() {
  Table CDRAmens = loadTable("data/GIS/POI/tower_as_poi.tsv", "header");
  for (int i = 0; i<towers.size(); i++) {     
    for (int j = 0; j<CDRAmens.getRowCount(); j++) {
      if (i == CDRAmens.getInt(j, "TOWER") ) {
        towers.get(i).amenities = getPOIFromTowerID(i);
      }
    }
  }
}

public ArrayList<POI> getPOIFromTowerID(int id) {
  ArrayList<POI> tempPois = new ArrayList<POI>();
  for (POI p : streetsAND.pois) {
    if (p.towerId == id) {
      tempPois.add(p);
    }
  }
  return tempPois;
}