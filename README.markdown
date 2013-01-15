# iPhone Augmented Reality Toolkit #

## Overview ##

This version of the iPhone ARKit is a forked version of the ARKit started on GitHub by Zac White, then forked by jjamminjim. I have made several improvements, which include a new customisable radar control, easier integration, better orientation / screen size detection.

## Screenshots ##
![Vertical](http://i.imgur.com/k5HJS.jpg) ![Horizontal 1](http://i.imgur.com/k9JMZ.jpg)

## Goals of the project ##
* ~~Not depended on a specific View Controller or the main App Delegate. (Completed) [jjamminjim]~~
* ~~Ability to use both the Landscape and Portrait modes. (Completed) [jjamminjim]~~
* ~~Use CoreLocation coordinates and update location as the user moves around. (Completed) [jjamminjim]~~
* ~~Ability to add different type of views to augment. (Completed) [jjamminjim]~~
* ~~Ability to touch any of the augment views to handle other tasks. (Completed) [jjamminjim]~~
* ~~Convert to ARC / remove deallocs (Completed)~~
* ~~Improve the markers (aesthetically) (Completed)~~
* ~~Add a Radar Control (Completed)~~

## In the pipeline ##
* iOS 5 Support
* Better callout placement
* API for useful data to be built in (such as country lists)

iPhone ARKit's APIs are modeled after MapKit's. For an overview of MapKit, please read [the documentation](http://developer.apple.com/iphone/library/documentation/MapKit/Reference/MapKit_Framework_Reference/index.html) for more information.

## How to Use ##
Firstly, copy the contents of the ARKit directory into your project. Then make sure you have the following frameworks linked:

- `QuartzCore`
- `MapKit`
- `CoreLocation`
- `AVFoundation`

#### Include ARKit.h ####
Open the .h file of the view controller you are going to use to display the augmented reality view. In here, add `#import "ARKit.h"`

#### Implement delegate methods ####
Now open the .m file for the same UIViewController and implement the following two methods:

`- (NSMutableArray *)geoLocations` This must return an array of `ARGeoCoordinate`'s. For example:
```
- (NSMutableArray *)geoLocations
	NSMutableArray 	*locationArray = [[NSMutableArray alloc] init];
	ARGeoCoordinate *tempCoordinate;
	CLLocation     	*tempLocation;

	tempLocation = [[CLLocation alloc] initWithLatitude:39.550051 longitude:-105.782067];
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Denver"];
	[locationArray addObject:tempCoordinate];

	tempLocation = [[CLLocation alloc] initWithLatitude:45.523875 longitude:-122.670399];
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Portland"];
	[locationArray addObject:tempCoordinate];

	return locationArray;
}
```

`- (void)locationClicked:(ARGeoCoordinate *)coordinate` This is to handle the taps on the locations. You can do whatever you wish within this method.


#### Display the augmented reality view ####
To display the augmented reality view (typically from a button) use:

```
if([ARKit deviceSupportsAR]){
	_arViewController = [[ARViewController alloc] initWithDelegate:self];
	[_arViewController setModalTransitionStyle: UIModalTransitionStyleFlipHorizontal];
	[self presentViewController:_arViewController animated:YES completion:nil];
}
```

## ARKit Options ##
There are a few options I've added in for turning things on/off, colourising the radar, setting the range etc... They are as follows:

- `setDebugMode:` *bool* - toggles debug mode on or off. Not really that useful. Default: NO.
- `setShowsRadar:` *bool* - toggles the radar on or off. Default: YES.
- `setScaleViewsBasedOnDistance:` *bool* - toggles whether to scale the popups based on their distance from you. Default: YES.
- `setMinimumScaleFactor:` *float* - sets the minimum scale factor for the popups. Default: 0.5.
- `setRotateViewsBasedOnPerspective:` *bool* - slightly rotates the popups based on the perspective. Default: YES.
- `setRadarPointColour:` *UIColor* - sets the colour of the points on the radar. Default: White.
- `setRadarBackgroundColour:` *UIColor* - sets the background colour of the radar. Default: Transparent green.
- `setRadarViewportColour:` *UIColor* - sets the viewport colour of the radar. Default: Less transparent green.
- `setRadarRange:` *float* - sets the range of the radar (in km). Default 20.0.
- `setOnlyShowItemsWithinRadarRange:` *bool* - toggles whether to show all popups, or hide the ones beyond the range of the radar. Default: NO.

### Example ###
This example will change the default look of the radar, limit the range to 4000km and hide any coordinates that would appear outside of this range.

```
if([ARKit deviceSupportsAR]){
	_arViewController = [[ARViewController alloc] initWithDelegate:self];
	[_arViewController setRadarBackgroundColour:[UIColor blackColor]];
	[_arViewController setRadarViewportColour:[UIColor colorWithWhite: 0.0 alpha:0.5]];
	[_arViewController setRadarPointColour:[UIColor whiteColor]];
	[_arViewController setRadarRange:4000.0];
	[_arViewController setOnlyShowItemsWithinRadarRange:YES];
	[_arViewController setModalTransitionStyle: UIModalTransitionStyleFlipHorizontal];
	[self presentViewController:_arViewController animated:YES completion:nil];
}
```


## Current Status ##
The ARKit is targeting the iOS6 SDK.

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
