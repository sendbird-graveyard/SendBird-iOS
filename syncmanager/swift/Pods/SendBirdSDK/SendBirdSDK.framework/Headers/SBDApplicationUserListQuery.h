//
//  SBDApplicationUserListQuery.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 11/6/18.
//  Copyright © 2018 SENDBIRD.COM. All rights reserved.
//

#import "SBDUserListQuery.h"
#import "SBDUser.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The `SBDApplicationUserListQuery` class is a query class for getting the list of all users of the current application. This instance is created by `createApplicationUserListQuery` of `SBDMain`.
 @since 3.0.120
 */
@interface SBDApplicationUserListQuery : SBDUserListQuery

/**
 Sets the user IDs filter.
 */
@property (copy, nonatomic, nullable) NSArray <NSString *> *userIdsFilter;

/**
 The meta data key filter. This query will return users that has the meta data key and values. This has to be set by `setMetaDataFilterWithKey:values:`.
 */
@property (copy, nonatomic, readonly, nullable) NSString *metaDataKeyFilter;

/**
 The meta data values filter. This query will return users that has the meta data key and values. This has to be set by `setMetaDataFilterWithKey:values:`.
 */
@property (copy, nonatomic, readonly, nullable) NSArray <NSString *> *metaDataValuesFilter;

/**
 Sets meta data filter.
 
 @param key The key of the meta data to use for filter.
 @param values The values of the meta data to use for filter.
 */
- (void)setMetaDataFilterWithKey:(nullable NSString *)key
                          values:(nullable NSArray<NSString *> *)values;

@end

NS_ASSUME_NONNULL_END
