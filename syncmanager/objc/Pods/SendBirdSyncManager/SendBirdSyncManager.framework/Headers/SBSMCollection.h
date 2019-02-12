//
//  SBSMCollection.h
//  SyncManager
//
//  Created by sendbird-young on 2018. 9. 3..
//  Copyright © 2018년 SendBird. All rights reserved.
//

#ifndef SBSMCollection_h
#define SBSMCollection_h

#import <Foundation/Foundation.h>

@protocol SBSMObject;

@protocol SBSMCollection <NSObject>

- (NSComparisonResult)orderAscendingBetweenObject:(id<SBSMObject> _Nonnull)obj1 andObject:(id<SBSMObject> _Nonnull)obj2;

@end

#endif /* SBSMCollection_h */
