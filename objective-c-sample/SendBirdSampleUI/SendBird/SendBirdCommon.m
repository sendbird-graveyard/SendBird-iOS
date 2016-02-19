//
//  SendBirdCommon.m
//  SendBirdSample
//
//  Created by SendBird Developers on 2015. 5. 20..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import "SendBirdCommon.h"

#pragma mark - ImageCache

@implementation ImageCache {
    
}

static NSCache *cache;
static ImageCache *_sharedInstance = nil;

+ (ImageCache *) sharedInstance
{
    @synchronized([ImageCache class]) {
        // TODO: Check proper NSAssertX.
        NSAssert(_sharedInstance != nil, @"Cache instance hasn't been initialized.");
        return _sharedInstance;
    }
    return nil;
}

+ (id) alloc
{
    @synchronized([ImageCache class]) {
        NSAssert(_sharedInstance == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedInstance = [super alloc];
        return _sharedInstance;
    }
    return nil;
}

+ (void) initImageCache
{
    if (_sharedInstance == nil) {
        _sharedInstance = [[ImageCache alloc] init];
        [_sharedInstance initCache];
    }
}

- (void) initCache
{
    cache = [[NSCache alloc] init];
    [cache setName:@"ImageCache"];
    [cache setCountLimit:40];
}

- (UIImage *)getImage:(NSString *)key
{
    if ([cache objectForKey:key] != nil && ![[cache objectForKey:key] isKindOfClass:[NSNull class]]) {
        UIImage *image = [cache objectForKey:key];
        return image;
    }
    
    return nil;
}

- (void)setImage:(UIImage *)image withKey:(id<NSCopying>)key
{
    if (key == nil || image == nil) {
        return;
    }
    
    if ([cache objectForKey:key] != nil && ![[cache objectForKey:key] isKindOfClass:[NSNull class]]) {
        [cache removeObjectForKey:key];
    }
    
    [cache setObject:image forKey:key];
}

@end

#pragma mark - SendBirdUtils

@implementation SendBirdUtils

+ (NSString *) deviceUniqueID
{
    NSString *uniqueID = [NSString stringWithFormat:@"%@",[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    return	uniqueID;
}

+ (void)imageDownload:(NSURL *)url endBlock:(void (^)(NSData *response, NSError *error))onEnd
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"Jios/%@", [SendBird VERSION]] forHTTPHeaderField:@"User-Agent"];
    [request setURL:url];
    
#if 0
    NSBlockOperation *theOp = [NSBlockOperation blockOperationWithBlock:^{
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        onEnd(data, error);
    }];
    [theOp start];
#else
    [NSURLConnection sendAsynchronousRequest:request queue:[[SendBird sharedInstance] imageTaskQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        onEnd(data, connectionError);
    }];
#endif
    
}

+ (NSString *) getChannelNameFromUrl:(NSString *)channelUrl
{
    NSArray *result = [channelUrl componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    if ([result count] > 1) {
        return [result objectAtIndex:1];
    }
    else {
        return channelUrl;
    }
}

+ (NSString *) getUrlFromString:(NSString *)bulk
{
    NSArray *arrString = [bulk componentsSeparatedByString:@" "];
    NSString *url = @"";
    for(int i = 0; i < arrString.count; i++){
        if([[arrString objectAtIndex:i] rangeOfString:@"http://" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            url = [arrString objectAtIndex:i];
            break;
        }
        
        if([[arrString objectAtIndex:i] rangeOfString:@"https://" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            url = [arrString objectAtIndex:i];
            break;
        }
    }
    
    return url;
}

+ (NSString *) messageDateTime:(NSTimeInterval) interval
{
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSCalendar *todayCalendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [todayCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:today];
    NSDateComponents *messageDateComponents = [todayCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:messageDate];
    
    NSInteger dayOfNow = [todayComponents day];
    NSInteger monthOfNow = [todayComponents month];
    NSInteger yearOfNow = [todayComponents year];
    NSInteger dayOfMessage = [messageDateComponents day];
    NSInteger monthOfMessage = [messageDateComponents month];
    NSInteger yearOfMessage = [messageDateComponents year];
    
    [formatter setLocale:[NSLocale currentLocale]];
    
    if (dayOfNow != dayOfMessage) {
        [formatter setDateFormat:@"MM/dd/YY, HH:mm"];
    }
    else {
        if (monthOfNow != monthOfMessage || yearOfNow != yearOfMessage) {
            [formatter setDateFormat:@"MM/dd/YY, HH:mm"];
        }
        else {
            [formatter setTimeStyle:NSDateFormatterShortStyle];
        }
    }
    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    return [formatter stringFromDate:messageDate];
}

+ (NSString *) oldMessageDateTime:(NSTimeInterval) interval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"MM/dd/YY, HH:mm"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    return [formatter stringFromDate:date];
}

+ (NSString *) lastMessageDateTime:(NSTimeInterval) interval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    return [formatter stringFromDate:date];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGFloat)width
{
    float newWidth = 0;
    float newHeight = 0;
    if (image.size.width > image.size.height) {
        newWidth = width * image.size.width / image.size.height;
        newHeight = width;
    }
    else {
        newHeight = width * image.size.width / image.size.height;
        newWidth = width;
    }
    
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    UIGraphicsBeginImageContextWithOptions(newSize, YES, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (NSString *) getDisplayMemberNames:(NSArray *)members
{
    if ([members count] < 2) {
        return @"No Members";
    }
    else if ([members count] == 2) {
        NSMutableString *names = [[NSMutableString alloc] init];
        for (int i = 0; i < [members count]; i++) {
            SendBirdMember *member = [members objectAtIndex:i];
            if ([[member guestId] isEqualToString:[SendBird getUserId]]) {
                continue;
            }
            
            [names appendString:@", "];
            [names appendString:[member name]];
        }
        [names deleteCharactersInRange:NSMakeRange(0, 2)];
        return names;
    }
    else {
        return [NSString stringWithFormat:@"Group %lu", (unsigned long)[members count]];
    }
}

+ (NSString *) getMessagingChannelNames:(NSArray *)members
{
    if ([members count] > 1) {
        NSMutableString *names = [[NSMutableString alloc] init];
        for (int i = 0; i < [members count]; i++) {
            SendBirdMemberInMessagingChannel *member = [members objectAtIndex:i];
            if ([[member guestId] isEqualToString:[SendBird getUserId]]) {
                continue;
            }
            
            [names appendString:@", "];
            [names appendString:[member name]];
        }
        [names deleteCharactersInRange:NSMakeRange(0, 2)];
        return names;
    }
    else {
        return @"";
    }
}

+ (NSString *) getDisplayCoverImageUrl:(NSArray *)members
{
    for (SendBirdMemberInMessagingChannel *member in members) {
        if ([[member guestId] isEqualToString:[SendBird getUserId]]) {
            continue;
        }
        
        return [member imageUrl];
    }
    
    return @"";
}

+ (void) setMessagingMaxMessageTs:(long long)messageTs
{
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:[NSNumber numberWithLongLong:messageTs] forKey:@"messaging_max_message_ts"];
    [preferences synchronize];
}

+ (long long) getMessagingMaxMessageTs
{
    long long maxMessageTs = LLONG_MIN;
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    
    if ([preferences objectForKey:@"messaging_max_message_ts"] != nil) {
        maxMessageTs = [[preferences objectForKey:@"messaging_max_message_ts"] longLongValue];
    }

    return maxMessageTs;
}

+ (void)loadImage:(NSString *)imageUrl imageView:(UIImageView *)imageView width:(CGFloat)width height:(CGFloat)height
{
    __weak UIImageView *iv = imageView;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"Jios/%@", [SendBird VERSION]] forHTTPHeaderField:@"User-Agent"];
    [request setURL:[NSURL URLWithString:imageUrl]];
    
    [iv setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        CGSize newSize = CGSizeMake(height * 2, width * 2);
        float widthRatio = newSize.width / image.size.width;
        float heightRatio = newSize.height / image.size.height;
        
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(image.size.width * heightRatio, image.size.height * heightRatio);
        }
        else {
            newSize = CGSizeMake(image.size.width * widthRatio, image.size.height * widthRatio);
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [iv setImage:newImage];
    } failure:nil];
}

@end

#pragma mark - NSMutableArray+SendBirdMessageOrdering
@implementation NSMutableArray (SendBirdMessageOrdering)

- (void) addSendBirdMessage:(SendBirdMessageModel *)message updateMessageTsBlock:(void (^)(SendBirdMessageModel *model))updateMessageTs
{
    if ([message isPast]) {
        [self insertObject:message atIndex:0];
    }
    else {
        [self addObject:message];
    }
    
    updateMessageTs(message);
}

@end