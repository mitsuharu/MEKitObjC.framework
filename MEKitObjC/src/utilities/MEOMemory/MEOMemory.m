//
//  MyMemory.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 12/09/06.
//
//

#import "MEOMemory.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <mach/host_info.h>
#import <mach/mach_init.h>

@interface MEOMemory ()
{
    vm_statistics_data_t statistics_;
    vm_size_t pagesize_;
    host_basic_info_data_t host_;
}
-(BOOL)updateStatistics;
-(BOOL)updateHost;
@end

@implementation MEOMemory

-(NSString*)description
{
    float scale = 1000*1000;
    NSMutableString *str = [NSMutableString string];
    [str appendFormat:@"Memory\n"];
    [str appendFormat:@"free     = %.3lf MB\n", self.free/scale];
    [str appendFormat:@"active   = %.3lf MB\n", self.active/scale];
    [str appendFormat:@"inactive = %.3lf MB\n", self.inactive/scale];
    [str appendFormat:@"wire     = %.3lf MB\n", self.wire/scale];
    [str appendFormat:@"sesure   = %.3lf MB\n", self.sesure/scale];
    [str appendFormat:@"other    = %.3lf MB\n", self.other/scale];
    [str appendFormat:@"total    = %.3lf MB\n", self.total/scale];
    return str;
}

-(BOOL)updateStatistics
{
    host_page_size(mach_host_self(), &pagesize_);
    mach_msg_type_number_t size = HOST_BASIC_INFO_COUNT;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&statistics_, &size) != KERN_SUCCESS)
    {
        return NO;
    }
    return YES;
}

-(BOOL)updateHost
{
    mach_msg_type_number_t size = HOST_BASIC_INFO_COUNT;
    if (host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&host_, &size) != KERN_SUCCESS )
    {
        return NO;
    }
    return YES;
}

-(double)free
{
    if ([self updateStatistics] == NO) {
        return -1;
    }
    
    double memory = statistics_.free_count * pagesize_;
    return (double)memory;
}

-(double)active
{
    if ([self updateStatistics] == NO) {
        return -1;
    }
    
    // DLog(@"%d %d", statistics_.active_count , pagesize_);
    
    double memory = statistics_.active_count * pagesize_;
    return (double)memory;
}

-(double)inactive
{
    if ([self updateStatistics] == NO) {
        return -1;
    }
    
    double memory = statistics_.inactive_count * pagesize_;
    return (double)memory;
}

-(double)wire
{
    if ([self updateStatistics] == NO) {
        return -1;
    }
    
    double memory = statistics_.wire_count * pagesize_;
    return (double)memory;
}

-(double)sesure
{
    double active = [self active];
    if ( active < 0)
    {
        return -1;
    }
    
    double inactive = [self inactive];
    if ( inactive < 0)
    {
        return -1;
    }
    
    double wire = [self wire];
    if ( wire < 0)
    {
        return -1;
    }
    
    return (active + inactive + wire);
}

-(double)other
{
    double total = [self total];
    if ( total < 0)
    {
        return -1;
    }
    
    double free = [self free];
    if ( free < 0)
    {
        return -1;
    }
    
    double sesure = [self sesure];
    if ( sesure < 0)
    {
        return -1;
    }
    
    return (total - free - sesure);
}

-(double)total
{
    if ([self updateHost] == NO) {
        return -1;
    }
    
    double memory_size = host_.memory_size;
    return (double)memory_size;
}

@end
