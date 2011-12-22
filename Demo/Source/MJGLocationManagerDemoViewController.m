//
//  ViewController.m
//  MJGLocationManagerDemo
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

#import "MJGLocationManagerDemoViewController.h"

#import "MJGLocationManager.h"

@implementation MJGLocationManagerDemoViewController

@synthesize accuracyField, maxAgeField, timeoutField;
@synthesize startButton;
@synthesize locationTextField;

#pragma mark -

- (IBAction)startTapped:(id)sender {
    self.startButton.enabled = NO;
    [self.accuracyField resignFirstResponder];
    [self.maxAgeField resignFirstResponder];
    [self.timeoutField resignFirstResponder];
    self.locationTextField.text = @"Locating...";
    
    MJGLocationRequest *newRequest = [[MJGLocationRequest alloc] initWithAccuracy:[self.accuracyField.text floatValue] 
                                                                   maxLocationAge:[self.maxAgeField.text floatValue] 
                                                                          timeout:[self.timeoutField.text floatValue]];
    newRequest.delegate = self;
    [[MJGLocationManager sharedManager] addLocationRequest:newRequest];
}


#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup the shared instance
    [[MJGLocationManager sharedManager] setDesiredAccuracy:kCLLocationAccuracyBest];
    [[MJGLocationManager sharedManager] setLocationRequiredMessage:@"Location is required for this application."];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.accuracyField = nil;
    self.maxAgeField = nil;
    self.timeoutField = nil;
    
    self.startButton = nil;
    
    self.locationTextField = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - MJGLocationRequestDelegate

- (void)locationRequestFinished:(MJGLocationRequest *)request withLocation:(CLLocation *)location {
    self.locationTextField.text = [location description];
    self.startButton.enabled = YES;
}

@end
