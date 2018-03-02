# CityScope Andorra
Grasshopper Script Documentation for Andorra CityScope Project


## Running CityScope Andorra

0. To show the command line (if Rhino crashed) paste this in Rhino: ```DisplayCommandPrompt```

1. Run ```CityMatrix.3dm``` on desktop;

2. Type the command ```Grasshopper``` or ```GH``` and press ```Enter```;

3. Click the last opened Gh file (will appear as the upper-left icon on the canvas)

4. Check camera:
	* Right click the camera component and select the ```Logitec HD webcam``` 
	* select the ```Slow(1s)``` option
	* select the highest resolution option;

5. Move the Rhino window to the projector display;

6. (Make sure you click Rhino once to have the focus) and directly type the command ```fullscreen``` or ```FULL```; (the camera is named "T1", see below)


## Building Types

ID #  | Type
------------- | -------------
-2 | Mask of full site overflow
-1  | Mask of interactive area
0  | RL 
1  | RM
2 | RS
3 	| OL
4 | OM
5 | OS
6 | Road 
7 | Amenities
8 | Park
9 | Parking


## Dependencies


We used Gh 0.9.0076 for development.

All Grasshopper libraries are that need to be added in Grasshopper's Components Folder are in /Users/dalma/Dropbox (MIT)/CityMatrix_Volpe/RH_GH/resources/Grasshopper Plugins.

These are the following:

* Human & TreeFrog
* Horster Camera Control v0.1
* GhPython (needs Python installed) 0.6.0.3


Libraries that need to be installed are found in /Users/dalma/Dropbox (MIT)/CityMatrix_Volpe/RH_GH/resources/Grasshopper Plugins/installers and are the following:

* Firefly 1.0070



## Rhino Viewports

Shortcut  | Purpose
------------- | -------------
T* (ideally, T1) | 'Table view' or the view of the 2D City Matrix on the table
G* (ideally, G1) | 'Graph view'
C1  | The view of the camera's image for grid scan calibration 
C2 | The view of the partitioned RGB color space for grid scan calibration (color sampling)


## Grasshopper Variables

### Main variables

Variable Name  | Role | Color
------------- | ------------- | -------------
```grid X extent```  | X dimension of base grid (unmasked) | Green 
```grid Y extent```  | Y dimension of base grid (unmasked) | Green
```grid resolution``` | Int for defining grid size; either 2x2 or 4x4 | Green
```` dockID``` 	| The ID of the current item sitting at the dock position (for modifying floor heights etc.) | Red
```moduleID``` | The current scanned ID of each module (masked) | Magenta
```slider``` | The current slider value | Red

Each time a variable reoccurs, it has to be copied so that a new reference is created with the same color at the right position.

### Variables that need to be customized

All variables specific to each city (project) are at the top left and are referenced from here later on.

Variable Name  | Role | Color
------------- | ------------- | -------------
```grid mask```  | The bitmask that defines the active area for the given grid (creating a custom site/ shape) | Green 
```full site grid``` | The grid IDs for the full site |
```webcam``` | Webcam video stream | Yellow
```grid corner points``` | The corner points (in order) that define a polyline that encloses the grid.

### Rhino references

All objects references from Rhino are blue.


## Grasshopper Script Structure

### 1 Input

#### 1.1 OpenCV (Grid scanning & color detection)

To change or calibrate what the camera sees, you need to look at the 'C1' view in Rhino (type 'C1' in the command prompt) and enable the camera visualization components (noted below).

###### 1.1.1 Camera

The grid scanning relies on a camera component (WebCam Video Stream) that needs to be installed separately. This can be found by typing 'webcam' in Grasshopper's search. This is normally set to the highest resolution at 1 fps.

As a static workfile, sometimes an image is used from the Data folder.

For calibration, you can enable all the CV components that are not normally displayed.

###### 1.1.2 CV Processing

The scanning basically keystones the camera's view. The grid is perspective corrected and the remapped points used for scanning.

*Color*

For finding the sample point's closest color, three spheres are defined that modify the partitioning of the 3D color space all sampled colors belong to. These spheres can be moved to recalibrate what the definition of 'black' of 'red' in the current camera's vision is. You can do this in Rhino by enabling the Color Space Visualization group. We're currently using RGB space, but could also use HSV.

*Decoding IDs*

All color cells are then converted to IDs ignoring rotations by listing all possible permutations.

This happens for all sampled cells and for the dock item.

###### 1.1.3 ID Masking

Module IDs are masked according to the bitmask at the top left.


#### 1.2 Physical UI

##### Sliders

There are two sliders; ```slider 2``` is the slider for floor heights and ```slider 1``` is the slider to toggle between heatmap states / visualizations.

In Volpe, the sliders are a part of the CV/ scanning process; however, in Andorra, this will have to change due to lack of room for the physical interface. These are currently calibrated using sample points in Rhino--one on the base for the slider (e.g. all red), and the other outside of it (e.g. white).

The values of slider 1 (for the visualizations) range from [0, 9].

The values of slider 2 (for buiding heights) range from [1, 30].

#### 1.3 Building types & meshes (Linked from Rhino)

Meshes are referenced from Rhino, but their color was initially set (and thus if need be modified, has to be modified) in Grasshopper.

Switching between ground floor view and regular (top floors) view also takes place here. Ground floor meshes are without type and number labels.

#### 1.4 Building heights

Building heights are determined using slider 2. They range from 1-30, and they modify the density of the neighborhood.

#### 1.5 Full site parsing

Another mask is added for the full site with the same building types.




### 2 Analysis

#### 2.1 Excel parsing

Excel files are now read directly and parsed in Grasshopper.

#### 2.2 Sending data to Unity

As a JSON file.

### 3 Output

#### 3.1 2D City Matrix

2D City Matrix includes the 2D residential and office bricks (RL, RS, RM etc.) projected down onto the table with roads and other building types.

#### 3.2 3D City Matrix (also Unity)

The 3D matrix is now being visualized in Unity only, but for potential future use, it is also in Grasshopper. 

The Grasshopper version also clusters the same building types so that they are visualized as one large unit rather than a set of bricks.

#### 3.3 Heatmaps

#### 3.4 Graphs

#### 3.5 People visualization

#### 3.6 Dashboard projection (UI)
















