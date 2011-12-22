//
//  MJGLocationManager.m
//  MJGLocationManager
//
//  Copyright (c) 2011 Matt Galloway. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer. 
//
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "MJGLocationManager.h"

#import "MJGLocationRequest.h"

static MJGLocationManager *sharedManager = nil;

@interface MJGLocationManager () <CLLocationManagerDelegate>
@property (nonatomic, unsafe_unretained, readwrite) BOOL isLocating;
@property (nonatomic, strong) CLLocation *latestLocation;
@property (nonatomic, strong) NSTimer *locationRequestQueueTimer;
@property (nonatomic, strong) NSMutableSet *locationRequests;
@property (nonatomic, unsafe_unretained) id <CLLocationManagerDelegate> actualDelegate;

- (void)startLocating;
- (void)stopLocating;
- (void)showRequiredAlert;
- (void)checkForFinishedLocationRequests;
@end

@implementation MJGLocationManager

@synthesize isLocating, locationRequiredMessage;
@synthesize latestLocation, locationRequestQueueTimer, locationRequests, actualDelegate;

#pragma mark - Singleton Methods

+ (id)sharedManager {
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
        }
    }
    return sharedManager;
}


#pragma mark -

- (void)addLocationRequest:(MJGLocationRequest*)request {
    [locationRequests addObject:request];
    [request start];
    [self startLocating];
}

- (void)removeLocationRequest:(MJGLocationRequest*)request {
    [locationRequests removeObject:request];
    if (locationRequests.count == 0) {
        [self stopLocating];
    }
}


#pragma mark - Custom accessors

- (id<CLLocationManagerDelegate>)delegate {
    return self.actualDelegate;
}

- (void)setDelegate:(id<CLLocationManagerDelegate>)delegate {
    self.actualDelegate = delegate;
}


#pragma mark -

- (void)startLocating {
    @synchronized(self) {
        if ([CLLocationManager locationServicesEnabled]) {
            if (!isLocating) {
                isLocating = YES;
                [self startUpdatingLocation];
                self.locationRequestQueueTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkForFinishedLocationRequests) userInfo:nil repeats:YES];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showRequiredAlert];
            });
        }
    }
}

- (void)stopLocating {
    @synchronized(self) {
        if(isLocating) {
            isLocating = NO;
            [self stopUpdatingLocation];
            [self.locationRequestQueueTimer invalidate];
            self.locationRequestQueueTimer = nil;
        }
    }
}

- (void)showRequiredAlert {
    if (self.locationRequiredMessage && ![self.locationRequiredMessage isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" 
                                                        message:self.locationRequiredMessage 
                                                       delegate:nil 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void)checkForFinishedLocationRequests {
    @synchronized(self) {
        NSMutableSet *doneRequests = [NSMutableSet setWithCapacity:0];
        
        for (MJGLocationRequest *request in locationRequests) {
            if ([request isDone:latestLocation]) {
                [doneRequests addObject:request];
                [request.delegate locationRequestFinished:request withLocation:latestLocation];
            }
        }
        
        for (MJGLocationRequest *request in doneRequests) {
            [locationRequests removeObject:request];
        }
        
        if (locationRequests.count == 0) {
            [self stopLocating];
        }
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    latestLocation = [newLocation copy];
    [self checkForFinishedLocationRequests];
    
    if ([self.actualDelegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
        [self.actualDelegate locationManager:self didUpdateToLocation:newLocation fromLocation:oldLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if ([self.actualDelegate respondsToSelector:@selector(locationManager:didUpdateHeading:)]) {
        [self.actualDelegate locationManager:self didUpdateHeading:newHeading];
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    if ([self.actualDelegate respondsToSelector:@selector(locationManagerShouldDisplayHeadingCalibration:)]) {
        return [self.actualDelegate locationManagerShouldDisplayHeadingCalibration:self];
    }
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([self.actualDelegate respondsToSelector:@selector(locationManager:didEnterRegion:)]) {
        [self.actualDelegate locationManager:self didEnterRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([self.actualDelegate respondsToSelector:@selector(locationManager:didExitRegion:)]) {
        [self.actualDelegate locationManager:self didExitRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    @synchronized(self) {
        isLocating = NO;
        [self stopUpdatingLocation];
        
        if ([error code] == kCLErrorDenied) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showRequiredAlert];
            });
        }
    }
    
    if ([self.actualDelegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
        [self.actualDelegate locationManager:self didFailWithError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    if ([self.actualDelegate respondsToSelector:@selector(locationManager:monitoringDidFailForRegion:withError:)]) {
        [self.actualDelegate locationManager:self monitoringDidFailForRegion:region withError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([self.actualDelegate respondsToSelector:@selector(locationManager:didChangeAuthorizationStatus:)]) {
        [self.actualDelegate locationManager:self didChangeAuthorizationStatus:status];
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    if ([self.actualDelegate respondsToSelector:@selector(locationManager:didStartMonitoringForRegion:)]) {
        [self.actualDelegate locationManager:self didStartMonitoringForRegion:region];
    }
}


#pragma mark -

- (id)init {
    if ((self = [super init])) {
        [super setDelegate:self];
        
        isLocating = NO;
        latestLocation = nil;
        locationRequestQueueTimer = nil;
        locationRequests = [[NSMutableSet alloc] init];
    }
    return self;
}

@end
