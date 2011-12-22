//
//  MJGLocationRequest.m
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

#import "MJGLocationRequest.h"

@interface MJGLocationRequest ()
@property (nonatomic, unsafe_unretained) CLLocationAccuracy accuracy;
@property (nonatomic, unsafe_unretained) NSTimeInterval maxLocationAge;
@property (nonatomic, unsafe_unretained) NSTimeInterval timeout;

@property (nonatomic, strong) NSDate *startTime;
@end

@implementation MJGLocationRequest

@synthesize delegate;
@synthesize accuracy, maxLocationAge, timeout;
@synthesize startTime;

#pragma mark -

- (id)initWithAccuracy:(CLLocationAccuracy)inAccuracy maxLocationAge:(NSTimeInterval)inMaxLocationAge timeout:(NSTimeInterval)inTimeout {
    if(self = [super init]) {
        accuracy = inAccuracy;
        maxLocationAge = inMaxLocationAge;
        timeout = inTimeout;
        delegate = nil;
    }
    return self;
}


#pragma mark -

- (BOOL)isDone:(CLLocation*)location {
    BOOL thisDone = NO;
    
    NSTimeInterval locatorAge = -[startTime timeIntervalSinceNow];
    if (locatorAge > timeout) {
        thisDone = YES;
    }
    
    if (location) {
        CLLocationAccuracy locationHacc = location.horizontalAccuracy;
        NSTimeInterval locationAge = -[location.timestamp timeIntervalSinceNow];
        if (locationHacc <= accuracy && locationAge < maxLocationAge) {
            thisDone = YES;
        }
    }
    
    return thisDone;
}

- (void)start {
    startTime = [NSDate date];
}

@end

