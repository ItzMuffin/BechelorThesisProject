//
//  ViewController.m
//  energymonitorwriteonfile
//
//  Created by Michele Maffei on 03/03/15.
//  Copyright (c) 2015 Michele Maffei. All rights reserved.
//

#import "ViewController.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "Reachability.h"
#import "CoreTelephony.h"
#import <MessageUI/MessageUI.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#include <dlfcn.h>


@interface ViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation ViewController

{
    Reachability *internetReachable;
    
    CTTelephonyNetworkInfo *telephonyInfo;
    
    NSFileHandle *fileHandle;
    
    NSTimer *masterTimer;
    
    NSString *logFilePath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.batteryLevel.text = @"-";
    self.connectionType.text = @"-";
    self.rssi.text = @"-";
    self.CPULoad.text = @"-";
    self.memory.text = @"-";
    
    self.stopMonitoringButton.hidden = YES;
    
    internetReachable = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath = [paths firstObject];
    
    logFilePath = [docPath stringByAppendingPathComponent:@"log.csv"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil];
    }
    
    fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:logFilePath];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Battery Level

- (NSString *)getBatteryLevel
{
    float batteryLevel = [[UIDevice currentDevice] batteryLevel];
    if (batteryLevel < 0.0) {
        // -1.0 means battery state is UIDeviceBatteryStateUnknown
        self.batteryLevel.text = @"Level Unknown";
        
        return @"Level Unknown";
    }
    else {
        static NSNumberFormatter *numberFormatter = nil;
        if (numberFormatter == nil) {
            numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
            [numberFormatter setMaximumFractionDigits:1];
        }
        
        NSNumber *levelObj = [NSNumber numberWithFloat:batteryLevel];
        self.batteryLevel.text = [numberFormatter stringFromNumber:levelObj];
        
        return [numberFormatter stringFromNumber:levelObj];
    }
}

#pragma mark - Connection Type

- (NSString *)getConnectionType
{
    NSString *connectionType = [[NSString alloc] init];
    
    if ([internetReachable isReachableViaWWAN]) {
        
        NSString *currentRadio = telephonyInfo.currentRadioAccessTechnology;
        
        if ([currentRadio isEqualToString:CTRadioAccessTechnologyLTE]) {
            connectionType = @"LTE";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyHSDPA] || [currentRadio isEqualToString:CTRadioAccessTechnologyHSUPA]){
            connectionType = @"HSPA";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyWCDMA]) {
            connectionType = @"3G";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyGPRS]) {
            connectionType = @"GPRS";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyEdge]) {
            connectionType = @"Edge";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyCDMA1x] || [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] || [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] || [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
            connectionType = @"CDMA";
        }

    } else if ([internetReachable isReachableViaWiFi]) {
        connectionType = @"WiFi";
    } else connectionType = @"Not Reachable";

    self.connectionType.text = connectionType;
    
    return connectionType;
}

#pragma mark - Memory

- (CGFloat)totalMemory {
    double totalMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    totalMemory = ((vm_page_size * (vmStats.active_count + vmStats.inactive_count + vmStats.wire_count + vmStats.free_count)) / 1024) / 1024;
    
    return totalMemory;
}

- (CGFloat)freeMemory {
    double freeMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    freeMemory = ((vm_page_size * vmStats.free_count) / 1024) / 1024;
    
    return freeMemory;
}

- (CGFloat)usedMemory {
    double usedMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    usedMemory = ((vm_page_size * (vmStats.active_count + vmStats.inactive_count + vmStats.wire_count)) / 1024) / 1024;
    
    return usedMemory;
}

- (CGFloat)activeMemory {
    double activeMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    activeMemory = ((vm_page_size * vmStats.active_count) / 1024) / 1024;
    
    return activeMemory;
}

- (CGFloat)wiredMemory {
    double wiredMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    wiredMemory = ((vm_page_size * vmStats.wire_count) / 1024) / 1024;
    
    return wiredMemory;
}

- (CGFloat)inactiveMemory {
    double inactiveMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    inactiveMemory = ((vm_page_size * vmStats.inactive_count) / 1024) / 1024;
    
    return inactiveMemory;
}

- (NSString *)getMemoryUsage
{
    NSNumber *freeMemoryPercent = [NSNumber numberWithFloat:([self freeMemory] * 100)/[self totalMemory]];
    NSNumber *activeMemoryPercent = [NSNumber numberWithFloat:(([self usedMemory] - [self wiredMemory] - [self inactiveMemory]) * 100)/[self totalMemory]];
    NSNumber *wiredMemoryPercent = [NSNumber numberWithFloat:([self wiredMemory] * 100)/[self totalMemory]];
    NSNumber *inactiveMemoryPercent = [NSNumber numberWithFloat:([self inactiveMemory] * 100)/[self totalMemory]];
    
    NSString *memoryUsage = [NSString stringWithFormat:@"F:%@, U:%@, W:%@, I:%@", freeMemoryPercent, activeMemoryPercent, wiredMemoryPercent, inactiveMemoryPercent];
    
    NSLog(@"%@", memoryUsage);
    
    self.memory.text = memoryUsage;
    
    return memoryUsage;
}

#pragma mark - CPU Load

float cpu_usage()
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0;
    
    basic_info = (task_basic_info_t)tinfo;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    }
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

- (NSString *)getCPULoad
{
    static NSNumberFormatter *numberFormatter = nil;
    if (numberFormatter == nil) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        [numberFormatter setMaximumFractionDigits:1];
    }
    
    NSNumber *levelObj = [NSNumber numberWithFloat:cpu_usage()];
    self.CPULoad.text = [numberFormatter stringFromNumber:levelObj];
    
    return [numberFormatter stringFromNumber:levelObj];
}
#pragma mark - RSSI

int getSignalStrength()
{
    void *libHandle = dlopen("/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony", RTLD_LAZY);
    int (*CTGetSignalStrength)();
    CTGetSignalStrength = dlsym(libHandle, "CTGetSignalStrength");
    if( CTGetSignalStrength == NULL) NSLog(@"Could not find CTGetSignalStrength");
    int result = CTGetSignalStrength();
    dlclose(libHandle);
    return result;
}


- (NSString *)getRSSI
{
    NSString *signalStrength = [NSString stringWithFormat:@"%i", getSignalStrength()];
    self.rssi.text = signalStrength;
    
    return signalStrength;
}

#pragma mark - Write on file

- (void)writeDataOnFile:(NSTimer *)timer
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy  HH:mm:ss"];
    
    NSDate *date = [NSDate date];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    NSString *data = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@\n", [self getBatteryLevel], [self getConnectionType], [self getRSSI], [self getCPULoad], [self getMemoryUsage], formattedDateString];
    
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}


#pragma mark - IBActions

- (IBAction)startMonitoringButtonPressed:(UIButton *)sender
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil];
    }
    
    masterTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(writeDataOnFile:) userInfo:nil repeats:YES];
    
    [masterTimer fire];
    
    self.stopMonitoringButton.hidden = NO;
    self.startMonitoringButton.hidden = YES;
}

- (IBAction)stopMonitoringButtonPressed:(UIButton *)sender
{
    [masterTimer invalidate];
    
    self.stopMonitoringButton.hidden = YES;
    self.startMonitoringButton.hidden = NO;
    
    self.batteryLevel.text = @"-";
    self.connectionType.text = @"-";
    self.rssi.text = @"-";
    self.CPULoad.text = @"-";
    self.memory.text = @"-";
}

- (IBAction)mailLogButtonPressed:(UIButton *)sender
{

//con questo qualche volta non manda l'allegato
    
    NSData *data = [NSData dataWithContentsOfFile:logFilePath];
    if (data == nil) return;
    
    if([MFMailComposeViewController canSendMail] == NO) return;
    
    MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
    
    mailVC.mailComposeDelegate = self;
    
    [mailVC addAttachmentData:data mimeType:@"text/csv" fileName:[[logFilePath componentsSeparatedByString:@"/"] lastObject]];
    
    NSArray *recipents = @[@"michele.muffin@gmail.com"];
    
    [mailVC setSubject:@"Energy monitor log"];
    
    [mailVC setToRecipients:recipents];
    
    [self presentViewController:mailVC animated:YES completion:^{
        
    }];
    
// Con questo da molti più problemi con l'allegato
    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
//        NSData *data = [NSData dataWithContentsOfFile:logFilePath];
//        if (data == nil) return;
//        
//        if([MFMailComposeViewController canSendMail] == NO) return;
//        
//        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
//        
//        mailVC.mailComposeDelegate = self;
//        
//        [mailVC addAttachmentData:data mimeType:@"text/csv" fileName:[[logFilePath componentsSeparatedByString:@"/"] lastObject]];
//        
//        NSArray *recipents = @[@"michele.muffin@gmail.com"];
//        
//        [mailVC setSubject:@"Energy monitor log"];
//        
//        [mailVC setToRecipients:recipents];
//        
//        [self presentViewController:mailVC animated:YES completion:^{
//            
//        }];
//
//    } else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"No log file in documents directory" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
//        [alertView show];
//    }

}

- (IBAction)deleteLogButtonPressed:(UIButton *)sender
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:logFilePath error:&error];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"No log file in documents directory" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
