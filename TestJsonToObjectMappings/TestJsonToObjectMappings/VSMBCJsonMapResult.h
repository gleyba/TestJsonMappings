//
//  VSMBCJsonMapResult.h
//  TestJsonToObjectMappings
//
//  Created by Gleb Kolobkov on 17/04/2017.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, VSMBCJsonMapErrorTypes) {
    VSMBCJsonMapErrorInvalidData = 1,
    VSMBCJsonMapErrorNilInput = 2,
    VSMBCJsonMapErrorInvalidInput = 3,
    VSMBCJsonMapErrorNoRootSpecified = 4
};

@interface VSMBCJsonMapResult : NSObject

- (id)init;
- (id)initWithError:(NSError*) error;

+ (instancetype) resultWithError:(NSError*) error;

+ (instancetype)resultErrorBadJSON;
+ (instancetype)resultErrorInputIsNil;
+ (instancetype)resultErrorInputInvalidInput;
+ (instancetype)resultErrorNoRootSpecified;

@property(nonatomic,strong) NSError* error;


@end
