//
//  NSObject+JsonMapper.m
//  TestJsonToObjectMappings
//
//  Created by Gleb Kolobkov on 17/04/2017.
//
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "EXTScope.h"

#import "NSObject+VSMBCJsonMapper.h"
#import "VSMBCKeyMapper.h"

static const void * sKeyMapperObject = &sKeyMapperObject;
static const void * sPropertiesObject = &sPropertiesObject;

static NSArray* sAllowedJSONTypes = @[
    [NSString class],
    [NSNumber class],
    [NSDecimalNumber class],
    [NSArray class], 
    [NSDictionary class],
    [NSNull class], //immutable JSON classes
    [NSMutableString class],
    [NSMutableArray class],
    [NSMutableDictionary class] //mutable JSON classes
];


@implementation NSObject (VSMBCJsonMapper)


+ (Class) vsmbc_inspectRootClass {
    Class result = nil;
    
    SEL rootClassSelector = NSSelectorFromString(@"vsmbcRootClass");
    if ([self instancesRespondToSelector:rootClassSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        result = [self performSelector:rootClassSelector];
#pragma clang diagnostic pop
    }

    return result;
}

+ (NSDictionary<NSString*,VSMBCModelClassProperty*>*) vsmbc_parseProperties {
    NSMutableDictionary<NSString*,VSMBCModelClassProperty*>* properties = [NSMutableDictionary dictionary];
    
    Class currentClass = self.class;
    Class rootClass = [self.class vsmbc_inspectRootClass];
    
    NSScanner* scanner = nil;
    NSString* propertyType = nil;
    
    do {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);
        onExit{
            free(properties);
        };
        
        //loop over the class properties
        for (unsigned int i = 0; i < propertyCount; i++) {
            
            objc_property_t property = properties[i];
            
            //get property attributes
            NSString* propertyAttributes = @(property_getAttributes(property));
            NSArray* attributeItems = [propertyAttributes componentsSeparatedByString:@","];
            
            //ignore read-only properties
            if ([attributeItems containsObject:@"R"]) {
                continue; //to next property
            }
            
            auto* p = [[VSMBCModelClassProperty alloc] init];
            p.name = @(property_getName(property));
            
            scanner = [NSScanner scannerWithString: propertyAttributes];

            [scanner scanUpToString:@"T" intoString: nil];
            [scanner scanString:@"T" intoString:nil];
        

            //check if the property is an instance of a class
            if ([scanner scanString:@"@\"" intoString: &propertyType]) {

                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                        intoString:&propertyType];

                //JMLog(@"type: %@", propertyClassName);
                p.type = NSClassFromString(propertyType);
                p.isMutable = ([propertyType rangeOfString:@"Mutable"].location != NSNotFound);
                p.isStandardJSONType = [sAllowedJSONTypes containsObject:p.type];

                //read through the property protocols
//                while ([scanner scanString:@"<" intoString:NULL]) {
//
//                    NSString* protocolName = nil;
//
//                    [scanner scanUpToString:@">" intoString: &protocolName];
//
//                    if ([protocolName isEqualToString:@"Optional"]) {
//                        p.isOptional = YES;
//                    } else if([protocolName isEqualToString:@"Index"]) {
//                        objc_setAssociatedObject(
//                                                 self.class,
//                                                 &kIndexPropertyNameKey,
//                                                 p.name,
//                                                 OBJC_ASSOCIATION_RETAIN // This is atomic
//                                                 );
//                    } else if([protocolName isEqualToString:@"Ignore"]) {
//                        p = nil;
//                    } else {
//                        p.protocol = protocolName;
//                    }
//
//                    [scanner scanString:@">" intoString:NULL];
//                }

            }
 //check if the property is a structure
            else if ([scanner scanString:@"{" intoString: &propertyType]) {
                [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
                                    intoString:&propertyType];

                p.isStandardJSONType = NO;
                p.structName = propertyType;

            }
            //the property must be a primitive
            else {

                //the property contains a primitive data type
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]
                                        intoString:&propertyType];

                //get the full name of the primitive type
                propertyType = valueTransformer.primitivesNames[propertyType];

                if (![allowedPrimitiveTypes containsObject:propertyType]) {

                    //type not allowed - programmer mistaken -> exception
                    @throw [NSException exceptionWithName:@"JSONModelProperty type not allowed"
                                                   reason:[NSString stringWithFormat:@"Property type of %@.%@ is not supported by JSONModel.", self.class, p.name]
                                                 userInfo:nil];
                }

            }

            NSString *nsPropertyName = @(propertyName);
            if([[self class] propertyIsOptional:nsPropertyName]){
                p.isOptional = YES;
            }

            if([[self class] propertyIsIgnored:nsPropertyName]){
                p = nil;
            }

            Class customClass = [[self class] classForCollectionProperty:nsPropertyName];
            if (customClass) {
                p.protocol = NSStringFromClass(customClass);
            }

            //few cases where JSONModel will ignore properties automatically
            if ([propertyType isEqualToString:@"Block"]) {
                p = nil;
            }

            //add the property object to the temp index
            if (p && ![propertyIndex objectForKey:p.name]) {
                [propertyIndex setValue:p forKey:p.name];
            }

            // generate custom setters and getter
            if (p)
            {
                NSString *name = [p.name stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[p.name substringToIndex:1].uppercaseString];

                // getter
                SEL getter = NSSelectorFromString([NSString stringWithFormat:@"JSONObjectFor%@", name]);

                if ([self respondsToSelector:getter])
                    p.customGetter = getter;

                // setters
                p.customSetters = [NSMutableDictionary new];

                SEL genericSetter = NSSelectorFromString([NSString stringWithFormat:@"set%@WithJSONObject:", name]);

                if ([self respondsToSelector:genericSetter])
                    p.customSetters[@"generic"] = [NSValue valueWithBytes:&genericSetter objCType:@encode(SEL)];

                for (Class type in allowedJSONTypes)
                {
                    NSString *class = NSStringFromClass([JSONValueTransformer classByResolvingClusterClasses:type]);

                    if (p.customSetters[class])
                        continue;

                    SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@With%@:", name, class]);

                    if ([self respondsToSelector:setter])
                        p.customSetters[class] = [NSValue valueWithBytes:&setter objCType:@encode(SEL)];
                }
            }
        }
    
        if (currentClass != rootClass) {
            currentClass = [rootClass superclass];
        }
    } while(currentClass != rootClass);

    return properties;
}

-(NSString*) vsmbc_indexPropertyName {
    //custom getter for an associated object
    return objc_getAssociatedObject(self.class, &kIndexPropertyNameKey);
}

+ (NSDictionary<NSString*,VSMBCModelClassProperty*>*) vsmbc_properties {
    NSDictionary<NSString*,VSMBCModelClassProperty*>* properties = objc_getAssociatedObject(self.class, &sPropertiesObject);
    if (properties != nil) return properties;
    
    @synchronized (self.class) {
        properties = objc_getAssociatedObject(self.class, &sPropertiesObject);
        if (properties != nil) return properties;
        
        properties = [self vsmbc_parseProperties];
        objc_setAssociatedObject(
            self.class,
            sPropertiesObject,
            properties,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );
    }
    
    return properties;
}


+ (VSMBCKeyMapper*) vsmbc_keyMapper {
    VSMBCKeyMapper* mapper = objc_getAssociatedObject(self.class, &sKeyMapperObject);
    if (mapper != nil) return mapper;
    
    @synchronized (self.class) {
        mapper = objc_getAssociatedObject(self.class, &sKeyMapperObject);
        if (mapper != nil) return mapper;
        
        mapper = [VSMBCKeyMapper mapperForClass:self root:[self vsmbc_inspectRootClass]];
        objc_setAssociatedObject(
            self.class,
            sKeyMapperObject,
            mapper,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );
    }
    
    return mapper;
}

- (VSMBCJsonMapResult*) vsmbc_bindJsonFromDictionary:(NSDictionary *)dict {
    if (!dict) {
        return [VSMBCJsonMapResult resultErrorInputIsNil];
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return [VSMBCJsonMapResult resultErrorInputInvalidInput];
    }
    if (![self.class vsmbc_inspectRootClass]) {
        return [VSMBCJsonMapResult resultErrorNoRootSpecified];
    }
    auto* keyMapper = [self vsmbc_keyMapper];

    return nil;
}

- (VSMBCJsonMapResult*) vsmbc_bindJsonFromData:(NSData *) data {
    if (!data) {
        return [VSMBCJsonMapResult resultErrorInputIsNil];
    }

    NSError* jsonSerializeError = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data
                                             options:kNilOptions
                                               error:&jsonSerializeError];
                                               
    if (jsonSerializeError) {
        return [VSMBCJsonMapResult resultErrorBadJSON];
    }
    
    return [self vsmbc_bindJsonFromDictionary:obj];
} 

- (VSMBCJsonMapResult*) vsmbc_bindJsonFromString:(NSString*) jsonStr {
    return [self vsmbc_bindJsonFromData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]];
}



@end
