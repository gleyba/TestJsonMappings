//
//  VSMBCDataModel.h
//  TestJsonToObjectMappings
//
//  Created by Gleb Kolobkov on 18/04/2017.
//
//

#import <Foundation/Foundation.h>

@interface VSMBCDataModel : NSObject

@property(nonatomic,strong) NSString* vsmbcIndex;

+ (Class) vsmbcRootClass;
+ (NSString*) vsmbcIndexPropertyName;

@end
