//
//  Copyright (c) 2013 Fish Hook LLC. All rights reserved.
//

#import "FHKViewController.h"

//----------------------------------------------------------------------------//

@interface FHKViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

//----------------------------------------------------------------------------//

@implementation FHKViewController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        
        NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        NSSortDescriptor *sortByAwesomeness = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
        [fetchRequest setSortDescriptors:@[ sortByDate, sortByAwesomeness ]];
        [fetchRequest setResultType:NSManagedObjectResultType];     // Default value
        [fetchRequest setIncludesPendingChanges:YES];               // Default value
        [fetchRequest setIncludesPropertyValues:YES];               // Default value
        [fetchRequest setShouldRefreshRefetchedObjects:NO];         // Default value
        
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                              managedObjectContext:self.managedObjectContext
                                                                                sectionNameKeyPath:@"date"
                                                                                         cacheName:nil];
        
        NSError *fetchError = nil;
        BOOL success = [frc performFetch:&fetchError];
        
        if (!success) {
            NSLog(@"%@", fetchError.localizedDescription);
        }
        
        [self setFetchedResultsController:frc];
    }
    
    return _fetchedResultsController;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
#warning Interesting Stuff Here!
    
    // App Delegate's child managed object context save operation causes managed
    // objects to be saved into it's parent managed object context (colloquially
    // referred to as "pushing saves up one level"). However, if the parent
    // managed object context does not persist these objects to disk
    // (meaning: parentContext.hasChanges == YES), thereby obtaining permenant
    // object IDs, then the fetched results controller does not create sections
    // based on the keypath passed at initialization.
    //
    // I believe this has *something* to do with Key-Value Coding. Overriding
    // -[NSManagedObject valueForKeyPath:] yields the following interesting
    // backtrace when the fetched results controller fetches on a dirty managed
    // object context that is directly connected to a persistent store
    // coordinator:
    //
    // frame #0:  FetchedResultsController`-[FHKEvent valueForKeyPath:](self=0x08c7dd90, _cmd=0x012a5b93, keyPath=0x00005888) + 57 at FHKEvent.m:15
    // frame #1:  CoreData`-[NSFetchedResultsController(PrivateMethods) _sectionNameForObject:] + 50
    // frame #2:  CoreData`-[NSFetchedResultsController(PrivateMethods) _computeSectionInfo:error:] + 1151
    // frame #3:  CoreData`-[NSFetchedResultsController performFetch:] + 1021
    // frame #4:  FetchedResultsController`-[FHKViewController fetchedResultsController](self=0x08a9ef70, _cmd=0x000043e8) + 700 at FHKViewController.m:39
    // frame #5:  FetchedResultsController`-[FHKViewController numberOfSectionsInTableView:](self=0x08a9ef70, _cmd=0x00998b00, tableView=0x09295000) + 78 at FHKViewController.m:78
    // frame #6:  UIKit`-[UITableViewRowData(UITableViewRowDataPrivate) _updateNumSections] + 102
    // frame #7:  UIKit`-[UITableViewRowData invalidateAllSections] + 69
    // frame #8:  UIKit`-[UITableView _updateRowData] + 194
    // frame #9:  UIKit`-[UITableView _ensureRowDataIsLoaded] + 45
    // frame #10:  UIKit`-[UITableView numberOfSections] + 35
    // frame #11:  UIKit`-[UITableViewController viewWillAppear:] + 103
    // --snip--
    //
    // However, when the fetched results controller fetches on a "clean" child
    // (hasChanges == NO) of a dirty parent context (that parent context dirtied
    // by a save pushing changes up), -[NSManagedObject valueForKeyPath:] isn't
    // called after -[NSFetchedResultsController _computeSectionInfo:error:].
    // -[NSFetchedResultsController _sectionNameForObject:] isn't called at all
    // in this situation.
    //
    // How can I replicate this behavior?
    // 1. In FHKAppDelegate, line 72 should be uncommented and line 73 should remain commented
    //     [moc setParentContext:self.parentManagedObjectContext];
    //     //[moc setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    // 2. In FHKAppDelegate, line 111 should be uncommented and lines 112 - 114 should remain commented
    //     [moc save:NULL];
    //     //[self.parentManagedObjectContext performBlock:^{
    //     //   [self.parentManagedObjectContext save:NULL];
    //     //}];
    // 3. Put a break point on line 40 of FHKViewController (this file).
    // 4. Build and run
    // 5. When execution halts in the debugger, `po frc.sections` will output an empty array
    //
    // Possible Solutions:
    // 1. Save the child and parent contexts
    //      This might cause a race condition if fetch finishes before the parent save completes
    // 2. Don't save the child context
    //      This doesn't accomplish the goal of being able to push changes up whenever necessary
    // 3. Set the fetched results controller's keypath to @"self.<keypath>"
    //      This seems to force the KVC process, but seems likely to have a performance penalty
    // 4. Find some combination of fetch request properties that causes the fetch to do the right thing
    
    
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.fetchedResultsController.sections objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    return cell;
}

@end
