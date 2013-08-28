OC Mapper for Objective C
=========================

OCMapper is a data mapping library for Objective C that converts NSDictionary to NSObject. My inspiration behind writing OCMapper was to achieve two things:
- Simplify/Automate Data retrieval through web services
- Avoid adding parsing logic to model objects (I'm a big fan of separation of responsibilities!!!)

The end result I was looking for was a single method that would take a URL and a return type (object or array of objects), and just works doesn't matter what.
Take a look at the sample project for more info on how this is done.
```objective-c
ServiceClient *client = [[ServiceClient alloc] init];

// Getting back a single customer from service
[client fetchDataWithUrl:URL returnType:[Customer class] andCompletion:^(Customer *customer, NSError *error){
   // Do something with the object
}];

// Getting back a list of customers from service
[client fetchDataWithUrl:URL returnType:[Customer class] andCompletion:^(NSArray *customers, NSError *error){
   // Do something with the object
}];
```


Features:
-------------------------
- Supports array mapping
- Supports tree structure mapping
- Supports complex object nesting 
- Supports Core Data (NSManagedObjects)
- Mapping configuration can be done both in code or through a PLIST
- Auto detects key/values based on NSDictionary keys
- Fully Configurable
- Does not require subclassing or adding any extra code to your models
- Auto data conversion, and configurable DateFormatters


Examples
-------------------------
```objective-c
@interface User
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) NSDate *dateOfBirth;
@property (nonatomic, strong) NSDate *accountCreationDate;
@property (nonatomic, strong) Address *address;
@property (nonatomic, strong) NSMutableArray *posts;
@end

@interface Address
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@end

@interface Post
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) User *author;
@property (nonatomic, strong) NSDate *datePosted;
@end
```

Simple Automatic Mapping
-------------------------
```objective-c
{
   "firstName"   : "Aryan",
   "lastName"    : "Ghassemi",
   "age"         : 26,
   "dateOfBirth" : "01/01/2013"
}

User *user = [User objectFromDictionary:aDictionary];
```

Nested Automatic Mapping
-------------------------
In this case everything is mapped automaticly because all key/values are similar.
"address" will automatically convert to "Address" Object.
"posts" will automatically convert to an array of "Post" objects.
The library detect the plural nouns, and finds the right class to be used for mapping
```objective-c
{
   "firstName"   : "Aryan",
   "lastName"    : "Ghassemi",
   "age"         : 26,
   "dateOfBirth" : "01/01/2013",
   "address"     : { 
                        "city" : "San Diego", 
                        "country" : "US"  
                   },
   "posts"       : [
                         {
                             "title" : "Post 1 title",
                             "datePosted : "04/15/2013",
                         },
                         {
                             "title" : "Post 2 title",
                             "datePosted : "04/12/2013",
                         }
                   ]
}

User *user = [User objectFromDictionary:aDictionary];
```

Complex Mapping
-------------------------
Here is a more complex scenario where the dictionary keys do not match the model property names.
The key for date of birth changes from "dateOfBirth" to "dob".
Each post has an author and the conversion class (User) doesn't have a property with that name.
```objective-c
{
   "firstName"   : "Aryan",
   "lastName"    : "Ghassemi",
   "age"         : 26,
   "dob" : "01/01/2013",
   "address"     : { 
                        "city" : "San Diego", 
                        "country" : "US"  
                   },
   "posts"       : [
                         {
                             "title" : "Post 1 title",
                             "datePosted : "04/15/2013",
                             "author" : { 
                                             "firstName" : "Chuck", 
                                             "lastName" : "Norris" 
                                        }
                         },
                         {
                             "title" : "Post 2 title",
                             "datePosted : "04/12/2013",
                             "author" : { 
                                             "firstName" : "Chuck", 
                                             "lastName" : "Norris" 
                                        }
                         }
                   ]
}

// Handle different key for dateOfBirth
[inCodeMappingProvider mapFromDictionaryKey:@"dob" toPropertyKey:@"dateOfBirth" forClass:[User class]];

// Handle conversion of "author" to a "User" object
[inCodeMappingProvider mapFromDictionaryKey:@"author" toPropertyKey:@"author" withObjectType:[User class] forClass:[Comment class]];

User *user = [User objectFromDictionary:aDictionary];
```

Mapping Array on root level
------------------------- 
```objective-c
[
   {
      "firstName" : "Aryan",
      ... rest of JSON data ...
   },
   {
      "firstName" : "Chuck",
      ... rest of JSON data ...
   },
]

NSArray *users = [User objectFromDictionary:aDictionary];
```

Flat Data to Complex Object
-------------------------
```objective-c
{
      "firstName"           : "Aryan",
      "city"                : "San Diego"
      "country"             : "United States"
}

   // We map city and country to a nested object called 'address' inside the 'user' object
	[self.mappingProvider mapFromDictionaryKey:@"city" toPropertyKey:@"address.city" forClass:[User class]];
	[self.mappingProvider mapFromDictionaryKey:@"country" toPropertyKey:@"address.country" forClass:[User class]];
	
	User *user = [User objectFromDictionary:aDictionary];
      NSLog(@"FirstName:%@   City:%@  Country:%@", 
      user.firstName,
      user.address.city, 
      user.address.coutnry);
```

Date Conversion
-------------------------
Automapper has a property named defaultDateFormatter, and when the property is set it'll use this NSDateFormatter for date conversions on all NSDate properties. It's recomended to set the defaultDateFormatter for best performance. Note that custom dateFormatters have priority over defaultDateFormatter
```objective-c
[inCodeMappingProvider setDefaultDateFormatter:aDefaultDateFormatter];
```

ObjectMapper uses a list of common NSDateFormatters to convert string to NSDate. Here is a list of common dateFormats supported out of the box
```objective-c
"yyyy-MM-dd"
"MM/dd/yyyy"
"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"
"yyyy-MM-dd HH:mm:ss"
"MM/dd/yyyy HH:mm:ss aaa"
"yyyy-MM-dd'T'HH:mm:ss'Z'"
```

You can also have custom NSDateFormatter specific to classes & properties
```objective-c
{
      "firstName"           : "Aryan",
      "accountCreationDate" : "01/21/2005"
      "dateOfBirth"         : "2005-21-01"
}

// Custom formatter for account creation date
NSDateFormatter *accountCreationFormatter = [[NSDateFormatter alloc] init];
[accountCreationFormatter setDateFormat:@"MM/dd/yyyy"];
[inCodeMappingProvider setDateFormatter:accountCreationFormatter forProperty:@"accountCreationDate" andClass:[User class]];

// Custom formatter for date of birth
NSDateFormatter *dateOfBirthFormatter = [[NSDateFormatter alloc] init];
[dateOfBirthFormatter setDateFormat:@"yyyy-dd-MM"];
[inCodeMappingProvider setDateFormatter:dateOfBirthFormatter forProperty:@"dateOfBirth" andClass:[User class]];

User *user = [User objectFromDictionary:aDictionary];
```

Different Usage & Helpers
-------------------------
```objective-c
// Using ObjectMapper Directly
ObjectMapper *mapper = [[ObjectMapper alloc] init];
Urse *user = [mapper objectFromSource:dictionary toInstanceOfClass:[User class]];

// Using ObjectMapper Singleton Instance
Urse *user = [[ObjectMapper sharedInstance] objectFromSource:dictionary toInstanceOfClass:[User class]];
```

In order to use these categories you must add your mapping provider to the singleton Instance
```objective-c
// Using NSObject Category
User *user = [User objectFromDictionary:aDictionary];

// Using NSDictionary Category
User *user = [aDictionary objectForClass:[User class]];
```
