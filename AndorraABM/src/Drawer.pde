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
import deadpixel.keystone.*;

public class Drawer{

  Keystone ks;  
      
  CornerPinSurface surfacePin3DTable;
  CornerPinSurface surfacePinFlatTable;
  CornerPinSurface[] surface = new CornerPinSurface[2];
  CornerPinSurface[] surface3D = new CornerPinSurface[2];

  PGraphics offscreen3DTable;
  PGraphics offscreenFlatTable;
  PGraphics miniFlat;
  PGraphics miniTable;

  
  Drawer(PApplet parent){
    ks = new Keystone(parent); //<>// //<>// //<>// //<>//
    offscreen3DTable = createGraphics((int)getROIDimension().x, (int)getROIDimension().y, P2D);   //<>//
    offscreenFlatTable = createGraphics(playGroundWidth, playGroundHeight, P2D);

  }
  
  void initTableView(){
    if(multiProj){
      surface3D[0] = ks.createCornerPinSurface((int)getROIDimension().x/2, (int)getROIDimension().y, 50);
      surface3D[1] = ks.createCornerPinSurface((int)getROIDimension().x/2, (int)getROIDimension().y, 50);
      
      surface[0] = ks.createCornerPinSurface((int)playGroundWidth/2, (int)playGroundHeight, 50);
      surface[1] = ks.createCornerPinSurface((int)playGroundWidth/2, (int)playGroundHeight, 50);
      //FIXME: Thos load can only be done if the keystoen was made with the right number of projectors
      //ks.load();
    }else{
      surfacePin3DTable = ks.createCornerPinSurface((int)getROIDimension().x, (int)getROIDimension().y, 50);    
      surfacePinFlatTable = ks.createCornerPinSurface((int)playGroundWidth, (int)playGroundHeight, 50);
      println("UpperLeft" + UpperLeft + "UpperRight" + UpperRight + "LowerLeft" + LowerLeft + "LowerRight" + LowerRight);
      println("getROICenter()" + getROICenter());
      println("getROIDimension()" + getROIDimension());
      //FIXME: Thos load can only be done if the keystoen was made with the right number of projectors
      //ks.load();
    }
    miniFlat = createGraphics(playGroundWidth/2, playGroundHeight, P2D);
    miniTable = createGraphics((int)getROIDimension().x/2, (int)getROIDimension().y, P2D);

  }
  
  void initScreenView(){
    surfacePin3DTable = ks.createCornerPinSurface(playGroundWidth, playGroundHeight, 50);
    surfacePinFlatTable = ks.createCornerPinSurface((int)playGroundWidth, (int)playGroundHeight, 50);
  }
  
  void drawFaltTableView(){
    if (tableView) {
      offscreenFlatTable.beginDraw();
      offscreenFlatTable.clear();
      updateExternalCity(offscreenFlatTable);
      drawTemporalLegend(offscreenFlatTable, new PVector(1700, 850), 240.0, (5000/slideHandler.curHourDuration)*(millis() - slideHandler.lastTime));
      drawAgentLegend(offscreenFlatTable, new PVector(1250, 860), 450);
      offscreenFlatTable.endDraw();
      if(multiProj){
        miniFlat.beginDraw();
        miniFlat.clear();
        miniFlat.image(offscreenFlatTable, 0, 0);
        miniFlat.endDraw();
        surface[0].render(miniFlat);
        miniFlat.beginDraw();
        miniFlat.clear();
        miniFlat.image(offscreenFlatTable, -playGroundWidth/2, 0);
        miniFlat.endDraw();
        surface[1].render(miniFlat);
      }else{
        surfacePinFlatTable.render(offscreenFlatTable);
      }
      
    }
  }
  
  
  void draw3DTableView(){
  offscreen3DTable.beginDraw();
  offscreen3DTable.clear();
  offscreen3DTable.background(0);

    if (tableView) {
      //FIXME: A.G What is this ugly constant!!!! It should come from somewhere
     // offscreen3DTable.translate(-132*width/2000, -535*height/1000); 
      offscreen3DTable.translate(-getROICenter().x*0.135, -getROICenter().y*0.6);
      offscreen3DTable.translate(getROICenter().x, getROICenter().y);
      offscreen3DTable.rotate(0.445 + 3.14);
      offscreen3DTable.translate(-getROICenter().x, -getROICenter().y);
      drawTableBackGround(offscreen3DTable);
    }
    
    if (showCityMatrix && cityIO) {
      if (frameCount % 60 == 0) {
          jsonCityIO = loadJSONObject(CityMatrixUrl);
        isGridHasChanged = true;
      } 
      cityMatrix.drawGrid(offscreen3DTable);
    }
  
    instantHeatmap.draw(offscreen3DTable);
    aggregatedHeatmap.draw(offscreen3DTable);
    rncHeatmap.draw(offscreen3DTable);
    streetsAND.draw(offscreen3DTable);
    model.run(offscreen3DTable);
    
    if (streetsAND.showTower) {
      updateTowerPop();
      for (Tower t : towers) {
        if (t.screenLoc.x > 0 && t.screenLoc.x < width && t.screenLoc.y > 0 && t.screenLoc.y < height) {
          t.draw(offscreen3DTable);
        }
      }
    }
    
    if (agentsSelected != null) {
      offscreen3DTable.textSize(9);
      for (int i=0; i<agentsSelected.size(); i++) {
        Agent agent = agentsSelected.get(i);
        String text = agent.getType() + " " + agent.getId() + ". Traveled " + round( agent.hasTraveled() * streetsAND.getScale() ) + "m" + "s:" + agent.inNode.pos + "d:" + agent.destNode.pos;
        if (agent.waiting) text += " [WAITING]";
        if (agent.arrived) text += " [ARRIVED]";
        int posY = 130 + 15*i;
        offscreen3DTable.textAlign(LEFT, CENTER); 
        offscreen3DTable.fill(#FFFFFF);
        offscreen3DTable.text(text, 40, posY);
        offscreen3DTable.fill(agent.myColor); 
        offscreen3DTable.noStroke();
        offscreen3DTable.ellipse( 30, posY + 2, 4, 4);
      }
    }
    
    if (frameCount % 30 == 0) {
      aggregatedHeatmap.update("Aggregated", model.getAgents(), "cold", false);
  
    }
    
    if (frameCount % 10 == 0) {
      rncHeatmap.updateRNC("RNC", rnc.positions, baseRnc.positions,"hot", "cold");
    }
    if(printLegend == true){
      drawLegend(offscreen3DTable);
      model.printLegend(offscreen3DTable, 40, 70);
    }
    
    
    if(streetsAND.showRNC||rncHeatmap.visible==true){
      rnc.update();
      baseRnc.update();
    }
    if(streetsAND.showRNC){
      rnc.draw(offscreen3DTable);
    }
    
     if(streetsAND.showRNCCluster){
       
       rncCluster.update();
      rncCluster.draw(offscreen3DTable);
    }
    
    // draw the links showing the equilbrium traffic conditions
    if (trafficEquilibrium==true) {
      equilibrium.draw(offscreen3DTable);
    }
   
  offscreen3DTable.endDraw();
  
   if(multiProj){
        miniTable.beginDraw();
        miniTable.clear();
        miniTable.image(offscreen3DTable, 0, 0);
        miniTable.endDraw();
        surface3D[0].render(miniTable);
        miniTable.beginDraw();
        miniTable.clear();
        miniTable.image(offscreen3DTable, -getROIDimension().x/2, 0);
        miniTable.endDraw();
        surface3D[1].render(miniTable);
      }else{
        surfacePin3DTable.render(offscreen3DTable);
      }
  
  
  
  }
  
  void drawLegend(PGraphics p) {
    p.fill(#FFFFFF);
    p.textAlign(RIGHT); 
    p.textSize(10);
    p.text("FRAMERATE: " + int(frameRate) + " fps", width-30, 30);
    String speedText = "SPEED: " + String.format("%.2f", model.speed);
    if (model.stop) speedText += " [PAUSED]";
    p.text(speedText, width-30, 45);
    p.text("AGENTS: " + model.numAgents(), width-30, 60);
    p.fill(#FFFFFF); 
    p.textAlign(LEFT, TOP); 
    p.textSize(14);
    p.text("[SPACE] Play/Stop simulation  [+][-] Simulation speed  [A] Agents toggle  [P] POIs toggle  [R] Road toogle [X] Road allowance  [T] Road types  [B] Background  [C]Congestion  [M] Grid", 30, 30);
      p.text("[D] Heatmap  [H] Aggregated Heatmap  [Q] RNC Heatmap ", 30, 50);
    
}
  void drawAgentLegend(PGraphics p, PVector pos, float size) {
    p.noFill();
    p.stroke(#CCCCCC,125);
    p.rect(pos.x-40,pos.y-25,size*0.75,size*0.3,5);
    
    int step=38;  
    p.textFont(font18);
    p.textSize(20);
    p.fill(250);
    p.noStroke();
  
    p.fill(#2D34EA);
    p.ellipse(pos.x, pos.y+3, 10, 10);
    p.text("French ", pos.x+42, pos.y+10);
  
    p.fill(#e67e22);
    p.ellipse(pos.x+100, pos.y+3, 10, 10);
    p.text("Spanish ", pos.x+147, pos.y+10);
  
    p.fill(125);
    p.ellipse(pos.x+200, pos.y+3, 10, 10);
    p.text("Other", pos.x+235, pos.y+10);
  
    p.ellipse(pos.x, pos.y+step+5, 6, 6);
    p.text("People", pos.x+40, pos.y+step+10);
  
    p.noFill();
    p.stroke(125);
    p.strokeWeight(2);
    p.ellipse(pos.x+100, pos.y+step+5, 6*1.5, 6*1.5);
    p.text("Car", pos.x+130, pos.y+step+10);
    
    p.ellipseMode(CENTER);
    p.fill(255, 130); p.stroke(#FFFFFF);
    p.ellipse(pos.x, pos.y+2*step+5, 10, 10);
    p.fill(255);
    p.text("Amenities", pos.x+53, pos.y+2*step+10);
  
    p.rectMode(CENTER);
    p.fill(255, 130); p.stroke(#FFFFFF);
    p.rect(pos.x+130, pos.y+2*step+5, 10, 10);
    p.fill(255);
    p.text("Parking", pos.x+173, pos.y+2*step+10);
    p.rectMode(CORNER);
    
  }
  
  void drawDemoLegend(PGraphics p) {
    p.fill(#FFFFFF);
    p.textAlign(CENTER); 
    p.textSize(30);
    p.text(slideHandler.display.getString("legend"), displayWidth/8, displayHeight/8);
    int i = 0;
    for (Profile pr : Profile.values()) {
      int pY = displayHeight/8 + 15 * i;
      p.fill(pr.getColor()); 
      p.noStroke();
      p.ellipse(displayWidth/8, pY, 7, 7);
      p.fill(#FFFFFF); 
      p.textSize(12); 
      p.textAlign(LEFT, CENTER);
      p.text(""+pr, displayWidth/8+10, pY);
      i++;
    }
  }
  
  void drawTableBackGround(PGraphics p) {
    
    p.beginShape();
    p.texture(backgroundImage);
    p.vertex(UpperLeft.x, UpperLeft.y, 0, 0);
    p.vertex(UpperRight.x, UpperRight.y, 2000, 0);
    p.vertex(LowerRight.x, LowerRight.y, 2000, 711);
    p.vertex(LowerLeft.x, LowerLeft.y, 0, 711);
    p.endShape(); 
    p.ellipse(UpperLeft.x,UpperLeft.y,20,20);
    p.ellipse(UpperRight.x,UpperRight.y,20,20);
    p.ellipse(LowerLeft.x,LowerLeft.y,20,20);
    p.ellipse(LowerRight.x,LowerRight.y,20,20);
    //p.rect(UpperLeft.x,UpperLeft.y,UpperRight.x-UpperLeft.x,711);
    if (streetsAND.hideBackground) {
      p.fill(0, 200);
    } else {
      p.fill(0, 125);
    }
    p.rect(0, 0, 10000, 7110);
    
  }

  void drawTemporalLegend(PGraphics p, PVector pos, float size, float simulationTime) {
    
    aggregatedData.drawTotalPopHistogramByPop(p,pos.x,pos.y,10,1000);
    p.fill(#AAAAAA);
    p.rect(pos.x, pos.y, size, size*0.03, size*0.03, size*0.03, size*0.03, size*0.03);
    p.fill(#444444);
    p.rect(pos.x, pos.y, simulationTime/slideHandler.interval*size, size*0.03, size*0.01, size*0.01, size*0.01, size*0.01);  
    p.fill(#222222);
    p.ellipse(pos.x+simulationTime/slideHandler.interval*size, pos.y+size*0.02, size*0.1, size*0.1);
    p.fill(#444444);
    p.ellipse(pos.x+simulationTime/slideHandler.interval*size, pos.y+size*0.02, size*0.05, size*0.05);
    p.fill(#FFFFFF);
    p.textAlign(CENTER); 
    
    simulationTime = 2*simulationTime*3600/10;
    //int seconds = (int) (simulationTime / 1000) % 60 ;
    minutes = (int) ((simulationTime / (1000*60)) % 60);
    hours   = (int) ((simulationTime / (1000*60*60)) % 24);
    String min= str(minutes);
    if (minutes<10) {
      min = "0"+min;
    }
    p.textFont(font18);
    //textSize();
    p.textAlign(LEFT); 
    p.text(slideHandler.display.getString("date"), pos.x, pos.y+32);
    p.textAlign(RIGHT); 
    p.text(hours + ":" + min ,pos.x + size, pos.y+32);
    p.textAlign(LEFT); 
    p.textSize(32);
    p.text(slideHandler.display.getString("legend"), pos.x , pos.y+70);
   // p.textAlign(RIGHT); 
    //p.text(int(frameRate), pos.x +size, pos.y+52);
    //drawCenterlegend(p,new PVector(pos.x+size,pos.y-80));
    p.textAlign(CENTER); 
    p.textSize(32);
    p.fill(#2D34EA);
    p.text("France", 75 , 975);
    p.fill(#e67e22);
    p.text("Spain", 1950 , 425);
    
    p.stroke(#CCCCCC,125);
    p.line(1900 , 420, 1845, 465); // Line from Spain to St Julia
    p.line(55 , 945, 55, 905);
    
    
  }
  
  void drawCenterlegend(PGraphics p, PVector pos){
    p.noFill();
    p.stroke(#CCCCCC,125);
    p.rect(pos.x-5,pos.y+10,160,-150,5);
    aggregatedData.drawExternalPopHistogram(p, pos.x, pos.y, 3);
    aggregatedData.drawCurrentStackedBAr(p, pos.x + 80, pos.y);
    p.textAlign(LEFT); 
    p.text("Center", pos.x + 80 , pos.y-32);
  }
  
  void drawKeyBoardLegend(PGraphics p, PVector pos){
    p.noFill();
    p.stroke(#CCCCCC,125);
    p.rect(pos.x-10,pos.y-20,250,50,10);
    p.fill(#FFFFFF);
    p.textFont(font12);
    p.textAlign(LEFT); 
    p.text("[t] Tower [a] Agents [p] Ameneties [w] Road ", pos.x, pos.y);
    p.text("[c]Congestion  [d] Density [h] Density", pos.x, pos.y+24);
  
  }
  
  void drawROI(PGraphics p) {
    p.stroke(255, 0, 0);
    p.strokeWeight(1);
    p.line(UpperLeft.x, UpperLeft.y, UpperRight.x, UpperRight.y);
    p.line(UpperRight.x, UpperRight.y, LowerRight.x, LowerRight.y);
    p.line(LowerRight.x, LowerRight.y, LowerLeft.x, LowerLeft.y);
    p.line(LowerLeft.x, LowerLeft.y, UpperLeft.x, UpperLeft.y);
    p.rectMode(CENTER);
    p.rect(getROICenter().x, getROICenter().y, 8, 8);
  }
  
  PVector getROIDimension() {
    return new PVector(dist(UpperLeft.x, UpperLeft.y, UpperRight.x, UpperRight.y), dist(UpperLeft.x, UpperLeft.y, LowerLeft.x, LowerLeft.y));
  }

  PVector getROICenter() {
    return new PVector((UpperLeft.x +LowerRight.x)/2, (UpperLeft.y +LowerRight.y)/2);
  }
}

//////////////////////////////// fonts

PFont font12, font18, font24, font48;

void loadFonts() {
  font12 = loadFont("ressources/Font/Helvetica-12.vlw");
  font18 = loadFont("ressources/Font/Helvetica-18.vlw");
  font24 = loadFont("ressources/Font/Helvetica-24.vlw");
  font48 = loadFont("ressources/Font/Helvetica-48.vlw");
}