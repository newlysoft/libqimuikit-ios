
//
//  QtalkPlugin.m
//  QIMUIKit
//
//  Created by 李露 on 11/13/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QtalkPlugin.h"
#import "QIMFastEntrance.h"
#import "QIMJSONSerializer.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>


@implementation QtalkPlugin

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(browseBigImage:(NSDictionary *)param :(RCTResponseSenderBlock)callback){
    [[QIMFastEntrance sharedInstance] browseBigHeader:param];
}

RCT_EXPORT_METHOD(openDownLoad:(NSDictionary *)param :(RCTResponseSenderBlock)callback){
    [[QIMFastEntrance sharedInstance] openQIMFilePreviewVCWithParam:param];
}

RCT_EXPORT_METHOD(openNativeWebView:(NSDictionary *)param) {
    if ([QIMFastEntrance handleOpsasppSchema:param] == NO) {
        NSString *linkUrl = [param objectForKey:@"linkurl"];
        if (linkUrl.length > 0) {
            [QIMFastEntrance openWebViewForUrl:linkUrl showNavBar:YES];
        }
    } else {

    }
}

RCT_EXPORT_METHOD(getWorkWorldItem:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSDictionary *momentDic = [[QIMKit sharedInstance] getLastWorkMoment];
    NSLog(@"getWorkWorldItem : %@", momentDic);
    callback(@[momentDic ? momentDic : @{}]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[QIMKit sharedInstance] getRemoteLastWorkMoment];
    });
}

RCT_EXPORT_METHOD(getWorkWorldNotRead:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSInteger notReadMsgCount = [[QIMKit sharedInstance] getWorkNoticeMessagesCount];
    BOOL showNewPOST = NO;
    NSLog(@"getWorkWorldNotRead : %d", notReadMsgCount);
    NSDictionary *notReadMsgDic = @{@"notReadMsgCount":@(notReadMsgCount), @"showNewPost":@(showNewPOST)};
    callback(@[notReadMsgDic ? notReadMsgDic : @{}]);
}

RCT_EXPORT_METHOD(openWorkWorld:(NSDictionary *)param) {
    [[QIMFastEntrance sharedInstance] openWorkFeedViewController];
}

//打开笔记本
RCT_EXPORT_METHOD(openNoteBook:(NSDictionary *)param) {
    [QIMFastEntrance openQTalkNotesVC];
}

//打开文件助手
RCT_EXPORT_METHOD(openFileTransfer:(NSDictionary *)param) {
    [[QIMFastEntrance sharedInstance] openFileTransMiddleVC];
}

//打开行程
RCT_EXPORT_METHOD(openScan:(NSDictionary *)param) {
    [QIMFastEntrance openQRCodeVC];
}

//获取发现页应用列表
RCT_EXPORT_METHOD(getFoundInfo:(RCTResponseSenderBlock)callback) {
    NSString *foundListStr = [[QIMKit sharedInstance] getLocalFoundNavigation];
    NSArray *foundList = [[QIMJSONSerializer sharedInstance] deserializeObject:foundListStr error:nil];
    NSMutableArray *mutableGroupItems = [NSMutableArray arrayWithCapacity:3];
    NSMutableDictionary *mutableResult = [NSMutableDictionary dictionaryWithCapacity:1];
    
    for (NSDictionary *groupItemDic in foundList) {
        
        NSMutableDictionary *newGroupDic = [NSMutableDictionary dictionaryWithCapacity:2];
        
        NSInteger groupId = [[groupItemDic objectForKey:@"groupId"] integerValue];
        NSString *groupName = [groupItemDic objectForKey:@"groupName"];
        NSString *groupIcon = [groupItemDic objectForKey:@"groupIcon"];
        NSArray *groupItems = [groupItemDic objectForKey:@"members"];
        
        [newGroupDic setObject:@(groupId) forKey:@"groupId"];
        [newGroupDic setObject:groupName forKey:@"groupName"];
        [newGroupDic setObject:groupIcon forKey:@"groupIcon"];

        
        NSMutableArray *newGroupItems = [NSMutableArray arrayWithCapacity:3];
        if ([groupItems isKindOfClass:[NSArray class]]) {
            for (NSDictionary *childItemDic in groupItems) {
                NSInteger appType = [[childItemDic objectForKey:@"appType"] integerValue];
                NSString *bundle = [childItemDic objectForKey:@"bundle"];
                NSString *bundleUrls = [childItemDic objectForKey:@"bundleUrls"];
                NSString *entrance = [childItemDic objectForKey:@"entrance"];
                NSString *memberAction = [childItemDic objectForKey:@"memberAction"];
                NSString *memberIcon = [childItemDic objectForKey:@"memberIcon"];
                NSInteger memberId = [childItemDic objectForKey:@"memberId"];
                NSString *memberName = [childItemDic objectForKey:@"memberName"];
                NSString *module = [childItemDic objectForKey:@"module"];
                NSString *navTitle = [childItemDic objectForKey:@"navTitle"];
                NSString *properties = [childItemDic objectForKey:@"properties"];
                BOOL showNativeNav = [[childItemDic objectForKey:@"showNativeNav"] boolValue];
                
                NSMutableDictionary *newChildItemDic = [NSMutableDictionary dictionaryWithCapacity:3];
                [newChildItemDic setObject:[NSString stringWithFormat:@"%ld", appType] forKey:@"AppType"];
                [newChildItemDic setObject:bundle forKey:@"Bundle"];
                [newChildItemDic setObject:bundleUrls forKey:@"BundleUrls"];
                [newChildItemDic setObject:entrance forKey:@"Entrance"];
                [newChildItemDic setObject:memberAction forKey:@"memberAction"];
                [newChildItemDic setObject:memberIcon forKey:@"memberIcon"];
                [newChildItemDic setObject:@(memberId) forKey:@"memberId"];
                [newChildItemDic setObject:memberName forKey:@"memberName"];
                [newChildItemDic setObject:module forKey:@"Module"];
                [newChildItemDic setObject:navTitle forKey:@"navTitle"];
                [newChildItemDic setObject:properties forKey:@"appParams"];
                [newChildItemDic setObject:@(showNativeNav) forKey:@"showNativeNav"];
                
                [newGroupItems addObject:newChildItemDic];
            }
            [newGroupDic setObject:newGroupItems forKey:@"members"];
            [mutableGroupItems addObject:newGroupDic];
        }
        [mutableResult setObject:@(YES) forKey:@"isOk"];
        [mutableResult setObject:mutableGroupItems forKey:@"data"];
    }
    callback(@[mutableResult ? mutableResult : @{}]);

    NSLog(@"foundList : %@", foundListStr);
}

@end
