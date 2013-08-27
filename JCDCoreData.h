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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface JCDCoreData : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext *defaultContext;

+ (JCDCoreData *)sharedInstance;
+ (NSManagedObjectContext *)defaultContext;

@end


#pragma mark - NSManagedObjectContext additions

@interface NSManagedObjectContext (JCDCoreData)

- (id)insertNewObjectWithEntityName:(NSString *)entityName;
- (NSArray *)fetchObjectArrayWithRequest:(NSFetchRequest *)request;
- (NSUInteger)fetchCountWithRequest:(NSFetchRequest *)request;
- (NSFetchRequest *)fetchRequestForEntity:(NSEntityDescription *)entity;
- (NSFetchRequest *)fetchRequestForEntityName:(NSString *)entityName;
- (NSFetchRequest *)fetchRequestForEntityName:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate;
- (NSArray *)fetchObjectsWithEntityName:(NSString *)entityName sortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)predicate;
- (id)fetchFirstObjectWithEntityName:(NSString *)entityName sortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)predicate;
- (NSUInteger)fetchCountWithEntityName:(NSString *)entityName andPredicate:(NSPredicate *)predicate;

@end


#pragma mark - NSManagedObject additions

@interface NSManagedObject (JCDCoreData)

+ (NSString *)entityName;
+ (NSArray *)fetchAllInContext:(NSManagedObjectContext *)context;
+ (NSArray *)fetchObjectsInContext:(NSManagedObjectContext *)context sortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)predicate;
+ (NSUInteger)fetchCountInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate;
+ (instancetype)fetchFirstObjectInContext:(NSManagedObjectContext *)context sortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)predicate;
+ (instancetype)newObjectInContext:(NSManagedObjectContext *)context;

@end
