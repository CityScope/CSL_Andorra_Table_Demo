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

///////////////////////// EXTERNAL CITY MODEL ///////////////


City initExternalCity(String name, PVector loc, color c, boolean visible) {
  City city = new City(name, loc, c, 100, visible);
  JSONObject curCity = jsonExternalCity.getJSONObject(name);
  JSONArray curPop = curCity.getJSONArray("hourly_pop");
  //Update daily pop
  for (int i = 0; i < curPop.size(); i++) {
    JSONArray pop = curPop.getJSONArray(i);
    city.frenchPops.add(pop.getInt(0));
    city.spanishPops.add(pop.getInt(1));
    city.otherPops.add(pop.getInt(2));
  }
  externalCities.add(city);
  return city;
}


void initExternalCities() {
  externalCities = new ArrayList();
  highways = new ArrayList(); 
  //FIXME: co should be initialized with Andorra La vella value but we don't have yet this data...
  City c0 = initExternalCity("Encamp", new PVector(300, 450), #34495e, false);
  City c1 = initExternalCity("Encamp", new PVector(55, 450), #34495e, true);
  City c2 = initExternalCity("Canillo", new PVector(55, 650), #34495e, true);
  City c3 = initExternalCity("PasDeLaCasa", new PVector(55, 850), #34495e, true);

  Highway h01 = new Highway(c0, c1);
  Highway h12 = new Highway(c1, c2);
  Highway h23 = new Highway(c2, c3);
  highways.add(h01);
  highways.add(h12);
  highways.add(h23);

  City c4 = initExternalCity("StJulia", new PVector(1800, 500), #FFFF00, true);
  //FIXME: c4_bis should be initialized with Andorra La vella value but we don't have yet this data...
  City c4_bis = initExternalCity("StJulia", new PVector(1700, 600), #FFFF00, false);
  City c4_ter = initExternalCity("StJulia", new PVector(1700, 550), #FFFF00, false);
  Highway h44b = new Highway(c4, c4_bis);
  Highway h44t = new Highway(c4, c4_ter);
  highways.add(h44b);
  highways.add(h44t);


  City c5 = initExternalCity("Massana", new PVector(800, 925), #87322C, true);
  City c6 = initExternalCity("Ordino", new PVector(400, 925), #87322C, true);

  //FIXME: c5_bis and c5_ter should be initialized with Andorra La vella value but we don't have yet this data...
  City c5_bis = initExternalCity("Massana", new PVector(650, 700), #87322C, false);
  City c5_ter = initExternalCity("Massana", new PVector(800, 600), #87322C, false);

  Highway h55bis = new Highway(c5, c5_bis);
  Highway h55ter = new Highway(c5, c5_ter);
  Highway h56 = new Highway(c5, c6);
  highways.add(h55bis);
  highways.add(h55ter);
  highways.add(h56);
}
//FIXME: Need to factorize with updateTower
void updateExternalCity(PGraphics p) {
  for (City c : externalCities) {
    c.draw(p);
  }
  if (!streetsAND.showTower) {
    for (Highway h : highways) {
      h.draw(p);
    }
  }  
  updatePopList();
  CancerCellDrawing();
}
public void updatePopList() {
  for (City c : externalCities) {
    //Draw a proportion of the actual population in a PIE CHART
    c.popSize = c.frenchPops.get(slideHandler.curHour-1)+ c.spanishPops.get(slideHandler.curHour-1)+ c.otherPops.get(slideHandler.curHour-1);
    c.fRatio = c.frenchPops.get(slideHandler.curHour-1)/c.popSize*2*PI;
    c.sRatio = c.spanishPops.get(slideHandler.curHour-1)/c.popSize*2*PI;
    c.oRatio = c.otherPops.get(slideHandler.curHour-1)/c.popSize*2*PI;
  }
}

public void CancerCellDrawing() {
  //UPDATE City POP every hour (2500ms)
  float numberOFClick= 30;
  float curAngle;
  float curRadius;
  float maxRadius;
  if (millis() - externalCityTimerStep >= slideHandler.curHourDuration/numberOFClick) {
    externalCityTimerStep = millis();
    //Create people in the city 
    for (City c : externalCities) {
      //Draw a proportion of the actual population in a PIE CHART
      maxRadius = c.size*0.1+c.popSize/100;
      if (maxRadius > c.size/2) {
        maxRadius = c.size*0.4;
      }
      curAngle= random(0, c.fRatio);
      curRadius = random(0, maxRadius);
      c.pop.add(new ExternalAgent(new PVector(c.loc.x + curRadius * cos(curAngle), c.loc.y + curRadius * sin(curAngle)), #2D34EA, "PERSON", new PVector(0, 0)));

      curAngle= random(c.fRatio, c.fRatio+c.sRatio);
      curRadius = random(0, maxRadius);
      c.pop.add(new ExternalAgent(new PVector(c.loc.x + curRadius * cos(curAngle), c.loc.y + curRadius * sin(curAngle)), #e67e22, "PERSON", new PVector(0, 0)));

      curAngle= random(c.fRatio+c.sRatio, c.fRatio+c.sRatio+c.oRatio);
      curRadius = random(0, maxRadius);
      c.pop.add(new ExternalAgent(new PVector(c.loc.x + curRadius * cos(curAngle), c.loc.y + curRadius * sin(curAngle)), #AAAAAA, "PERSON", new PVector(0, 0)));


      for (int i = c.pop.size() - 1; i >= 0; i--) {
        if (c.pop.get(i).lifespan <=0) {
          c.pop.remove(i);
        }
      }
    }
    if (!streetsAND.showTower) {
      //Create people on the highway
      for (Highway h : highways) {
        float a = random(0, 500);
        if (a<10) {      
          addMovingAgentBetwenn2Cities(h.c1, h.c2, "MOVING", #2D34EA);
        }
        if (a>10 && a<20) {
          addMovingAgentBetwenn2Cities(h.c2, h.c1, "MOVING", #2D34EA);
        }
        if (a>20 && a<30) {
          addMovingAgentBetwenn2Cities(h.c1, h.c2, "MOVING", #e67e22);
        }
        if (a>30 && a<40) {
          addMovingAgentBetwenn2Cities(h.c2, h.c1, "MOVING", #e67e22);
        }
        if (a>40 && a<50) {
          addMovingAgentBetwenn2Cities(h.c1, h.c2, "MOVING", #AAAAAA);
        }
        if (a>50 && a<60) {
          addMovingAgentBetwenn2Cities(h.c2, h.c1, "MOVING", #AAAAAA);
        }
      }
    }
  }
}
public void addMovingAgentBetwenn2Cities(City c1, City c2, String type, color c) {
  c1.pop.add(new ExternalAgent(new PVector(c1.loc.x + random(-c1.size/8, c1.size/8), c1.loc.y + random(-c1.size/8, c1.size/8)), c, type, 
    new PVector(c2.loc.x + random(-c2.size/8, c2.size/8), c2.loc.y + random(-c2.size/8, c2.size/8))));
}
///// City Class //////////
public class City {

  String name;
  PVector loc;
  color c;
  int size;
  boolean visible;
  ArrayList<ExternalAgent> pop;
  ArrayList<Integer> frenchPops;
  ArrayList<Integer> spanishPops;
  ArrayList<Integer> otherPops;
  float fRatio;
  float sRatio;
  float oRatio;
  float popSize;
  int barSize=10;
  int barHeight= 5;


  City(String _name, PVector _loc, color _c, int _size, boolean _visible) {
    name  = _name;
    loc = _loc;
    c= _c;
    size = _size;
    visible=_visible;
    pop = new ArrayList<ExternalAgent>(); 
    frenchPops = new ArrayList<Integer>();
    spanishPops = new ArrayList<Integer>();
    otherPops = new ArrayList<Integer>();
  }

  public void update() {//Update my current population
    //Refresh my popluation every seconds
  }

  public float getPopSize() {
    return popSize;
  }

  public void draw(PGraphics p) {
    if (visible) {
      p.noFill();
      p.stroke(#CCCCCC, 125);
      p.strokeWeight(2);
      p.ellipse(loc.x, loc.y, size*0.8, size*0.8);
      p.fill(#CCCCCC);
      p.textFont(font18);
      if (name.equals("PasDeLaCasa")) {
        p.text("PasDeCasa", loc.x+size*0.8, loc.y+size*0.4);
      } else {
        p.text(name, loc.x+size*0.7, loc.y+size*0.4);
      }
      drawCurrentStackedBAr(p, loc.x+size*0.4, loc.y+size*0.6);
      drawExternalPopHistogram(p, loc.x+size*1.2, loc.y+size*0.6, 3);

      p.strokeWeight(1); 
      for (int i = pop.size()-1; i >= 0; i--) {
        pop.get(i).draw(p, visible);
      }
    } else {
      for (int i = pop.size()-1; i >= 0; i--) {
        pop.get(i).draw(p, visible);
      }
    }
  }

  public void drawCurrentStackedBAr(PGraphics p, float x, float y ) {
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

  public void drawExternalPopHistogram(PGraphics p, float x, float y, int step) {
    p.fill(#FFFFFF);
    p.noStroke();
    for (int i= 0; i<24; i++) {
      p.rect(x+i*step, y, step, -(frenchPops.get(i)+ spanishPops.get(i)+ otherPops.get(i))/200);
    }
    p.fill(#000000);
    p.rect(x+slideHandler.curHour*step, y, step, -(frenchPops.get(slideHandler.curHour)+ spanishPops.get(slideHandler.curHour)+ otherPops.get(slideHandler.curHour))/200);
  }

  public void drawExternalPopHistogramPyPop(PGraphics p, float x, float y, int step) {
    p.fill(255);
    p.noStroke();
    for (int i= 0; i<24; i++) {      
      p.stroke(#2D34EA);
      p.fill(#2D34EA);
      p.rect(x+i*step, y, step, -(frenchPops.get(i))/200);
      p.stroke(#e67e22);
      p.fill(#e67e22);
      p.rect(x+i*step, y-(frenchPops.get(i)/200), step, -(spanishPops.get(i))/200);
      p.stroke(#AAAAAA);
      p.fill(#AAAAAA);
      p.rect(x+i*step, y - (frenchPops.get(i)+ spanishPops.get(i))/200, step, -(otherPops.get(i))/200);
    }
    p.fill(#FF0000);
    p.rect(x+slideHandler.curHour*step, y, 1, -25);
  }
}

public class Highway {

  City c1;
  City c2;
  color c;
  int size;

  Highway(City _c1, City _c2) {
    c1  = _c1;
    c2 = _c2;
  }

  public void update() {
  }

  public void draw(PGraphics p) {

    p.stroke(#CCCCCC, 125);
    p.strokeWeight(3);
    float a= atan((c2.loc.y-c1.loc.y)/(c2.loc.x-c1.loc.x));
    float c = 60;
    if (c2.loc.x == c1.loc.x) {
      if (c2.loc.y > c1.loc.y) {
        a = PI/2;
      } else {
        a=-PI/2;
      }
    }  
    if (c2.loc.x < c1.loc.x) {
      a = a + PI;
    }
    p.line(c1.loc.x + c*cos(a), c1.loc.y +  c * sin(a), c2.loc.x - c * cos(a), c2.loc.y - c * sin(a));
    p.noStroke();
  }
}

public class ExternalAgent {
  PVector location;
  color c;
  float lifespan;
  String type;
  PVector dest;


  ExternalAgent(PVector l, color _c, String _t, PVector _d) {
    location = l;
    c=_c;
    lifespan = 255.0;
    type = _t;
    dest=_d;
  }

  public void draw(PGraphics p, boolean visible) {
    if (visible) {
      if (type.equals("PERSON") == true) {
        p.fill(c, lifespan);
        p.noStroke();
        location.x = location.x + random(-0.25, 0.25);
        location.y = location.y + random(-0.25, 0.25);
        p.ellipse(location.x, location.y, 6, 6); 
        lifespan -= 2.0;
      }

      if (type.equals("CAR") == true) {
        p.stroke(c);
        p.noFill();
        p.ellipse(location.x+ (dest.x-location.x)*lifespan/255, location.y+ (dest.y-location.y)*lifespan/255, 10, 10);
        lifespan -= 2.0;
      }

      if (type.equals("MOVING") == true) {
        p.fill(c);
        p.noStroke();
        p.ellipse(location.x+ (dest.x-location.x)*lifespan/255, location.y+ (dest.y-location.y)*lifespan/255, 6, 6);
        lifespan -= 0.5;
      }
    }
    else{
      if (type.equals("MOVING") == true) {
        p.fill(c);
        p.noStroke();
        p.ellipse(location.x+ (dest.x-location.x)*lifespan/255, location.y+ (dest.y-location.y)*lifespan/255, 6, 6);
        lifespan -= 0.5;
      }
    }
  }
}