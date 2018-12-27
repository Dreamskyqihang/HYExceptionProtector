//
//  Person.h
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/19.
//  Copyright © 2018 张鸿运. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PersonDelegate <NSObject>

- (void)eat;

@end

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;

- (void)eat;

- (void)timeTest;

@end

NS_ASSUME_NONNULL_END
