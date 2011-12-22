# MJGLocationManager

## Introduction

MJGLocationManager is a cunning wrapper around CLLocationManager to add some very useful features. 
The most important feature which it adds is the ability to ask to be called back when the location 
reaches a given accuracy and the location is not over a certain age. This might never be reached, 
but fear not, you can also give it a timeout to be called back even if the desired accuracy & age 
have not been met.

Since MJGLocationManager is a subclass of CLLocationManager, all the normal methods you are used to 
are available. You can even attach yourself as a delegate in the usual way to observe the location 
changes yourself in the normal way.

MJGLocationManager has a singleton-style shared instance as well so you can use it from all over 
your app which is something I always felt CLLocationManager lacked.

## License

MJGLocationManager uses the 2-clause BSD license. So you should be free to use it pretty much however 
you want. Contact me if you require further information.

Copyright (c) 2011 Matt Galloway. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Automatic Reference Counting (ARC)

This project uses ARC.

## Author

MJGLocationManager is written and maintained by Matt Galloway <http://iphone.galloway.me.uk>.

## How to use

### Adding MJGLocationManager to your project ###

All you need to do to get started is to add everything in the `Source` folder to your project.

### Using MJGLocationManager ###

Using MJGLocationManager to obtain the user's location is as easy as this:

 1. Implement the `MJGLocationRequestDelegate` protocol in your class:

        #import <UIKit/UIKit.h>
        #import "MJGLocationRequest.h"
        
        @interface MyClass : UIViewController <MJGLocationRequestDelegate>
        
        @end
        
        @implementation MyClass
        
        - (void)locationRequestFinished:(MJGLocationRequest *)request withLocation:(CLLocation *)location {
        	// Handle the location
        }
        
        @end

 1. Setup the `MJGLocationManager` instance as you see fit:

        // Setup the shared instance
        [[MJGLocationManager sharedManager] setDesiredAccuracy:kCLLocationAccuracyBest];
        [[MJGLocationManager sharedManager] setLocationRequiredMessage:@"Location is required for this application."];

 1. Make a request:

        // Add a new request
        MJGLocationRequest *newRequest = [[MJGLocationRequest alloc] initWithAccuracy:100.0f 
                                                                       maxLocationAge:600.0 
                                                                              timeout:30.0];
        newRequest.delegate = self;
        [[MJGLocationManager sharedManager] addLocationRequest:newRequest];

 1. Wait for the request to come back and handle the location in `locationRequestFinished:withLocation:location`
