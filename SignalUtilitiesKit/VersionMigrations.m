//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "VersionMigrations.h"
#import "OWSDatabaseMigrationRunner.h"
#import "SignalKeyingStorage.h"

#import <SignalUtilitiesKit/AppContext.h>
#import <SignalUtilitiesKit/AppVersion.h>
#import <SignalUtilitiesKit/NSUserDefaults+OWS.h>
#import <SignalUtilitiesKit/OWSPrimaryStorage+Loki.h>

#import <SignalUtilitiesKit/TSAccountManager.h>

#import <SignalUtilitiesKit/TSThread.h>
#import <SignalUtilitiesKit/TSGroupThread.h>
#import <YapDatabase/YapDatabase.h>
#import <SignalUtilitiesKit/SignalUtilitiesKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

#define NEEDS_TO_REGISTER_PUSH_KEY @"Register For Push"
#define NEEDS_TO_REGISTER_ATTRIBUTES @"Register Attributes"

@interface SignalKeyingStorage (VersionMigrations)

+ (void)storeString:(NSString *)string forKey:(NSString *)key;
+ (void)storeData:(NSData *)data forKey:(NSString *)key;

@end

@implementation VersionMigrations

#pragma mark - Dependencies

+ (TSAccountManager *)tsAccountManager
{
    OWSAssertDebug(SSKEnvironment.shared.tsAccountManager);
    
    return SSKEnvironment.shared.tsAccountManager;
}

#pragma mark - Utility methods

+ (void)performUpdateCheckWithCompletion:(VersionMigrationCompletion)completion
{
    OWSLogInfo(@"");

    // performUpdateCheck must be invoked after Environment has been initialized because
    // upgrade process may depend on Environment.
    OWSAssertDebug(Environment.shared);
    OWSAssertDebug(completion);

    NSString *previousVersion = AppVersion.sharedInstance.lastAppVersion;
    NSString *currentVersion = AppVersion.sharedInstance.currentAppVersion;

    OWSLogInfo(@"Checking migrations. currentVersion: %@, lastRanVersion: %@", currentVersion, previousVersion);

    if (!previousVersion) {
        OWSLogInfo(@"No previous version found. Probably first launch since install - nothing to migrate.");
        OWSDatabaseMigrationRunner *runner = [[OWSDatabaseMigrationRunner alloc] init];
        [runner assumeAllExistingMigrationsRun];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
        return;
    }

    if ([self isVersion:previousVersion atLeast:@"2.0.0" andLessThan:@"2.1.70"] && [self.tsAccountManager isRegistered]) {
        [self clearVideoCache];
    }

    if ([self isVersion:previousVersion atLeast:@"2.0.0" andLessThan:@"2.3.0"] && [self.tsAccountManager isRegistered]) {
        [self clearBloomFilterCache];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[OWSDatabaseMigrationRunner alloc] init] runAllOutstandingWithCompletion:completion];
    });
}

+ (BOOL)isVersion:(NSString *)thisVersionString
          atLeast:(NSString *)openLowerBoundVersionString
      andLessThan:(NSString *)closedUpperBoundVersionString
{
    return [self isVersion:thisVersionString atLeast:openLowerBoundVersionString] &&
        [self isVersion:thisVersionString lessThan:closedUpperBoundVersionString];
}

+ (BOOL)isVersion:(NSString *)thisVersionString atLeast:(NSString *)thatVersionString
{
    return [thisVersionString compare:thatVersionString options:NSNumericSearch] != NSOrderedAscending;
}

+ (BOOL)isVersion:(NSString *)thisVersionString lessThan:(NSString *)thatVersionString
{
    return [thisVersionString compare:thatVersionString options:NSNumericSearch] == NSOrderedAscending;
}

#pragma mark Upgrading to 2.1 - Removing video cache folder

+ (void)clearVideoCache
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    basePath = [basePath stringByAppendingPathComponent:@"videos"];

    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:basePath]) {
        [NSFileManager.defaultManager removeItemAtPath:basePath error:&error];
    }

    if (error) {
        OWSLogError(
            @"An error occured while removing the videos cache folder from old location: %@", error.debugDescription);
    }
}

#pragma mark Upgrading to 2.3.0

// We removed bloom filter contact discovery. Clean up any local bloom filter data.
+ (void)clearBloomFilterCache
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *cachesDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *bloomFilterPath = [[cachesDir objectAtIndex:0] stringByAppendingPathComponent:@"bloomfilter"];

    if ([fm fileExistsAtPath:bloomFilterPath]) {
        NSError *deleteError;
        if ([fm removeItemAtPath:bloomFilterPath error:&deleteError]) {
            OWSLogInfo(@"Successfully removed bloom filter cache.");
            [LKStorage writeSyncWithBlock:^(YapDatabaseReadWriteTransaction *_Nonnull transaction) {
                [transaction removeAllObjectsInCollection:@"TSRecipient"];
            }];
            OWSLogInfo(@"Removed all TSRecipient records - will be replaced by SignalRecipients at next address sync.");
        } else {
            OWSLogError(@"Failed to remove bloom filter cache with error: %@", deleteError.localizedDescription);
        }
    } else {
        OWSLogDebug(@"No bloom filter cache to remove.");
    }
}

@end

NS_ASSUME_NONNULL_END
