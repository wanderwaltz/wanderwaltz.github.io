---
title: Safe NSArray literals
description: "A way to ensure nil safety for NSArray literals."
date: 2016-03-18 22:20:00 +0600
updated: 2016-03-19 04:34:00 +0600
tags: [Objective-C, NSArray, iOS]
---
While Swift is a new panacea and a go-to solution for all things programming, we still have to maintain our years'-old Objective-C codebases. And that comes with a bag of old problems, which every Objective-C programmer has encountered once in their life.

Consider an `NSArray`. Capable of containing any object type, it does not handle `nil` all that well. Constructing an `NSArray` of objects using an array literal like this:

{% highlight objc %}
NSArray *arr = @[object1, object2, object3];
{% endhighlight %}

is concise and convenient, but it comes with a cost. If any of the object references is actually `nil`, we'll have a crash in our hands. We don't really want this to happen, right?
<!--more-->

# The Problem

I really want to write code like this:

{% highlight objc %}
[self presentActions: @[
    [LikeAction new],
    [DislikeAction new],
    [ShareAction new]
]];
{% endhighlight %}

without worrying about accidentally getting `nil` in one of these object references. Here I've just constructed them, but what their initializers may fail?[^1] What if I do not really know where the objects come from (as if I got them from elsewhere as method parameters)?

[^1]: Well, yes, we have to decide what to do with these possible `nil` objects if we encounter one of these. In our codebases the most common case is just to skip them, so this is the scenario I am considering.

**Solution #1: Explicit `nil` checks** One obvious alternative is to `nil`-check all of the objects before adding them to the array, but it is much uglier:

{% highlight objc %}
NSMutableArray *actions = [[NSMutableArray alloc] init];

LikeAction *likeAction = [LikeAction new];

if (likeAction != nil) {
    [actions addObject: likeAction];
}

DislikeAction *dislikeAction = [DislikeAction new];

if (dislikeAction != nil) {
    [actions addObject: dislikeAction];
}

ShareAction *shareAction = [ShareAction new];

if (shareAction != nil) {
    [actions addObject: shareAction];
}

[self presentActions: actions];
{% endhighlight %}

This solution adds much cognitive strain on the potential code reader. Instead of focusing on the simple "instantiate some actions and present them" logic, we create a bunch of temporary variables, complement each one with a `nil`-checking condition and completely obscure the point of the whole thing.

One can argue that we should have non-failable initializers of the objects in question and there would be no problem in the first place, but unfortunately, this is not always possible.

**Solution #2: Implicit nil checks** Trying to minimize possible `nil`-related crashes, we've added a category on `NSMutableArray`, which provides a method for safely adding a nullable object by just ignoring the `nil` values.

The code becomes much simpler:

{% highlight objc %}
NSMutableArray *actions = [[NSMutableArray alloc] init];

[actions addMaybe: [LikeAction new]];
[actions addMaybe: [DislikeAction new]];
[actions addMaybe: [ShareAction new]];

[self presentActions: actions];
{% endhighlight %}

Well, it is simpler, but not simple enough. I do not really like to have a temporary array variable, the only purpose of which is to be passed to the method invocation right after it is instantiated.

**Solution #3: Defaulting** Another possible solution is to default all the possible `nil` values to
a certain guaranteed non-nil object:

{% highlight objc %}
[self presentActions: @[
    [LikeAction new] ?: [NSNull null],
    [DislikeAction new] ?: [NSNull null],
    [ShareAction new] ?: [NSNull null]
]];
{% endhighlight %}

This is also too syntactically heavy for my taste and also requires the `presentActions:` method to know about this defaulting behavior and appropriately handle the `NSNull` instance passed instead of the expected action object.

There has to be a better way.

## The Solution: Custom literals

What if we could come up with a custom array literal implementation, which skips `nil` values automagically? Preempting myself a bit, I'll show how the solution I've ended up with looks like:

{% highlight objc %}
[self presentActions: $array(
    [LikeAction new],
    [DislikeAction new],
    [ShareAction new]
)];
{% endhighlight %}

It is almost as simple as the default `@[]` syntax and provides virtually no additional cognitive strain on the reader.

Implementation is also simple enough. Consider the following class:

{% highlight objc %}
@interface NSArraySafeLiteral : NSObject

+ (NSArray *)arrayWithObjects:(id)terminator, ...;

@end
{% endhighlight %}

Here we are using variable argument list for passing the objects. Usually, these lists are `nil`-terminated (there's even an `NS_REQUIRES_NIL_TERMINATION` attribute, which triggers a compiler check for that), but since we want to allow `nil` values inside our argument list, we have to provide some other object as the terminator.

Implementation of this class is rather straightforward:

{% highlight objc %}
@implementation NSArraySafeLiteral

+ (NSArray *)arrayWithObjects:(id)terminator, ...
{
    NSParameterAssert(terminator != nil);

    NSMutableArray *result = [NSMutableArray new];

    va_list args;
    va_start(args, terminator);

    id _Nullable nextObject = va_arg(args, id);

    while (nextObject != terminator) {
        if (nextObject != nil) {
          [result addObject: nextObject];
        }
        nextObject = va_arg(args, id);
    }

    va_end(args);

    return result;
}

@end
{% endhighlight %}

Note that we still have a mutable array and may need to copy it to make it immutable, but it is probably an optional precaution since the method interface does not state anything about the result's mutability.

The only step left is to provide a helper macro, which will make `NSArraySafeLiteral` a little bit simpler:

{% highlight objc %}
#define $array(...)                        \
    ([NSArraySafeLiteral arrayWithObjects: \
        [NSArraySafeLiteral class],        \
        __VA_ARGS__,                       \
        [NSArraySafeLiteral class]])
{% endhighlight %}

Here I am utilizing the class pointer as the list terminator, which should suffice for the most use cases, but any other known static object can be used instead.

Now the syntax

{% highlight objc %}
[self presentActions: $array(
    [LikeAction new],
    [DislikeAction new],
    [ShareAction new]
)];
{% endhighlight %}

becomes possible and works like a charm skipping all the nasty `nil` values. I call it a win.
