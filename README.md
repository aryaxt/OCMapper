Data Mapping library for Objective C
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

Swift Support
=========================
OCMapper takes advantage of the objective c runtime API, and will only work for classes that inherit from NSObject


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
- Auto date conversion, and configurable DateFormatters


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
// Mapping would NOT be required if both dictionary an drpopery were named 'user'
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

<b>NOTE:</b> Setting DateFormatter is not required as long as all date formats are standard or if the defaultDateFormatter knows how to parse the dates. The code below is just to demonstrate that it's possible to set custom dateformatters but it is not required due to use of standard date formats in this example.

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

Core Data Support
-------------------------
In order to use core data you must pass an instance of ManagedObjectInstanceProvider to object Mapper.

Object Mapper does not currently support both core-data and non-core-data mapping at the same time using a single instance of ObjectMapper.
in order to use both avoid using the singleton instance and Category methods. Instead initialize 2 diffrent instances of ObjectMapper; one with ObjectInstanceProvider and another with ManagedObjectInstanceProvider.
```objective-c
ManagedObjectInstanceProvider *instanceProvider = [[ManagedObjectInstanceProvider alloc] initWithManagedObjectContext:moc];
	
[[ObjectMapper sharedInstance] setInstanceProvider:instanceProvider];
```
On default Object mapper creates a new instance of NSManagedObject on every mapping. In order to update an existing record you could provide unique keys for a given class and ObjectMapper would automatically update the existing record.

```objective-c
[managedObjectInstanceProvider setUniqueKeys:@[@"userId"] forClass:[User class] withUpsertMode:UpsertModePurgeExistingObject];
```

When assigning keys for classes OCMApper also requires an enum describes how ObjectMapper should upsert existing records.

- **UpsertModeUpdateExistingObject:** This option creates a new temporary instance of managed object, and then based on the given keys it attempts to find an existing record. If it finds ONE record it updates all properties of the existing managed object and finally removes the temporary object. When using this upsert mode, delete does not get called on any of the related managed objects, and therefore records remain in memory. For instance if the user's address has changed from A to B address would be updated properly, but both records would remain in core data.

- **UpsertModePurgeExistingObject:** This option creates a new instance of managed object, and then based on the given keys it attempts to find an existing record. If it finds ONE record it calls delete on that record, and then inserts the newly created object into context. Using this upser mode, delete gets called on existing managed object, and therefore core data would delete all related relational objects, and all "delete rules" in core data model would be applied. For instance, if a user get's updated, and phone number changes from A to B, and if trhe delete rule is marked as cascade, then Address A would be removed and address B would be assigned to the user.

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
