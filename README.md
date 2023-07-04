# GUI-for-PWV

This document provides an overview of the different GUI pages, for installation help see the 'How to Install' file and for helpt in using the GUI see the 'How to Use' file.

Home Page

This page acts as a welcome screen for would be users. The properties section of the code allows the global variables to be defined. These are variables that can be used across the whole page. Three buttons are used alongside three button pushed call-backs to record the type of measurements the user has and then pass them to the next page.

Whichinputs  

This page allows users to select the data they have and the units of that data, alongside if the inputs are all contained within one file (achieved using a toggle switch). The first drop down menu allows the user to select if they have that data and what format it is in. The second allows them to select the units. A dropdown value changed callback is used to save the changed value of the drop down to a variable.

Inputpage

This page (based off the selections on the previous page) allows user to upload the data to the GUI. In order to limit erroneous data entry, the visible property of some of the features was set to ‘off’ so that only the necessary upload functionality was visible. Users first select the file and then the column within the file that the data is in.

Pt_new

This page allows users to visualise the data on four plots. When the next button is pressed, it determines whether there is an ECG trace and if there is it asks the user to identify which two peaks they went to conduct the analysis between. Additionally, a popup is used to confirm that the user is happy with the graphs before they progress.

Smooth data

This page allows users to select using check boxes which signals they want to smooth. The window size and polynomial order are then selected by using numeric edit fields and these are run with a savitzy-golay filter.

PU Adjust

This page allows users to shift the waveforms left and right so that their upstrokes are aligned. This is achieved using four buttons two for each waveform.

PU

This pages displays three graphs that show the loop plots. It also contains four buttons that allow the waveforms to be shifted as on the previous page. The auto calculate button pushed call back computes the wave speed by finding the gradient of the straight line section of the loop. There is also a manual option which is done using the calculate button pushed callback. The output graphs can also be saved using the savegraphsbutton pushed callback.

Windkessel

User manually enters the beat duration and then the calculate button pushed callback calculates the windkessel technique outputs and plots them on the axis.

Outputpage

This page uses the calculated wave speed from the PU page to calculate the wave separations and WIA. This is all done automatically within the start-up function. However, a numeric edit field has been edited that allows users to change the value of wave speed and so when this is changed, it calculates and plots the results for the new speed. Each graph and data set can be individually saved using the save data and save graph button pushed callbacks.



![image](https://github.com/tomt2234/GUI-for-PWV/assets/138600628/ae5fdba5-1ea9-4dae-9bb4-424312f091da)
