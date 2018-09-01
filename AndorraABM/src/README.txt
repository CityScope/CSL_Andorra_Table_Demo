CS_Andorra_Table_demo/AndorraABM 

1. Open src.pde
2. press run

//Full Option (interface and cityIO)
boolean btController=true;
public boolean cityIO = true; 

//SafeMode (no interface and no cityIO)
boolean btController=false;
public boolean cityIO = false

-----------------------------------------------------------------------------------------------------------------------------
Possible troubleshots:

* If the simulation doesn't display on the projector  (Windows can change the number of Screen)  edit the src.pde in setup()
fullScreen(P3D, 1);

* Physical interface (battery and connection)
0. If the simulation is running and the battery is empty the simulation will keep on.
1. If you need to restart the simulation be sure the arduino battery is charged (if not replace it and charge it). 
2. It might happen that the interface doesn't work even if the bluetooth is correctly set in that case rerun the model once.
3.If the arduino is not connected reconnect the button be sure to have HC-06 connected as a bluetooth device (PIN:1234)

-----------------------------------------------------------------------------------------------------------------------------

Contacts: agrignard@media.mit.edu

 