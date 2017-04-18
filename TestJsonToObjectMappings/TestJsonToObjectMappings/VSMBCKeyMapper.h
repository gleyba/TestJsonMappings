//
//  VSMBCKeyMapper.h
//  TestJsonToObjectMappings
//
//  Created by Gleb Kolobkov on 17/04/2017.
//
//

#import <Foundation/Foundation.h>

#import "VSMBCModelClassProperty.h"

@interface VSMBCKeyMapper : NSObject
+(instancetype) mapperForClass:(Class) clz 
                          root:(Class) root;
@end
