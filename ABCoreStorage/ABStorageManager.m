//
//  ABStorageManager.m
//  ABP2P
//
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

#import "ABStorageManager.h"
#import "EncryptedStore.h"
#import "sqlite3.h"
#import <ABUtils.h>

@implementation ABStorageManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectContextMain = _managedObjectContextMain;
@synthesize managedObjectContextForCurrentThread;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize databaseCipher = _databaseCipher;

#pragma mark -
#pragma mark - Class Methods

+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark -
#pragma mark - Init

- (id)initWitEncryption:(BOOL)shouldBeEncrypted
{
	if (self = [super init])
	{
		_shouldBeEncrypted = shouldBeEncrypted;
	}

	return self;
}


#pragma mark -
#pragma mark - Helpers

- (NSString *)className
{
	NSString * className = NSStringFromClass([self class]);

	return className;
}

- (void)setDatabaseCipher:(NSString *)databaseCipher
{
	if (![_databaseCipher isEqual:databaseCipher])
	{
		if (_databaseCipher && databaseCipher)
		{
			[self reset];
			[self rekeyDatabaseWithCipherString:databaseCipher];
		}

		_databaseCipher = databaseCipher;
		[self reset];
	}
}

- (BOOL)rekeyDatabaseWithCipherString:(NSString *)cipher
{
	sqlite3 * database;

	if (sqlite3_open([[[self storageURL] path] UTF8String], &database) == SQLITE_OK)
	{
		const char * oldCipher = [_databaseCipher UTF8String];
		int openStatus = sqlite3_key(database, oldCipher, (int)strlen(oldCipher));
		oldCipher = NULL;
		if (openStatus == SQLITE_OK)
		{
			const char *string = [cipher UTF8String];
			int status = sqlite3_rekey(database, string, (int)strlen(string));
			string = NULL;
			cipher = nil;

			if (status == SQLITE_OK)
			{
				sqlite3_close(database);
				database = NULL;
				
				return YES;
			}
		}
	}
	else
	{
		DLog(@"Database error: %@",[NSString stringWithUTF8String:sqlite3_errmsg(database)]);
	}

	sqlite3_close(database);

	return NO;
}


- (void)reset
{
	[[NSNotificationCenter defaultCenter]removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
	_persistentStoreCoordinator = nil;
	_managedObjectContext = nil;
	_managedObjectContextMain = nil;
	_managedObjectModel = nil;
}

- (void)cleanStorage
{
    NSURL *storeURL = [self storageURL];

	NSError *error = nil;

	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]];

	[[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];

	if (error)
	{
		DLog(@"Error cleaning storage:%@", [error description]);
	}
	else if (exists)
	{
		DLog(@"\n\n\n\n\n\n\n\n\n%@ cleaned\n\n\n\n\n\n\n\n\n\n", storeURL.lastPathComponent);
	}

	_persistentStoreCoordinator = nil;
}

- (void)cleanAllData
{
	[self reset];
	[self cleanStorage];
}

- (BOOL)isStorageAvaliable
{
	BOOL isStorageAvaliable = !(_shouldBeEncrypted && self.databaseCipher.length == 0);

	return isStorageAvaliable;
}

+ (void)saveContext:(NSManagedObjectContext *)context andPerformBlockAfter:(void (^)())success
{
	if ([context hasChanges])
	{
		NSError * objectContextSaveError = nil;
		[context save:&objectContextSaveError];

		if (objectContextSaveError)
		{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
			ALog(@"Saving objects error: %@", [objectContextSaveError description]);
#pragma clang diagnostic pop
		}
		else
		{
			if (success)
			{
				success();
			}

		}
	}
    else
    {
        if (success)
        {
            success();
        }
    }
}


#pragma mark -
#pragma mark - Core Data Stack Init
- (NSURL *)storageURL
{
	NSString * storageFileName = [NSString stringWithFormat:@"%@%@.sqlite", [self className], _shouldBeEncrypted ? @"Encrypted" : @""];
    NSURL *storeURL = [[ABStorageManager applicationDocumentsDirectory] URLByAppendingPathComponent:storageFileName];

	return storeURL;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (![self isStorageAvaliable])
	{
		return nil;
	}

    if (_persistentStoreCoordinator != nil)
	{
		return _persistentStoreCoordinator;
	}

    NSURL *storeURL = [self storageURL];

	if (_shouldBeEncrypted)
	{
		_persistentStoreCoordinator = [EncryptedStore makeStoreWithDatabaseURL:storeURL managedObjectModel:[self managedObjectModel] : self.databaseCipher];
		DLog(@"%@ uses EncrytedStore", [self className]);
	}
	else
	{
		_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
		DLog(@"%@ uses regular store", [self className]);

		NSError * error = nil;
		[_persistentStoreCoordinator
		 addPersistentStoreWithType:NSSQLiteStoreType
		 configuration:nil
		 URL:storeURL
		 options:nil
		 error:&error];

		if (error)
		{
			DLog(@"Error occured while adding store to coordinator: %@", [error localizedDescription]);
		}
	}


    if (!_persistentStoreCoordinator || _persistentStoreCoordinator.persistentStores.count == 0)
	{
		[self cleanStorage];

        return [self persistentStoreCoordinator];
    }

    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
	{
		return _managedObjectModel;
	}

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[self className] withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return _managedObjectModel;
}

- (NSManagedObjectContext *)managedObjectContextMain
{
	if (![self isStorageAvaliable])
	{
		return nil;
	}

    @synchronized(self)
    {
        if (!_managedObjectContextMain)
        {
            NSManagedObjectContext * context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];

            context.persistentStoreCoordinator = self.persistentStoreCoordinator;
            context.undoManager = nil;
            context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
            _managedObjectContextMain = context;

			[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(contextDidSaveMainQueueContext:) name:NSManagedObjectContextDidSaveNotification object:_managedObjectContextMain];
        }
    }

    return _managedObjectContextMain;
}

- (NSManagedObjectContext *)managedObjectContextForCurrentThread
{
	if ([[NSThread currentThread]isMainThread])
	{
		return self.managedObjectContextMain;
	}
	else
	{
		return self.managedObjectContext;
	}
}

- (NSManagedObjectContext *)managedObjectContext
{
	if (![self isStorageAvaliable])
	{
		return nil;
	}

	@synchronized(self)
	{
		if (!_managedObjectContext)
		{
			NSManagedObjectContext * context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
			//		[context setParentContext:self.managedObjectContextMain];
			context.persistentStoreCoordinator = self.persistentStoreCoordinator;
			context.undoManager = nil;
			context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
			_managedObjectContext = context;

			[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(contextDidSavePrivateQueueContext:) name:NSManagedObjectContextDidSaveNotification object:_managedObjectContext];
		}
	}

    return _managedObjectContext;
}

#pragma mark - Notifications

- (void)contextDidSavePrivateQueueContext:(NSNotification *)notification
{
	@synchronized(self)
	{
		[self.managedObjectContextMain performBlock:
		^{
			[self.managedObjectContextMain mergeChangesFromContextDidSaveNotification:notification];
		}];
	}
}

- (void)contextDidSaveMainQueueContext:(NSNotification *)notification
{
	@synchronized(self)
	{
		[self.managedObjectContext performBlock:
		^{
			[self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
		}];
	}
}

@end
