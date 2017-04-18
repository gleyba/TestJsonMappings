//
//  VSMBCModelClassProperty.h
//  TestJsonToObjectMappings
//
//  Created by Gleb Kolobkov on 18/04/2017.
//
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


@interface VSMBCModelClassProperty : NSObject

/** The name of the declared property (not the ivar name) */
@property (copy, nonatomic) NSString *name;

/** A property class type  */
@property (assign, nonatomic) Class type;

/** Struct name if a struct */
@property (strong, nonatomic) NSString *structName;

/** The name of the protocol the property conforms to (or nil) */
//@property (copy, nonatomic) NSString *protocol;

/** If YES, it can be missing in the input data, and the input would be still valid */
//@property (assign, nonatomic) BOOL isOptional;

/** If YES - don't call any transformers on this property's value */
@property (assign, nonatomic) BOOL isStandardJSONType;

/** If YES - create a mutable object for the value of the property */
@property (assign, nonatomic) BOOL isMutable;

/** a custom getter for this property, found in the owning model */
@property (assign, nonatomic) SEL customGetter;

/** custom setters for this property, found in the owning model */
@property (strong, nonatomic) NSMutableDictionary *customSetters;
@end
