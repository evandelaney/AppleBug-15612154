//
//  Copyright (c) 2013 Fish Hook LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "FHKAppDelegate.h"

//----------------------------------------------------------------------------//

@interface FHKAppDelegate ()

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectContext *parentManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *childManagedObjectContext;

@end

//----------------------------------------------------------------------------//

@implementation FHKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self _insertFakeData];
    
    UIViewController *viewController = self.window.rootViewController;
    [viewController setValue:self.childManagedObjectContext forKey:@"managedObjectContext"];
    
    return YES;
}

#pragma mark -

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        NSURL *storeURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                 inDomain:NSUserDomainMask
                                                        appropriateForURL:nil
                                                                   create:NO
                                                                    error:NULL];
        storeURL = [storeURL URLByAppendingPathComponent:@"Events.sqlite"];
        
        NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:@[ [NSBundle mainBundle] ]];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:NULL];

        [self setPersistentStoreCoordinator:psc];
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)parentManagedObjectContext
{
    if (!_parentManagedObjectContext) {
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [moc setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        
        [self setParentManagedObjectContext:moc];
    }
    
    return _parentManagedObjectContext;
}

- (NSManagedObjectContext *)childManagedObjectContext
{
    if (!_childManagedObjectContext) {
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [moc setParentContext:self.parentManagedObjectContext];
//        [moc setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        
        [self setChildManagedObjectContext:moc];
    }
    
    return _childManagedObjectContext;
}

#pragma mark - Private Helper

- (void)_insertFakeData
{
    NSManagedObjectContext *moc = self.childManagedObjectContext;
    
    NSManagedObject *fakeEvent1 = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:moc];
    [fakeEvent1 setValue:[NSDate dateWithTimeIntervalSinceNow:-30] forKey:@"date"];
    [fakeEvent1 setValue:@3 forKey:@"number"];
    
    NSManagedObject *fakeEvent2 = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:moc];
    [fakeEvent2 setValue:[NSDate dateWithTimeIntervalSinceNow:-20] forKey:@"date"];
    [fakeEvent2 setValue:@11 forKey:@"number"];
    
    NSManagedObject *fakeEvent3 = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:moc];
    [fakeEvent3 setValue:[NSDate dateWithTimeIntervalSinceNow:-20] forKey:@"date"];
    [fakeEvent3 setValue:@9 forKey:@"number"];
    
    NSManagedObject *fakeEvent4 = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:moc];
    [fakeEvent4 setValue:[NSDate dateWithTimeIntervalSinceNow:-30] forKey:@"date"];
    [fakeEvent4 setValue:@8 forKey:@"number"];
    
    NSManagedObject *fakeEvent5 = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:moc];
    [fakeEvent5 setValue:[NSDate dateWithTimeIntervalSinceNow:-10] forKey:@"date"];
    [fakeEvent5 setValue:@1 forKey:@"number"];
    
    NSManagedObject *fakeEvent6 = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:moc];
    [fakeEvent6 setValue:[NSDate dateWithTimeIntervalSinceNow:-10] forKey:@"date"];
    [fakeEvent6 setValue:@7 forKey:@"number"];
    
    [moc save:NULL];
//    [self.parentManagedObjectContext performBlock:^{
//        [self.parentManagedObjectContext save:NULL];
//    }];
}

@end
