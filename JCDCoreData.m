// JCDCoreData.m
//
// Copyright (c) 2013 Justin Driscoll (http://jdriscoll.org)
//
// Category methods adapted from work by by Matt Gallagher:
// http://www.cocoawithlove.com/2008/03/core-data-one-line-fetch.html
//
// and Craig Hockenberry:
// http://furbo.org/2012/04/05/core-data-without-fetch-requests/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "JCDCoreData.h"


@interface JCDCoreData ()
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *defaultContext;
@end

@implementation JCDCoreData

+ (JCDCoreData *)sharedInstance
{
    static JCDCoreData *_sharedInstance;

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

+ (NSString *)modelFilename
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+ (NSString *)databaseFilename
{
    return [[self modelFilename] stringByAppendingPathExtension:@"sqlite"];
}

+ (NSURL *)defaultStoreURL
{
    return [[self libraryDirectoryURL] URLByAppendingPathComponent:[self databaseFilename]];
}

+ (NSURL *)libraryDirectoryURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSManagedObjectContext *)defaultContext
{
    NSManagedObjectContext *defaultContext = [[JCDCoreData sharedInstance] defaultContext];
    return defaultContext;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSURL *storeURL = [JCDCoreData defaultStoreURL];
        self.persistentStoreCoordinator = [self persistentStoreCoordinatorWithModel:self.managedObjectModel
                                                                             andURL:storeURL];
    }
    return self;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[JCDCoreData modelFilename] withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }

    return _managedObjectModel;
}

- (NSManagedObjectContext *)defaultContext
{
    if (!_defaultContext) {
        if (_persistentStoreCoordinator) {
            _defaultContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_defaultContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
        }
    }

    return _defaultContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithModel:(NSManagedObjectModel *)managedObjectModel andURL:(NSURL *)storeURL
{
    NSError *error = nil;
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };

    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                             configuration:nil
                                                       URL:storeURL
                                                   options:options
                                                     error:&error];

    if (!persistentStoreCoordinator || persistentStoreCoordinator.persistentStores.count == 0) {
        NSLog(@"Error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable To Load Database"
                                                        message:@"Please restart the app and contact support if the issue persists."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }

    return persistentStoreCoordinator;
}

@end


#pragma mark - NSManagedObjectContext additions

@implementation NSManagedObjectContext (JCDCoreData)

- (id)insertNewObjectWithEntityName:(NSString *)entityName
{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self];
}

- (NSArray *)fetchObjectArrayWithRequest:(NSFetchRequest *)request
{
    NSError *error;
    NSArray *results = [self executeFetchRequest:request error:&error];

    NSAssert(error == nil, [error description]);

    return results;
}

- (NSUInteger)fetchCountWithRequest:(NSFetchRequest *)request
{
    NSError *error = nil;
    NSUInteger result = [self countForFetchRequest:request error:&error];

    NSAssert(error == nil, [error description]);

    return result;
}

- (NSFetchRequest *)fetchRequestForEntity:(NSEntityDescription *)entity
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];

    return request;
}

- (NSFetchRequest *)fetchRequestForEntityName:(NSString *)entityName
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    return [self fetchRequestForEntity:entity];
}

- (NSFetchRequest *)fetchRequestForEntityName:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *request = [self fetchRequestForEntityName:entityName];

    if (sortDescriptors)
        [request setSortDescriptors:sortDescriptors];

    if (predicate)
        [request setPredicate:predicate];

    return request;
}

- (NSArray *)fetchObjectsWithEntityName:(NSString *)entityName sortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *request = [self fetchRequestForEntityName:entityName sortDescriptors:sortDescriptors andPredicate:predicate];
    return [self fetchObjectArrayWithRequest:request];
}

- (NSManagedObject *)fetchFirstObjectWithEntityName:(NSString *)entityName sortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *request = [self fetchRequestForEntityName:entityName sortDescriptors:sortDescriptors andPredicate:predicate];
    [request setFetchLimit:1];

    NSArray *results = [self fetchObjectArrayWithRequest:request];

    if ([results count] == 0)
        return nil;

    return [results lastObject];
}

- (NSArray *)fetchObjectsWithEntityName:(NSString *)entityName usingPredicate:(NSPredicate *)predicate sortedBy:(NSString *)sortDescriptorKey ascending:(BOOL)ascending
{
    NSArray *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortDescriptorKey ascending:ascending];
    return [self fetchObjectsWithEntityName:entityName sortedBy:@[sortDescriptor] withPredicate:predicate];
}

- (NSManagedObject *)fetchFirstObjectWithEntityName:(NSString *)entityName usingPredicate:(NSPredicate *)predicate sortedBy:(NSString *)sortDescriptorKey ascending:(BOOL)ascending
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortDescriptorKey ascending:ascending];
    return [self fetchFirstObjectWithEntityName:entityName sortedBy:@[sortDescriptor] withPredicate:predicate];
}

- (NSUInteger)fetchCountWithEntityName:(NSString *)entityName andPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *request = [self fetchRequestForEntityName:entityName sortDescriptors:nil andPredicate:predicate];
    return [self fetchCountWithRequest:request];
}

@end


#pragma mark - NSManagedObject additions

@implementation NSManagedObject (JCDCoreData)

+ (NSString *)entityName
{
    return NSStringFromClass([self class]);
}

+ (NSArray *)fetchAllInContext:(NSManagedObjectContext *)context
{
    return [self fetchObjectsInContext:context sortedBy:nil withPredicate:nil];
}

+ (NSArray *)fetchObjectsInContext:(NSManagedObjectContext *)context sortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)predicate
{
    return [context fetchObjectsWithEntityName:[self entityName] sortedBy:sortDescriptors withPredicate:predicate];
}

+ (NSUInteger)fetchCountInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate
{
    return [context fetchCountWithEntityName:[self entityName] andPredicate:predicate];
}

+ (instancetype)fetchFirstObjectInContext:(NSManagedObjectContext *)context sortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)predicate
{
    return [context fetchFirstObjectWithEntityName:[self entityName] sortedBy:sortDescriptors withPredicate:predicate];
}

+ (instancetype)newObjectInContext:(NSManagedObjectContext *)context
{
    return [context insertNewObjectWithEntityName:[self entityName]];
}

@end
