//
//  VSMBCDataModel.m
//  TestJsonToObjectMappings
//
//  Created by Gleb Kolobkov on 18/04/2017.
//
//

#import "VSMBCDataModel.h"

@implementation VSMBCDataModel

+ (Class) vsmbcRootClass {
    return self;
}

+ (NSString*) vsmbcIndexPropertyName {
    return @"vsmbcIndex";
}
@end
