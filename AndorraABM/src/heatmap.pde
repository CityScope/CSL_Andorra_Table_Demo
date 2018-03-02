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

// ----------------------------------------------------------------------------------------------------------
// Heatmap method by Philipp Seifried 2011 http://philippseifried.com/blog/2011/09/30/generating-heatmaps-from-code/
// Imported to a class and modified by Marc Vilella to adapt the Andorra ABM - June 2016
//
// Generation of heatmap from a set of given points
// ----------------------------------------------------------------------------------------------------------

public enum Visibility { HIDE, SHOW, TOGGLE; }

/* HEATMAP CLASS --------------------------------------------------------------------------------------- */
public class Heatmap {

    private String title = "TITLE";
    private PVector position;
    private int width,
                height;
    private PImage heatmap,
                   gradientMap,
                   heatmapBrush;
    private HashMap<String, PImage> gradients = new HashMap<String, PImage>();
    
    private float maxValue = 0, maxDelta=36000, minDelta=-10000;
    private boolean visible = false;

    /* <--- CONSTRUCTOR ---> */
    Heatmap(int x, int y, int width, int height) {
        this.position = new PVector(x, y);
        this.width = width;
        this.height = height;
        
        // Default B/W gradient
        PImage defaultGrad = createImage(255, 1, RGB);
        defaultGrad.loadPixels();
        for(int i = 0; i < defaultGrad.pixels.length; i++) defaultGrad.pixels[i] = color(i, i, i); 
        defaultGrad.updatePixels();
        gradients.put("default", defaultGrad);
        
        clear();
    }


    public void setBrush(String brush, int brushSize) {
        heatmapBrush = loadImage(brush);
        heatmapBrush.resize(brushSize, brushSize);
    }
    
    
    public void addGradient(String name, String path) {
        File file = new File(dataPath(path));
        if( file.exists() ) gradients.put(name, loadImage(path));
    }


    public void visible(Visibility v) {
        switch(v) {
            case HIDE:
                visible = false;
                break;
            case SHOW:
                visible = true;
                break;
            case TOGGLE:
                visible = !visible;
                break;
        }
    }

    
    public boolean isVisible() {
        return visible;
    }

  
    public void clear() {
        heatmap = createImage(width, height, ARGB);
        gradientMap = createImage(width, height, ARGB);
        maxValue = 0;
        
    }
    
    
    public void update(String title, ArrayList objects) {
        update(title, objects, "default", false);
    }
    
    public void update(String title, ArrayList objects, String gradient, boolean persistance) {
        this.title = title;
        if(visible) {
            gradientMap.loadPixels();
            for(int i = 0; i < objects.size(); i++) {
                Placeable obj = (Placeable) objects.get(i);
                PVector position = obj.getPosition();
                gradientMap = addGradientPoint(gradientMap, position.x, position.y);
            }
            gradientMap.updatePixels();
            PImage gradientColors = gradients.containsKey(gradient) ? gradients.get(gradient) : gradients.get("default");
            if(persistance) heatmap.blend(colorize(gradientMap, gradientColors, gradientColors), 0, 0, width, height, 0, 0, width, height, MULTIPLY);
            else heatmap = colorize(gradientMap, gradientColors, gradientColors);
        }
    }
    
    public void updateRNC(String title, ArrayList<PVector> positionsNow, ArrayList<PVector> positionsBase, String hotGradient, String coldGradient) {
        this.title = title;
        if(visible) {
            PImage gradientMapNow = createImage(width, height, ARGB);
            PImage gradientMapBase = createImage(width, height, ARGB);
            gradientMapNow.loadPixels();
            gradientMapBase.loadPixels();
            for(int i = 0; i < positionsNow.size(); i++) {
                gradientMapNow = addGradientPoint(gradientMapNow, positionsNow.get(i).x, positionsNow.get(i).y);
            }
            for(int i = 0; i < positionsBase.size(); i++) {
                gradientMapBase = addGradientPoint(gradientMapBase, positionsBase.get(i).x, positionsBase.get(i).y);
            }
            gradientMapNow.updatePixels();
            gradientMapBase.updatePixels();
            PImage hotGradientColors = gradients.containsKey(hotGradient) ? gradients.get(hotGradient) : gradients.get("default");
            PImage coldGradientColors = gradients.containsKey(coldGradient) ? gradients.get(coldGradient) : gradients.get("default");
            for(int i=0; i< gradientMapNow.pixels.length; i++) {
              gradientMapNow.pixels[i]-=gradientMapBase.pixels[i];
              if (gradientMapNow.pixels[i]>maxDelta) maxDelta=gradientMapNow.pixels[i];
              if (gradientMapNow.pixels[i]<minDelta) minDelta=gradientMapNow.pixels[i];
            }
            heatmap = colorize(gradientMapNow,hotGradientColors, coldGradientColors);
            //heatmap = colorize(gradientMapBase, gradientColors);
            //heatmap.blend(colorize(gradientMapNow, gradientColors), 0, 0, width, height, 0, 0, width, height, DIFFERENCE);
        }
    }
    
  
    public PImage addGradientPoint(PImage img, float x, float y) {
        int startX = int(x - heatmapBrush.width / 2);
        int startY = int(y - heatmapBrush.height / 2);
        for(int pY = 0; pY < heatmapBrush.height; pY++) {
            for(int pX = 0; pX < heatmapBrush.width; pX++) {
                int hmX = startX + pX;
                int hmY = startY + pY;
                if( hmX < 0 || hmY < 0 || hmX >= img.width || hmY >= img.height ) continue;
                int c = heatmapBrush.pixels[pY * heatmapBrush.width + pX] & 0xff;
                int i = hmY * img.width + hmX;
                if(img.pixels[i] < 0xffffff - c) {
                    img.pixels[i] += c;
                    if(img.pixels[i] > maxValue) maxValue = img.pixels[i];
                }
            }
        }
        return img;
    }
    
    
    //public PImage colorize(PImage gradientMap, PImage heatmapColors) {
    //    PImage heatmap = createImage(width, height, ARGB);
    //    heatmap.loadPixels();
    //    for(int i=0; i< gradientMap.pixels.length; i++) {
            
    //        int c = heatmapColors.pixels[ (int) map(gradientMap.pixels[i], 0, maxValue, 0, heatmapColors.pixels.length-1) ];
    //        heatmap.pixels[i] = c;
    //    }    
    //    heatmap.updatePixels();
    //    return heatmap;
    //}
    
    public PImage colorize(PImage gradientMap, PImage heatmapColorsHot, PImage heatmapColorsCold) {
      if (title=="RNC") maxValue=maxDelta;
      PImage heatmap = createImage(width, height, ARGB);
      heatmap.loadPixels();
      for(int i=0; i< gradientMap.pixels.length; i++) {
        int pix=gradientMap.pixels[i];
        int c;
        if (pix>=0){ //will always be true unless it's the RNC delta heatmap
        c = heatmapColorsHot.pixels[ (int) map(pix, 0, maxValue, 0, heatmapColorsHot.pixels.length-1) ];}
        else {c = heatmapColorsCold.pixels[ (int) map(-pix, 0, -minDelta, 0, heatmapColorsCold.pixels.length-1) ];}
        heatmap.pixels[i] = c;
        }             
        heatmap.updatePixels();
        return heatmap;
    }


    public void draw(PGraphics p) {
        if (visible) {
            if (!tableView) {
                p.blend(heatmap, 0, 0, width, height, 0, 0, width, height, MULTIPLY);
            } else {
                p.beginShape();
                p.texture(heatmap);
                p.vertex(UpperLeft.x, UpperLeft.y, UpperLeft.x, UpperLeft.y);
                p.vertex(UpperRight.x, UpperRight.y, UpperRight.x, UpperRight.y);
                p.vertex(LowerRight.x, LowerRight.y, LowerRight.x, LowerRight.y);
                p.vertex(LowerLeft.x, LowerLeft.y, LowerLeft.x, LowerLeft.y);
                p.endShape();
            }
        }
    }
    
    
}