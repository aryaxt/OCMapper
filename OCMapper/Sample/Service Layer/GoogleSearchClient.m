//
//  GoogleSearchClient.m
//  OCMapper
//
//  Created by Aryan Gh on 8/27/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "GoogleSearchClient.h"

@implementation GoogleSearchClient

- (void)searchWithKeyword:(NSString *)keyword andCompletion:(void (^)(GoogleSearchResponse *googleSearchResponse, NSError *error))completion
{
	ServiceClient *client = [[ServiceClient alloc] init];
	
	[client fetchDataWithUrl:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=%@", keyword]
				  returnType:[GoogleSearchResponse class]
			   andCompletion:completion];
}

// Here is the response sample coming back from google

/*
 {
 "responseData":{
 "results":[
 {
 "GsearchResultClass":"GwebSearch",
 "unescapedUrl":"https://github.com/aryaxt/OCMapper",
 "url":"https://github.com/aryaxt/OCMapper",
 "visibleUrl":"github.com",
 "cacheUrl":"http://www.google.com/search?q\u003dcache:-pDMwfW87-gJ:github.com",
 "title":"aryaxt/\u003cb\u003eOCMapper\u003c/b\u003e · GitHub",
 "titleNoFormatting":"aryaxt/OCMapper · GitHub",
 "content":"\u003cb\u003eOCMapper\u003c/b\u003e - Objective C library to easily map NSDictionary to model objects."
 },
 {
 "GsearchResultClass":"GwebSearch",
 "unescapedUrl":"https://github.com/aryaxt",
 "url":"https://github.com/aryaxt",
 "visibleUrl":"github.com",
 "cacheUrl":"http://www.google.com/search?q\u003dcache:5kvhg3jeR2YJ:github.com",
 "title":"aryaxt (Aryan Ghassemi) · GitHub",
 "titleNoFormatting":"aryaxt (Aryan Ghassemi) · GitHub",
 "content":"Similar to Path and Facebook · \u003cb\u003eOCMapper\u003c/b\u003e 4 Objective C library to easily map   NSDictionary to model objects · OCInjection 3 Dependency Injection framework   for \u003cb\u003e...\u003c/b\u003e"
 },
 {
 "GsearchResultClass":"GwebSearch",
 "unescapedUrl":"http://ocgis1.ocfl.net/",
 "url":"http://ocgis1.ocfl.net/",
 "visibleUrl":"ocgis1.ocfl.net",
 "cacheUrl":"http://www.google.com/search?q\u003dcache:bkUKnExJ6pwJ:ocgis1.ocfl.net",
 "title":"Orange County InfoMap Public",
 "titleNoFormatting":"Orange County InfoMap Public",
 "content":"Choose to either save the project on the server or download and save the project   to your computer. Save to ServerSave to My Computer \u003cb\u003e...\u003c/b\u003e"
 },
 {
 "GsearchResultClass":"GwebSearch",
 "unescapedUrl":"http://stackoverflow.com/questions/17268293/objective-c-runtime-built-in-classes-vs-custom-classes",
 "url":"http://stackoverflow.com/questions/17268293/objective-c-runtime-built-in-classes-vs-custom-classes",
 "visibleUrl":"stackoverflow.com",
 "cacheUrl":"http://www.google.com/search?q\u003dcache:CXrwgryjcREJ:stackoverflow.com",
 "title":"Objective C Runtime - Built-in classes vs custom \u003cb\u003e...\u003c/b\u003e - Stack Overflow",
 "titleNoFormatting":"Objective C Runtime - Built-in classes vs custom ... - Stack Overflow",
 "content":"\u003cb\u003e...\u003c/b\u003e and there is a warning in the code related to the piece i posted here on line 87.   github.com/aryaxt/\u003cb\u003eOCMapper\u003c/b\u003e/blob/master/\u003cb\u003eOCMapper\u003c/b\u003e/Source/ \u003cb\u003e...\u003c/b\u003e"
 }
 ],
 "cursor":{
 "resultCount":"6",
 "pages":[
 {
 "start":"0",
 "label":1
 },
 {
 "start":"4",
 "label":2
 }
 ],
 "estimatedResultCount":"6",
 "currentPageIndex":0,
 "moreResultsUrl":"http://www.google.com/search?oe\u003dutf8\u0026ie\u003dutf8\u0026source\u003duds\u0026start\u003d0\u0026hl\u003den\u0026q\u003dOCMapper",
 "searchResultTime":"0.10"
 }
 },
 "responseDetails":null,
 "responseStatus":200
 }
 */

@end
