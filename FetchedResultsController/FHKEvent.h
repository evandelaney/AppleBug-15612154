//
//  Copyright (c) 2013 Fish Hook LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface FHKEvent : NSManagedObject

@property (strong, nonatomic) NSNumber *number;
@property (strong, nonatomic) NSDate *date;

@end
