# iPhone Augmented Reality Kit#

## Overview ##

This version of the iPhone ARKit is a forked version of the ARKit started on GitHub by Zac White.  

### Goals of the project ###
-Not depended on a specific View Controller or the main App Delegate. (Completed)
-Use CoreLocation coordinates and update location as the user moves around. (not yet completed.) 
-Use CoreData to store coordinates (Not yet implemented.)
-Ability to use both the Landscape and Portrait modes (Almost done, sort of working but will be improving this. Portrait and Landscape right works (Landscape Right is not 100%))
-Ability to add different type of views to augment. (Not yet implemented.)
-Ability to touch any of the augment views to handle other tasks. (Not yet implemented.)
-Create as a static library that can be added to any other project.


iPhone ARKit's APIs are modeled after MapKit's. For an overview of MapKit, please read [the documentation](http://developer.apple.com/iphone/library/documentation/MapKit/Reference/MapKit_Framework_Reference/index.html) for more information.

## Current Status ##

This is a very early stage is is not ready to be used in existing projects. 
It's possible to run the toolkit with the current ViewController, but it's currently not the ARKit it needs to be to add to your project(s).
The current code now has been updated to use the accelerator's z variable to determine the angle of the phone and where to position it.

## Blog for Project ##
More information about the project can be found at [the agilite software blog](http://www.agilitesoftware.com/blog)

## Acknowledgements ##
I would like to thank Zac White for starting the initial project and giving me the ability to fork his code and make the changes I see to make an awesome ARKit.
