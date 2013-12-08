//
//  Copyright (c) 2013 Fish Hook LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FHKEvent : NSManagedObject

@property (strong, nonatomic) NSNumber *number;
@property (strong, nonatomic) NSDate *date;

@end
