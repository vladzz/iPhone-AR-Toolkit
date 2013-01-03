# iPhone Augmented Reality Toolkit#

## Overview ##

This version of the iPhone ARKit is a forked version of the ARKit started on GitHub by Zac White, then forked by jjamminjim.  

## Screenshots ##

![Vertical](http://i.imgur.com/heW49l.png) ![Horizontal 1](http://i.imgur.com/TA8lXl.png)

### Goals of the project ###
* ~~Not depended on a specific View Controller or the main App Delegate. (Completed) [jjamminjim]~~
* ~~Ability to use both the Landscape and Portrait modes. (Completed) [jjamminjim]~~
* ~~Use CoreLocation coordinates and update location as the user moves around. (Completed) [jjamminjim]~~
* ~~Ability to add different type of views to augment. (Completed) [jjamminjim]~~
* ~~Ability to touch any of the augment views to handle other tasks. (Completed) [jjamminjim]~~
* ~~Convert to ARC / remove deallocs (Completed)~~
* ~~Improve the markers (aesthetically) (Completed)~~
* Add a Radar Control

iPhone ARKit's APIs are modeled after MapKit's. For an overview of MapKit, please read [the documentation](http://developer.apple.com/iphone/library/documentation/MapKit/Reference/MapKit_Framework_Reference/index.html) for more information.

## Current Status ##

The AR kit is targeting the iOS6 SDK.

## Current Issues ##
Detecting correct screen size (for iPhone 5, status bars, nav bars etc...)

## Acknowledgements ##
I would like to thank Zac White for starting the initial project and giving me the ability to fork his code and make the changes I see to make an awesome ARKit.
I would also like to thank Jim Boyd for allowing me to fork his code (and all the people who have helped him get the ARKit repo to where it was when I forked it).

## MIT License ##

Copyright (c) 2013 Ed Rackham (edrackham.com)

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