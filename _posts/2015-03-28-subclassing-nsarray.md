---
title: Subclassing NSArray
description: "Where I talk about how one creates a proper NSArray subclass."
date: 2015-03-28
tags: [Objective-C, NSArray, Class Cluster]
---
Creating custom collections is rarely necessary nowadays. Most of the time you can safely go with the collection classes provided by the standard library you are working with and not bother with the implementation details. What would be the reason to write a custom collection anyway?

- **Performance?** I'd say that you go with the standard collections and rewrite them if and only if you are completely sure that it is the collection that is your bottleneck and not anything else. Give me a profiler-proven reason to do that.
- **Changing the interface?** Well, that could be done via categories or composition. You do not really need to subclass `NSArray` or `NSDictionary` to change their interface if you want to.

I cannot come up with another reason to subclass Foundation collections right now, but to be honest, here at [#justcodingthings](http://wanderwaltz.github.io) we do not actually need a reason to do something. We do it because we can, and that is the only reason we need.
<!--more-->

There is nothing new under the sun, and [@mikeash](https://twitter.com/mikeash) has already discussed this topic in his [Friday Q&A](https://mikeash.com/pyblog/friday-qa-2010-03-12-subclassing-class-clusters.html), but I still thought I'd reiterate it once more at least for the reason of providing another example of the technique.

To have a semi-realistic sample to work with, let's build a dynamically mapped array and integrate it into `NSArray` cluster.

Define 'dynamically mapped'
-------------
So suppose we want to perform a particular transform or mapping to the elements of a given `NSArray`. We could represent the mapping  with a block:

{% highlight objc %}
id (^mapper)(id object, NSUInteger index) {
    // return transformed object
}
{% endhighlight %}

So each time we access `array[i]` we will actually receive the result of `mapper(array[i], i)`. There are some questions open to discussion of course. What will we do if the block returns `nil` for some of the elements? To be consistent with `NSArray` API we should not return `nil` since we do not expect that from `NSArrays`. I suggest we transform `nil`s to `NSNull` instances automatically.

What will the mapping interface look like? I suppose something like that will do nicely:

{% highlight objc %}
NSArray *originalArray = @[@1, @2, @3];
NSArray *mappedArray =
    [originalArray arrayByApplyingMapping: ^(id object, NSUInteger index){
        return @([object integerValue]*2);
    }];
XCTAssertEqualObjects(mappedArray[1], @4, @""); // @[@2, @4, @6]
{% endhighlight %}

The goal is to get a proper `NSArray` instance which does not invoke the mapper block at the point of creation, but keeps it and invokes it when we try to access a certain element[^1].

[^1]: We could also think of a lazy mapping and memoise the mapped value to return it immediately when trying to access the same element for the second time, but this is probably out of the scope of this post.

We'll be creating a `CCMappedArray`[^2] with the following interface:

[^2]: Prefix `CC` stands for 'Containers Collection' which is a name of a [github project](https://github.com/wanderwaltz/ContainersCollection) where mapped array is implemented as well as some other collection-like classes.

{% highlight objc %}
@interface CCMappedArray : NSArray

- (instancetype)initWithArray:(NSArray *)originalArray
        mapper:(id (^)(id object, NSUInteger index))block NS_DESIGNATED_INITIALIZER;

@end
{% endhighlight %}

And we'll also need a category on `NSArray`:

{% highlight objc %}
@interface NSArray(CCMappedArray)

- (NSArray *)arrayByApplyingMapping:(id(^)(id object, NSUInteger index))mapper;

@end
{% endhighlight %}

Since we know we'll be subclassing `NSArray`, let's dive into the [documentation](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSArray_Class/) and look what we'll have to do to achieve our goal.

>Any subclass of `NSArray` must override the primitive instance methods `count` and `objectAtIndex:`. These methods must operate on the backing store that you provide for the elements of the collection.

>You might want to implement an initializer for your subclass that is suited to the backing store that the subclass is managing. If you do, your initializer must invoke one of the designated initializers of the `NSArray` class, either `init` or `initWithObjects:count:`. The `NSArray` class adopts the `NSCopying`, `NSMutableCopying`, and `NSCoding` protocols; if you want instances of your own custom subclass created from copying or coding, override the methods in these protocols.

So we'll have to deal with the following:

- **Primitive instance methods.** It's almost trivial to implement these in our case. More on that below.
- **Designated initializers.** Right, so creating our custom `initWithArray:mapper:` initializer won't be enough, since because of subclassing `NSArray` it would be possible to invoke all other initializers of this class on our `CCMappedArray`. So all of the `[CCMappedArray array]`, `[CCMappedArray arrayWithArray: other]` etc. should also work.
- **`NSCopying`** is simple and easily doable.
- **`NSMutableCopying`** is a bit trickier if we want to keep the dynamic mapping. For simplicity I suggest we just return a plain old `NSMutableArray` and lose the mapper block in the process (we'll have to apply the mapper to all elements while copying of course).
- **`NSCoding`** will also lose the mapper block since there is no way to encode/decode it.

Implementation
--------------

The category implementation is trivial:

{% highlight objc %}
@implementation NSArray(CCMappedArray)

- (NSArray *)arrayByApplyingMapping:(id(^)(id object, NSUInteger index))mapper
{
    return [[CCMappedArray alloc] initWithArray: self
                                         mapper: mapper];
}

@end
{% endhighlight %}

Although there is no reason to create a `CCMappedArray` without a mapper block, we still won't check the parameter for `nil` value here and leave this to the `CCMappedArray` itself if we find it necessary.

Now let's get to the interesting part. We'll probably need to store the references to the original array and the mapper block in the `CCMappedArray`, so we add these properties in the class extension:

{% highlight objc %}
@interface CCMappedArray()
@property (nonatomic, strong, readonly) NSArray *originalArray;
@property (nonatomic, copy, readonly) id (^mapper)(id, NSUInteger);
@end
{% endhighlight %}

Now our designated initializer will look like this:

{% highlight objc %}
- (instancetype)initWithArray:(NSArray *)originalArray
                       mapper:(id (^)(id object, NSUInteger index))block
{
    self = [super init];

    if (self != nil) {
        _originalArray = [originalArray copy];
        _mapper = [block copy];
    }

    return self;
}
{% endhighlight %}

Note how we're using `[originalArray copy]` there - for simplicity we want only to work with immutable arrays, although it is pretty simple to expand the implementation to work with mutable arrays too[^3].

[^3]: Although to keep the `NSMutableArray` contract intact we would need to be sure that setting elements of the array after it has been mapped would not apply the mapping block again. So we would need to store the indexes of the 'automatic' mapped elements and the indexes of the elements set explicitly by the user of the class and process these elements accordingly.

We also need to override the designated initializers of the `NSArray` class:

{% highlight objc %}
- (instancetype)init
{
    return [self initWithArray: @[] mapper: nil];
}


- (instancetype)initWithObjects:(const id [])objects
                          count:(NSUInteger)count
{
    NSArray *array = [[NSArray alloc] initWithObjects: objects count: count];
    return [self initWithArray: array mapper: nil];
}
{% endhighlight %}

Note that both these initializers do not have a mapper block essentially making the returned `CCMappedArray` a useless wrapper over the original `NSArray`. It's OK since initializing `CCMappedArray` using the standard `NSArray` initializers is not really intended.

Now let's get to primitive methods of the `NSArray`. We don't change the count of the original array[^4], so the `count` method just returns the original count:

{% highlight objc %}
- (NSUInteger)count
{
    return self.originalArray.count;
}


- (id)objectAtIndex:(NSUInteger)index
{
    id object = [self.originalArray objectAtIndex: index];
    if (self.mapper != nil) {
        object = self.mapper(object, index) ?: [NSNull null];
    }
    return object;
}
{% endhighlight %}

[^4]: I've seen and worked with an implementation of `NSArray` mapping using a category on `NSArray` which applied the given block to the receiver immediately and returned the mapped `NSArray`. This implementation handled `nil` returned from the block differently, essentially removing elements mapped to `nil` from the result. This would change the count of the elements within the resulting array. With our current implementation, this would result in unnecessary complications so we replace `nil` results with `NSNull`s and keep the count intact.

Without a mapper block, our array represents an identity mapping.

Let's continue with `NSCopying`. Note that since we are working with immutable arrays only, we never have to actually copy anything:

{% highlight objc %}
- (instancetype)copyWithZone:(NSZone *)zone
{
    return self; // Immutable objects do not need to be copied
}
{% endhighlight %}

Then we implement `NSMutableCopying` and `NSCoding` as following:

{% highlight objc %}
#pragma mark - <NSMutableCopying>

- (id)mutableCopyWithZone:(NSZone *)zone
{
    // A neat trick which will automatically map every value
    // when creating the copy
    return [[NSMutableArray alloc] initWithArray: self];
}

#pragma mark - <NSCoding>

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSArray *array = [[NSArray alloc] initWithArray: self];
    [array encodeWithCoder: aCoder];
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSArray *array = [[NSArray alloc] initWithCoder: aDecoder];
    return [self initWithArray: array mapper: nil];
}
{% endhighlight %}

So that is actually it. Our `CCMappedArray` is ready and working. The code for this class can be found [here](https://github.com/wanderwaltz/ContainersCollection). I've added some unit tests for `CCMappedArray` as well.