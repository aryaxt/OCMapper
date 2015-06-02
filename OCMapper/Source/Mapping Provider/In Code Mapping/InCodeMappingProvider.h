//
//  InCodeMappintProvider.h
//  OCMapper
//
//  Created by Aryan Gh on 4/20/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//
// https://github.com/aryaxt/OCMapper
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "MappingProvider.h"
#import "ObjectMappingInfo.h"

@interface InCodeMappingProvider : NSObject <MappingProvider>

/**
 *  Defaults to true, and if the value is true
 *  If true, for every dictionary-to-property mapping, it creates an inverse mapping
 *  So when a mapping is written to convert a dictionary key named "dob" to a property named "dateOfBirth"
 *  an inverse mapping is generated. Next time you convert that object to a dictionary, 
 *  the dictionary key would be named "dob",which is mapped from a property named "dateOfBirth"
 */
@property (nonatomic, assign) BOOL automaticallyGenerateInverseMapping;

/**
 *  Set key/property Mapping to be used for converting a dictionary to a model object
 *
 *  @param dictionaryKey NSString key in the dictionary
 *  @param propertyKey   NSString name of the property
 *  @param objectType    Class to be instantiated and assigned to property
 *  @param clazz         Class to be assign mapping to
 */
- (void)mapFromDictionaryKey:(NSString *)dictionaryKey toPropertyKey:(NSString *)propertyKey withObjectType:(Class)objectType forClass:(Class)clazz;

/**
 *  Set key/property Mapping to be used for converting a dictionary to a model object
 *
 *  @param dictionaryKey NSString key in the dictionary
 *  @param propertyKey   NSString name of the property
 *  @param clazz         Class to be assign mapping to
 *  @param transformer   Block to be used for transforming an item in dictionary into a desired result and assign to property
 */
- (void)mapFromDictionaryKey:(NSString *)dictionaryKey toPropertyKey:(NSString *)propertyKey forClass:(Class)clazz withTransformer:(MappingTransformer)transformer;

/**
 *  Set key/property Mapping to be used for converting a dictionary to a model object
 *
 *  @param dictionaryKey NSString key in the dictionary
 *  @param propertyKey   NSString name of the property
 *  @param clazz         Class to be assign mapping to
 */
- (void)mapFromDictionaryKey:(NSString *)dictionaryKey toPropertyKey:(NSString *)propertyKey forClass:(Class)clazz;

/**
 *  Set key/property Mapping to be used for converting a model object to dictionary
 *
 *  @param dictionaryKey NSString key in the dictionary
 *  @param propertyKey   NSString name of the property
 *  @param clazz         Class to be assign mapping to
 */
- (void)mapFromPropertyKey:(NSString *)propertyKey toDictionaryKey:(NSString *)dictionaryKey forClass:(Class)clazz;

/**
 *  Set key/property Mapping to be used for converting a model object to dictionary
 *
 *  @param dictionaryKey NSString key in the dictionary
 *  @param propertyKey   NSString name of the property
 *  @param clazz         Class to be assign mapping to
 *  @param transformer   Block to be used for transforming an item in dictionary into a desired result and assign to property
 */
- (void)mapFromPropertyKey:(NSString *)propertyKey toDictionaryKey:(NSString *)dictionaryKey forClass:(Class)clazz withTransformer:(MappingTransformer)transformer;

/**
 *  Set keys to be excluded when mapping model to a dictionary
 *
 *  @param clazz        Class to be assign mapping to
 *  @param keys         NSArray of NSStrings, include properties to be excluded when mapping
 */
- (void)excludeMappingForClass:(Class)clazz withKeys:(NSArray *)keys;

/**
 *  Set dateformatter to be used for converting a dictionary to a model object
 *
 *  @param dateFormatter NSDateFormatter a dateformatter
 *  @param propertyKey   NSString name of the property
 *  @param clazz         Class to be assign mapping to
 */
- (void)setDateFormatter:(NSDateFormatter *)dateFormatter forPropertyKey:(NSString *)propertyKey andClass:(Class)clazz;

/**
 *  Set dateformatter to be used for converting a model object to a dictionary
 *
 *  @param dateFormatter NSDateFormatter a dateformatter
 *  @param propertyKey   NSString name of the property
 *  @param clazz         Class to be assign mapping to
 */
- (void)setDateFormatter:(NSDateFormatter *)dateFormatter forDictionaryKey:(NSString *)dictionaryKey andClass:(Class)clazz;

@end
