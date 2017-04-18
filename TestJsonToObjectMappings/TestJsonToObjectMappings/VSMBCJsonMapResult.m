//
//  VSMBCJsonMapResult.m
//  TestJsonToObjectMappings
//
//  Created by Gleb Kolobkov on 17/04/2017.
//
//

#import "VSMBCJsonMapResult.h"

NSString* const VSMBCJsonMapErrorDomain = @"JSONModelErrorDomain";

@implementation VSMBCJsonMapResult

- (id)init {
     if (self = [super init])  {
     
     }
     return self;
}

- (id)initWithError:(NSError*) error {
    if (self = [super init])  {
        self.error = error;
    }
    return self;
}

+ (instancetype) resultWithError:(NSError*) error {
    return [[self alloc] initWithError:error];
}


+ (instancetype)resultErrorBadJSON {
    id error = [NSError errorWithDomain:VSMBCJsonMapErrorDomain
                                   code:VSMBCJsonMapErrorInvalidData
                               userInfo:@{NSLocalizedDescriptionKey:@"Malformed JSON. Check the data input."}];
    return [self resultWithError:error];
}

+ (instancetype)resultErrorInputIsNil {
    id error = [NSError errorWithDomain:VSMBCJsonMapErrorDomain
                                   code:VSMBCJsonMapErrorNilInput
                               userInfo:@{NSLocalizedDescriptionKey:@"Initializing model with nil input object."}];
    return [self resultWithError:error];
}

+ (instancetype)resultErrorInputInvalidInput {
    id error = [NSError errorWithDomain:VSMBCJsonMapErrorDomain
                                   code:VSMBCJsonMapErrorInvalidInput
                               userInfo:@{NSLocalizedDescriptionKey:@"Initializing model with invalid input data."}];
    return [self resultWithError:error];
}

+ (instancetype)resultErrorNoRootSpecified {
    id error = [NSError errorWithDomain:VSMBCJsonMapErrorDomain
                                   code:VSMBCJsonMapErrorNoRootSpecified
                               userInfo:@{NSLocalizedDescriptionKey:@"No root class for data model specified"}];
    return [self resultWithError:error];
}

@end
