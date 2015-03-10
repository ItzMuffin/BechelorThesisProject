//
//  ViewController.h
//  energymonitorwriteonfile
//
//  Created by Michele Maffei on 03/03/15.
//  Copyright (c) 2015 Michele Maffei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *batteryLevel;
@property (strong, nonatomic) IBOutlet UILabel *connectionType;
@property (strong, nonatomic) IBOutlet UILabel *rssi;
@property (strong, nonatomic) IBOutlet UIButton *startMonitoringButton;
@property (strong, nonatomic) IBOutlet UIButton *stopMonitoringButton;
@property (strong, nonatomic) IBOutlet UILabel *CPULoad;
@property (strong, nonatomic) IBOutlet UILabel *memory;
@property (strong, nonatomic) IBOutlet UILabel *avgWiFid;
@property (strong, nonatomic) IBOutlet UILabel *avgWWANd;
@property (strong, nonatomic) IBOutlet UILabel *avgWiFiu;
@property (strong, nonatomic) IBOutlet UILabel *avgWWANu;
@property (strong, nonatomic) IBOutlet UILabel *dMBWiFi;
@property (strong, nonatomic) IBOutlet UILabel *dMBWWAN;
@property (strong, nonatomic) IBOutlet UILabel *uMBWiFi;
@property (strong, nonatomic) IBOutlet UILabel *uMBWWAN;

- (IBAction)startMonitoringButtonPressed:(UIButton *)sender;
- (IBAction)stopMonitoringButtonPressed:(UIButton *)sender;
- (IBAction)mailLogButtonPressed:(UIButton *)sender;
- (IBAction)deleteLogButtonPressed:(UIButton *)sender;

@end

