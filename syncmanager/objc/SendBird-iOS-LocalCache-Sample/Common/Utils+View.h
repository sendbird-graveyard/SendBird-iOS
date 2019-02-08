//
//  Utils+View.h
//  SendBird-iOS-LocalCache-Sample
//
//  Created by sendbird-young on 03/02/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

#import "Utils.h"

NS_ASSUME_NONNULL_BEGIN

@interface Utils (View)

+ (void)tableView:(nonnull UITableView *)tableView performBatchUpdates:(nonnull void (^)(UITableView * _Nonnull tableView))updateProcess completion:(nullable void(^)(BOOL finished))completionHandler;

+ (BOOL)isTopViewController:(nonnull UIViewController *)viewController;
+ (nonnull UIViewController *)topViewController;

@end

NS_ASSUME_NONNULL_END
