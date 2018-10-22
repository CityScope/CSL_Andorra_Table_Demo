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
import processing.serial.*;

class PhysicalInterface{
  Serial myPort;
  int val;
  ArrayList<Integer> button;
  
  PhysicalInterface(PApplet parent){
    button = new ArrayList();
    button.add(0);
    button.add(0);
    button.add(0);
    button.add(0);
    button.add(0);
    button.add(0);
    button.add(0);
    if(btController){
     printArray(Serial.list());
     if (Serial.list().length > 0 && Serial.list()[1].equals("COM4")){
       myPort = new Serial(parent, Serial.list()[1],9600);
     }else{
       btController= false;
       println("Physical interface not working - Check your bluetooth settings");
     }   
    }
  }
  
  void update(){
     if(btController){
       if(buttons.myPort.available()>0)
        {
        buttons.val=myPort.read();
        updateInterface(buttons.val);
        }
     }
  }
  
  void updateInterface(int button){
    //Agent
    if(button == 0) {
      if(trafficEquilibrium == true) trafficEquilibrium = false;
      if(streetsAND.showRNC == true) streetsAND.showRNC = false;
      model.toggle();
    }
    //Road
    if(button == 1) trafficEquilibrium=!trafficEquilibrium;//streetsAND.toggleStreetRendering();
     //POI
    if(button == 2){
      if(trafficEquilibrium == true) trafficEquilibrium = false;
      streetsAND.toggleRNC();
    }
    //tower
    if(button == 3)  {
      if(trafficEquilibrium == true) trafficEquilibrium = false;
      streetsAND.toggleTower();
      model.toggleShowAgent();
    }
    //Congestion
    if(button == 4) {   
      if(trafficEquilibrium == true) trafficEquilibrium = false;  
      aggregatedHeatmap.visible(Visibility.TOGGLE);
    }
    //CityMatrix
    if(button == 5) showCityMatrix =!showCityMatrix;
    //next
    if(button == 6) slideHandler.NextSlide();
    //if(button == 7) model.speed(0.3);
    //if(button == 8) model.speed(-0.3);
    if(button == 9) model.playStop();
  }
  
  void drawInterface(PGraphics p, PVector pos, ArrayList button){
    p.clear();
    p.background(0);
    for(int i=0;i<button.size();i++){
      if((int)button.get(i) == 0 ){
         p.fill(255, 0, 0);
      }
      else{
        p.fill(0, 255, 0);
      }
       p.rect(pos.x, pos.y+63*i, 42, 42);
    }
  }
}