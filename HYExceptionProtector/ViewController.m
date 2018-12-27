//
//  ViewController.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/10/22.
//  Copyright © 2018年 张鸿运. All rights reserved.
//

#import "ViewController.h"
#import "HYExceptionProtector/HYExcepitionProtector.h"
#import <objc/runtime.h>

#import "Person.h"
#import "HYView.h"

@interface ViewController ()
@property (nonatomic, strong) Person *per;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[HYExcepitionProtector shareInstance] configAllProtectTypes];
    [[HYExcepitionProtector shareInstance] startProtection];
    
    NSArray *array = [self findAllOf:[NSDictionary class]];
    NSLog(@"array = %@",array);
    
    _per = [[Person alloc] init];
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1
//                                                      target:_per
//                                                    selector:@selector(timeTest)
//                                                    userInfo:nil
//                                                     repeats:YES];
//    [timer fire];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    // 测试数组崩溃事件
    // [self testArray];
    
    // 测试字典崩溃事件
    // [self testDict];
    
    // 测试在子线程刷新试图
    // [self testView];
    
    // 测试未实现方法
    // [self testUnrecognizedSelector];
    
    // 测试KVO
    // [self testKVO];
    // _per.name = @"hello";
    // [_per removeObserver:self forKeyPath:@"name"];
    
    _per = nil;
    NSLog(@"%@", _per);
    
    
    NSMutableSet *mSet = [NSMutableSet setWithObject:@"1"];
//    [mSet addObject:nil];
//    [mSet removeObject:nil];

    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    NSLog(@"%@",keyPath);
}

- (void)testArray
{
    NSArray *arr00 = [[NSArray alloc] init];
    NSArray *arr01 = [[NSArray alloc] initWithObjects:@"1", nil];
    NSArray *arr02 = [[NSArray alloc] initWithObjects:@"1", nil];
    NSArray *arr03 = [[NSArray alloc] initWithObjects:@"1", @"2", nil];
    NSArray *arr04 = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", nil];
    
    NSArray *arr05 = @[];
    NSArray *arr06 = @[@"1"];
    NSArray *arr07 = @[@"1",@"2",];
    NSArray *arr08 = @[@"1",@"2",@"3"];
    
    NSArray *arr09 = [NSArray arrayWithArray:arr01];
    
    NSLog(@"arr00 = %@",[arr00 class]);
    NSLog(@"arr01 = %@",[arr01 class]);
    NSLog(@"arr02 = %@",[arr02 class]);
    NSLog(@"arr03 = %@",[arr03 class]);
    NSLog(@"arr04 = %@",[arr04 class]);
    NSLog(@"arr05 = %@",[arr05 class]);
    NSLog(@"arr06 = %@",[arr06 class]);
    NSLog(@"arr07 = %@",[arr07 class]);
    NSLog(@"arr08 = %@",[arr08 class]);
    NSLog(@"arr09 = %@",[arr09 class]);
    
    
    [arr01 objectAtIndex:4];
    [arr02 subarrayWithRange:NSMakeRange(1, 2)];
    [arr03 objectAtIndex:4];
    [arr04 objectAtIndex:4];
}


- (void)testDict
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    [dictionary setObject:@"1" forKey:@"11"];
    [dictionary removeObjectForKey:nil];
    NSDictionary *dic = [[NSDictionary alloc] initWithObjects:@[@"1"] forKeys:@[]];
}

- (void)testView
{
    HYView *view = [[HYView alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [view setNeedsDisplay];
        
    });
}

- (void)testUnrecognizedSelector
{
    Person *p = [Person new];
    [p eat];
}

- (void)testKVO
{
    _per = [[Person alloc] init];
    [_per addObserver:self
           forKeyPath:@"name"
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    [_per addObserver:self
           forKeyPath:@"name"
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    [_per addObserver:self
           forKeyPath:@"name"
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    [_per addObserver:self
           forKeyPath:@"name"
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    [_per addObserver:self
           forKeyPath:@"name"
              options:NSKeyValueObservingOptionNew
              context:nil];
}

- (NSArray *)findAllOf:(Class)defaultClass
{
    int count = objc_getClassList(NULL, 0);

    if (count <= 0) {
        
        @throw @"Couldn't retrieve Obj-C class-list";
        
        return @[defaultClass];
    }
    
    NSMutableArray *output = @[].mutableCopy;
    
    Class *classes = (Class *) malloc(sizeof(Class) * count);
    
    objc_getClassList(classes, count);
    
    for (int i = 0; i < count; ++i) {
        
        if (defaultClass == class_getSuperclass(classes[i])) {
            
            [output addObject:classes[i]];
        }
        
    }
    
    free(classes);
    
    return output.copy;
    
}

@end
