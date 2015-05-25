//
//  ObjectMapper.h
//  OCMapper
//
//  Created by Aryan Gh on 4/14/13.
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

@protocol MappingProvider, LoggingProvider, InstanceProvider;

@interface ObjectMapper : NSObject

@property (nonatomic, strong) NSDateFormatter *defaultDateFormatter;
@property (nonatomic, strong) id <MappingProvider> mappingProvider;
@property (nonatomic, strong) id <LoggingProvider> loggingProvider;
@property (nonatomic, assign) BOOL normalizeDictionary;

+ (ObjectMapper *)sharedInstance;
- (id)objectFromSource:(id)source toInstanceOfClass:(Class)clazz;
- (id)dictionaryFromObject:(NSObject *)object;
- (void)addInstanceProvider:(id <InstanceProvider>)instanceProvider;

@end
