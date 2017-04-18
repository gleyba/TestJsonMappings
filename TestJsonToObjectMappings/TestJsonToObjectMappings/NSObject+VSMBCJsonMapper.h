//
//  NSObject+VSMBCJsonMapper.h
//  TestJsonToObjectMappings
//
//  Created by Gleb Kolobkov on 17/04/2017.
//
//

#import <Foundation/Foundation.h>

#import <VSMBCJsonMapResult.h>

@interface NSObject (VSMBCJsonMapper)

- (VSMBCJsonMapResult*) vsmbc_bindJsonFromDictionary:(NSDictionary *)dict;
- (VSMBCJsonMapResult*) vsmbc_bindJsonFromData:(NSData *) data;
- (VSMBCJsonMapResult*) vsmbc_bindJsonFromString:(NSString*) jsonStr;


@end
