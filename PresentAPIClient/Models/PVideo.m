//
//  PVideo.m
//  Present
//
//  Created by Justin Makaila on 11/13/13.
//  Copyright  2013 Present, Inc. All rights reserved.
//

#import "PVideo.h"

#import "PLocation.h"
#import "PLike+ResourceMethods.h"
#import "PRelationship.h"
#import "PView+ResourceMethods.h"
#import "PResult.h"
#import "PUser+SubjectiveObjectMeta.h"
#import "PComment+ResourceMethods.h"
#import "PPlace.h"

#import "PExternalServices.h"
#import "PSocialData.h"

#import "PSocialManager.h"

#import <objc/runtime.h>
#import <NSArray+Convenience.h>

@interface PVideo ()

@property (strong, nonatomic) NSString *archivedUrlString;
@property (strong, nonatomic) NSString *hlsUrlString;
@property (strong, nonatomic) NSString *coverUrlString;
@property (strong, nonatomic) NSString *shareUrlString;

@end

@implementation PVideo

#pragma mark PObject Protocol

+ (NSString*)classResource {
    return @"videos";
}

+ (Class)resourceResultClass {
    return PVideoResult.class;
}

#pragma mark MTLJSONSerilizing

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"creatorUserResult": @"creatorUser",
        @"startTime": @"creationTimeRange.startDate",
        @"endTime": @"creationTimeRange.endDate",
        @"commentCount": @"comments.count",
        @"commentsArray": @"comments.results",
        @"commentsCursor": @"comments.cursor",
        @"views": @"views.count",
        @"likeCount": @"likes.count",
        @"coverUrlString": @"mediaUrls.images.480px",
        @"hlsUrlString": @"mediaUrls.playlists.live.master",
        @"archivedUrlString": @"mediaUrls.playlists.replay.master",
        @"available": @"isAvailable",
        @"reply": @"isReply",
        @"replyCount": @"replies.count",
        @"lat": @"location.lat",
        @"lng": @"location.lng",
        @"placeResult": @"location.place",
        @"targetVideoId": @"targetVideo",
        @"shareUrlString": NSNull.null,
        @"likesCursor": NSNull.null,
        @"likesArray": NSNull.null,
    }];
}

+ (NSDictionary*)encodingBehaviorsByPropertyKey {
    NSSet *setToRemove = [NSSet setWithObjects:@"creator", @"commentsCursor", @"commentsArray", @"likesCursor", @"likesArray", @"commentCount", @"viewCount", @"likeCount", @"score", @"coordinate", nil];
    return [[super encodingBehaviorsByPropertyKey] mtl_dictionaryByRemovingEntriesWithKeys:setToRemove];
}

+ (NSValueTransformer*)creatorUserResultJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSDictionary *dictionary) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            return [MTLJSONAdapter modelOfClass:PUserResult.class fromJSONDictionary:dictionary error:nil];
        }else {
            return nil;
        }
    } reverseBlock:^NSDictionary * (PUserResult *userResult) {
        if ([userResult isKindOfClass:[PUserResult class]]) {
            return [MTLJSONAdapter JSONDictionaryFromModel:userResult];
        }else {
            return nil;
        }
    }];
}

+ (NSValueTransformer*)commentsArrayJSONTransformer {
    /**
     *  Forward transformer should convert each NSDictionary to a PComment
     *  Reverse transformer does not send comments back over the network
     */
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSMutableArray* (NSArray *commentsJSONArray) {
        NSMutableArray *commentsArray = [NSMutableArray array];
        for (NSDictionary *commentJSON in commentsJSONArray) {
            PCommentResult *result = [MTLJSONAdapter modelOfClass:PCommentResult.class fromJSONDictionary:commentJSON error:nil];
            [commentsArray addObject:result.comment];
        }
        
        return [NSMutableArray arrayWithArray:[commentsArray sortedArray]];
    } reverseBlock:^id (NSMutableArray *array) {
        return nil;
    }];
}

+ (NSValueTransformer*)placeResultJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id (NSDictionary *dictionary) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            return [MTLJSONAdapter modelOfClass:PPlaceResult.class fromJSONDictionary:dictionary error:nil];
        }else {
            return nil;
        }
    } reverseBlock:^NSDictionary * (PPlaceResult *placeResult) {
        if (placeResult) {
            return [MTLJSONAdapter JSONDictionaryFromModel:placeResult];
        }else {
            return nil;
        }
    }];
}

+ (NSValueTransformer*)startTimeJSONTransformer {
    return [PVideo dateTransformer];
}

+ (NSValueTransformer*)endTimeJSONTransformer {
    return [PVideo dateTransformer];
}

+ (instancetype)videoWithTitle:(NSString *)title location:(CLLocationCoordinate2D)location {
    PVideo *video = [PVideo object];
    video.title = title;
    video.lat = location.latitude;
    video.lng = location.longitude;
    
    return video;
}

- (void)mergePlaceResultFromModel:(MTLModel*)model {
    PVideo *video = (PVideo*)model;
    
    if (!video.placeResult) {
        return;
    }else if (video.placeResult && !self.placeResult) {
        self.placeResult = video.placeResult;
    }
}

- (void)mergeCreatorUserFromModel:(MTLModel*)model {
    PVideo *video = (PVideo*)model;
    
    if (!video.creatorUserResult) {
        return;
    }else if (video.creatorUserResult && !self.creatorUserResult) {
        self.creatorUserResult = video.creatorUserResult;
    }
}

- (void)mergeLatFromModel:(MTLModel*)model {
    PVideo *video = (PVideo*)model;
    
    if (!video.lat) {
        return;
    }else {
        self.lat = video.lat;
    }
}

- (void)mergeLngFromModel:(MTLModel*)model {
    PVideo *video = (PVideo*)model;
    
    if (!video.lng) {
        return;
    }else {
        self.lng = video.lng;
    }
}

- (void)mergeEndTimeFromModel:(MTLModel*)model {
    PVideo *video = (PVideo*)model;
    
    if (!video.endTime) {
        return;
    }else if (video.endTime) {
        _endTime = video.endTime;
    }
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        _startTime = [NSDate date];
    }
    
    return self;
}

#pragma mark - Accessors/Mutators
#pragma mark Accessors

- (BOOL)isLive {
    return !_endTime;
}

- (BOOL)isTitleValid {
    return !(!self.title || [self.title isEqual:@"No title"] || [self.title isEqual:@""]);
}

- (NSString*)title {
    if (!_title) {
        _title = @"";
    }
    
    return _title;
}

- (NSString*)shareUrlString {
    return [NSString stringWithFormat:@"http://www.present.tv/%@/p/%@", self.creatorUserResult.user.username, self._id];
}

- (NSURL*)watchURL {
    return (self.isLive) ? self.hlsURL : self.archivedURL;
}

- (NSURL*)archivedURL {
    return [NSURL URLWithString:self.archivedUrlString];
}

- (NSURL*)hlsURL {
    return [NSURL URLWithString:self.hlsUrlString];
}

- (NSURL*)coverURL {
    return [NSURL URLWithString:self.coverUrlString];
}

- (NSArray*)mostRecentComments {
    static NSInteger const kMostRecentCommentsToDisplay = 4;
    
    if (_commentsArray.count == 0) {
        return nil;
    }
    
    NSInteger start = 0;
    NSInteger length = 0;
    if (_commentsArray.count > 0 && _commentsArray.count < kMostRecentCommentsToDisplay) {
        length = _commentsArray.count;
    }else {
        start = _commentsArray.count - kMostRecentCommentsToDisplay;
        length = kMostRecentCommentsToDisplay;
    }
    
    return [[_commentsArray subarrayWithRange:NSMakeRange(start, length)] sortedArray];
}

- (PUser*)creatorUser {
    return self.creatorUserResult.user;
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.lat, self.lng);
}

- (NSMutableArray*)commentsArray {
    if (!_commentsArray) {
        _commentsArray = [NSMutableArray array];
    }
    
    return _commentsArray;
}

- (NSMutableArray*)likesArray {
    if (!_likesArray) {
        _likesArray = [NSMutableArray array];
    }
    
    return _likesArray;
}

#pragma mark Mutators

- (void)toggleLike {
    [PUser currentUser].likes.to(self) ? [self deleteLike] : [self createLike];
}

- (void)createLike {
    [self willChangeValueForKey:@"likeCount"];
    self.likeCount++;
    [self didChangeValueForKey:@"likeCount"];

    [PLike createLikeForVideo:self
                      success:nil
                      failure:nil];
    
    [PUser currentUser].likes.setForward(self, YES);
    
    if ([PUser currentUser].externalServices.facebook.shareLikes) {
        [self likeOnFacebook];
    }
}

- (void)deleteLike {
    [self willChangeValueForKey:@"likeCount"];
    self.likeCount--;
    [self didChangeValueForKey:@"likeCount"];
    
    [PLike deleteLikeForVideo:self
                      success:nil
                      failure:nil];
    
    [PUser currentUser].likes.setForward(self, NO);
}

- (void)createView {
    [PView createViewForVideo:self
                      success:nil
                      failure:nil];
}

/**
 *  Adds a comment
 *
 *  @param comment The comment to add
 */
- (void)addComment:(PComment *)comment {
    if (![self.commentsArray containsObject:comment]) {
        [self.commentsArray addObject:comment];
        
        [self willChangeValueForKey:@"commentCount"];
        self.commentCount++;
        [self didChangeValueForKey:@"commentCount"];
    }
}

/**
 *  Deletes a comment
 *
 *  @param commentToDelete The comment to delete
 */
- (void)deleteComment:(PComment*)commentToDelete {
    [self.commentsArray removeObject:commentToDelete];
    
    [PComment deleteComment:commentToDelete success:nil failure:nil];
    
    [self willChangeValueForKey:@"commentCount"];
    self.commentCount--;
    [self didChangeValueForKey:@"commentCount"];
}

- (void)end {
    _endTime = [NSDate date];
}

@end

#pragma mark - Social Interaction

@implementation PVideo (Social)

- (NSURL*)shareUrl {
    return (self.isNew) ? nil : [NSURL URLWithString:self.shareUrlString];
}

- (NSString*)openGraphObjectKey {
    return @"present";
}

- (NSMutableDictionary<FBOpenGraphObject>*)openGraphObject {
    // TODO: Move the NSString class method to a category
    return [FBGraphObject openGraphObjectForPostWithType:[NSString stringWithFormat:@"presenttv:%@", [self openGraphObjectKey]]
                                                   title:self.titleString
                                                   image:self.coverUrlString
                                                     url:self.shareUrl.absoluteString
                                             description:@""];
}

- (void)shareToFacebook {
    [PSocialManager showComposeControllerForAccountType:PSocialAccountTypeIdentifierFacebook
                                            withMessage:self.twitterShareString
                                                    url:self.shareUrl
                                                success:nil
                                                failure:nil];
}

- (void)postToFacebook {
    [PSocialManager postObjectToFacebook:self withAction:PFacebookShareActionVideoPost];
}

- (void)likeOnFacebook {
    [PSocialManager postObjectToFacebook:self withAction:PFacebookShareActionVideoLike];
}

- (void)shareToTwitter {
    [PSocialManager showComposeControllerForAccountType:PSocialAccountTypeIdentifierTwitter
                                            withMessage:self.twitterShareString
                                                    url:self.shareUrl
                                                success:nil
                                                failure:nil];
}

- (void)postToTwitter {
    [PSocialManager postObjectToTwitter:self withAction:PTwitterShareActionPost];
}

- (NSString*)titleString {
    return (self.isTitleValid) ? [NSString stringWithFormat:@"\"%@\"", self.title] : @"something";
}

- (NSString*)twitterShareString {
    return [NSString stringWithFormat:@"Check out %@ I found on Present! %@", self.titleString, self.shareUrl.absoluteString];
}

- (NSString*)twitterPostString {
    return [NSString stringWithFormat:@"I just started sharing %@ live on Present! %@", self.titleString, self.shareUrl.absoluteString];
}

- (NSString*)textMessageBody {
    return [NSString stringWithFormat:@"Hey, you should check out %@ on Present! %@", self.titleString, self.shareUrl.absoluteString];
}

- (NSString*)emailSubject {
    return @"You should check out this video from Present";
}

- (NSString*)emailBody {
    return [NSString stringWithFormat:@"I found this on Present and thought you might enjoy it. %@", self.shareUrl.absoluteString];
}

@end
