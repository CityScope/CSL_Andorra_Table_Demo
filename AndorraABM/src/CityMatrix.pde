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

class MetaData {
  int dockID;
  float slider1;
  int toggle1;
}

class Grid {
  ArrayList<Block> blocks;
  PVector origin;
  int w;
  int h;
  int blockSize;
  MetaData md;
  boolean isInit = false;

  Grid(PVector location, int _w, int _h, int _blockSize) {
    origin = location;
    w=_w;
    h=_h;
    blockSize=_blockSize;
    blocks = new ArrayList();
    md = new MetaData();
  }

  void display(PGraphics p) { 
      p.rectMode(CENTER);  
      p.fill(125); 
      p.pushMatrix();
      p.translate(origin.x - (blockSize*w)/2, origin.y - (blockSize*h)/2);   
      for (Block b : blocks) {
        p.translate(b.location.x*blockSize, b.location.y*blockSize); 
        b.display(p);
        p.translate(-b.location.x*blockSize, -b.location.y*blockSize);
      }
      p.popMatrix();
  }

  void addBlock(PVector _location, int _blockSize, int _id, float _data) { 
    blocks.add(new Block(_location, _blockSize, _id, _data));
  }

  void drawGrid(PGraphics p) {
    if (isGridHasChanged) {
      updateGridJSON();
      isGridHasChanged = false;
    }
    p.fill(255);  
    p.textSize(10);
    cityMatrix.display(p);
  }   
  PVector getGridSize() {
    return new PVector(16, 16);
  }
  void updateGridJSON() {
    JSONArray gridsA = jsonCityIO.getJSONArray("grid");
    JSONObject obj = jsonCityIO.getJSONObject("objects");
    md.dockID = obj.getInt("dockID");
    md.slider1 = obj.getFloat("slider1");
    md.toggle1 = int(obj.getFloat("toggle1"));
    if (isInit == false) {
      for (int i=0; i < gridsA.size(); i++) {
        JSONObject grid =  gridsA.getJSONObject(i);
        int type = grid.getInt("type");
        int x = grid.getInt("x");
        int y = grid.getInt("y");
        cityMatrix.addBlock(new PVector(15-x, y), blockSize, type, 255); 
      }
      isInit = true;
    }else{
      for (int i=0; i < gridsA.size(); i++) {
        JSONObject grid =  gridsA.getJSONObject(i);
        int type = grid.getInt("type");
        int x = grid.getInt("x");
        int y = grid.getInt("y");
        cityMatrix.blocks.get(i).Init(new PVector(15-x, y), blockSize, type, 255);
      }
    }
  }
}

class Block {
  PVector location;
  int size;
  int type;
  float data;
  String id;


  Block(PVector l, int _size, int _type, float _data) {
    location = l;//.copy();
    size = _size;
    type= _type;
    data= _data;
    id = str(int(l.x)) +str(int(l.y));
  }

  void Init(PVector l, int _size, int _type, float _data) {
    location = l;//.copy();
    size = _size;
    type= _type;
    data= _data;
    id = str(int(l.x)) +str((int)l.y);
  }

  void run() {
  }

  // Method to display
  void display(PGraphics p) {
    p.rectMode(CENTER);
    p.fill(255, data);
    if (type==6) {
      p.fill(25, data);
      p.rect(location.x, location.y, size, size);
    }
    if (type==-1) {
      p.fill(145,179,50, data);
      p.rect(location.x, location.y, size, size);
    }
    if (type==0 || type==1 || type ==2) {
      p.fill(255, 251, 230, data);
      p.rect(location.x, location.y, size, size);
      if (type==0) {
        p.fill(0, 164, 255, data);
        p.rect(location.x, location.y, size/4, size/4);
      }
      if (type==1) {
        p.fill(255, 212, 0, data);
        p.rect(location.x, location.y, size/4, size/4);
      }
      if (type==2) {
        p.fill(255, 0, 0, data);
        p.rect(location.x, location.y, size/4, size/4);
      }
    }
    if (type==3 || type==4 || type ==5) {
      p.fill(230, 242, 255, data);
      p.rect(location.x, location.y, size, size);
      if (type==3) {
        p.fill(0, 164, 255, data);
        p.rect(location.x, location.y, size/4, size/4);
      }
      if (type==4) {
        p.fill(255, 212, 0, data);
        p.rect(location.x, location.y, size/4, size/4);
      }
      if (type==5) {
        p.fill(255, 0, 0, data);
        p.rect(location.x, location.y, size/4, size/4);
      }
    }
  }
}