//
//  HondaDataItem.h
//  Honda[SmartCare]
//
//  Created by Tran Trung Hieu on 1/2/16.
//  Copyright © 2016 3SI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HondaDataItem : NSObject
@property (copy, nonatomic) NSString *objectId;
@property (copy, nonatomic) NSString *nameItem;
@property (copy, nonatomic) NSString *groudAccessary;
@property (copy, nonatomic) NSString *imageURL;
@property (copy, nonatomic) NSString *descriptionDetail;
@property (copy, nonatomic) NSString *starDate;
@property (copy, nonatomic) NSString *endDate;
@property (nonatomic)       NSInteger fixedPrice;
@property (nonatomic)       NSInteger renewPrice;
@end
