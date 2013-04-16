OC Mapper for Objective C
=========================

OCMapper is an NSDictionary to NSObject convertor.

Features:
- Supports array structures
- Supports Tree Structures
- Supports complex object nesting 
- Auto detects key/values based on NSDictionary keys
- Fully Configurable
- Does not require subclassing or adding any extra code to your model
- Convert Date values to NSDate
- Takes default dateformatter and uses it for all NSDate conversions
- NSDate conversion can be configured based on specific class & properties

Let's say these are our models
```objective-c
@interface User
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) NSDate *dateOfBirth;
@property (nonatomic, strong) Address *address;
@property (nonatomic, strong) Post *Posts;
@end

@interface Address
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@end

@interface Post
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) User *author;
@end
```

Simple Mapping

```objective-c
{
   firstName
}

```
