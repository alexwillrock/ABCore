//
//  ABStorageManager.h
//  ABP2P
//
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ABStorageManager : NSObject
{
	BOOL _shouldBeEncrypted;
}


@property (readonly, strong, nonatomic) NSManagedObjectContext			* managedObjectContextMain;
@property (readonly, strong, nonatomic) NSManagedObjectContext			* managedObjectContext;
@property (readonly, weak, nonatomic) NSManagedObjectContext			* managedObjectContextForCurrentThread;
@property (readonly, strong, nonatomic) NSManagedObjectModel			* managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator	* persistentStoreCoordinator;
@property (nonatomic, strong) NSString									* databaseCipher;

- (id)initWitEncryption:(BOOL)shouldBeEncrypted;

+ (NSURL *)applicationDocumentsDirectory;

- (void)reset;
- (void)cleanAllData;
- (BOOL)isStorageAvaliable;

+ (void)saveContext:(NSManagedObjectContext *)context andPerformBlockAfter:(void (^)())success;

@end
