# iPhone Augmented Reality Kit#

## Overview ##

This version of the iPhone ARKit is a forked version of the ARKit started on GitHub by Zac White.  

### Goals of the project ###
* Not depended on a specific View Controller or the main App Delegate. (Completed)
* Ability to use both the Landscape and Portrait modes (Completed)
* Use CoreLocation coordinates and update location as the user moves around. (Completed.) 
* Use CoreData to store coordinates (Not yet implemented.)
* Ability to add different type of views to augment. (Not yet implemented.)
* Ability to touch any of the augment views to handle other tasks. (Completed.)
* Add a Radar Control (Not yet implemented)

iPhone ARKit's APIs are modeled after MapKit's. For an overview of MapKit, please read [the documentation](http://developer.apple.com/iphone/library/documentation/MapKit/Reference/MapKit_Framework_Reference/index.html) for more information.

## Current Status ##

* The big changes to the UI kit is that its using new features of iOS4. 
* Using the AVFoundation instead of the UIViewImagePickerControler.
* No longer a ModalViewController but instead a view. 
* Launches from a different view, and items are not clickable and will display their own View Controller with information.
* Improved perfomance.
* 

## Current Issues ##
Still having issues with some minor memory leaks.  Looking into what we need to do to fix this. If anyone sees a memory leak,
please let me know where and I'll take a look and fix it ASAP.


## Blog for Project ##
More information about the project can be found at [the agilite software blog](http://www.agilitesoftware.com/blog)

## Acknowledgements ##
I would like to thank Zac White for starting the initial project and giving me the ability to fork his code and make the changes I see to make an awesome ARKit.
I would also like to thank Gamaliel A. Toro Herrera, Jared Crawford and Mike Tigas for their contributes to the project that I pulled in from their forked projects.

## MIT License ##

Copyright (c) 2011 Agilite Software

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.