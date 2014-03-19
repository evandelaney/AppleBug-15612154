//
//  Copyright (c) 2013 Fish Hook LLC. All rights reserved.
//

#import "FHKEvent.h"

@implementation FHKEvent

@dynamic number;
@dynamic date;

- (id)valueForKeyPath:(NSString *)keyPath
{
    return [super valueForKeyPath:keyPath];
}

- (id)valueForKey:(NSString *)key
{
    return [super valueForKey:key];
}

@end
