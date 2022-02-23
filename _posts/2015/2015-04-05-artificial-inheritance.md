---
title: Artificial Inheritance
description: "Where I build a composition-based object inheritance mechanism in Objective-C."
date: 2015-04-05
tags: [Objective-C, Objective-C Runtime, NSProxy, iOS]
---
[They](http://blogs.perl.org/users/sid_burn/2014/03/inheritance-is-bad-code-reuse-part-1.html) [say](http://blog.berniesumption.com/software/inheritance-is-evil-and-must-be-destroyed/) [inheritance](http://simpleprogrammer.com/2010/01/15/inheritance-is-inherently-evil/) [is](http://stackoverflow.com/questions/11056943/deep-class-inheritance-hierarchy-bad-idea) [bad](http://codingdelight.com/2014/01/16/favor-composition-over-inheritance-part-1/). Yes, there really are 5 different links in the previous sentence.

The links I've provided may not be the most trustworthy sources on the subject (as the matter of fact, I've entered 'inheritance is bad' in the Google prompt and used the top results just to provide a couple of examples). Jokes aside, there is much info out there about the reasons to prefer composition over inheritance in most cases.

As with all of such statements you do not blindly follow the rule. Inheritance is a tool, and as a software engineer, you should know when and where to use your tools.

I'm using composition for building complex objects a lot these days. One of the patterns I've been using lately is adding Objective-C protocol conformance to specific objects (i.e. not classes, but individual instances) with the help of wrapper (or decorator) objects. To simplify the interaction with these wrappers I am using the message forwarding mechanism, which allows me treating the wrapper in the same way as the original object, but with the benefits of the added protocol.

Now starting with that in mind I've come up with an interesting little runtime construct, which utilizes composition and message forwarding to implement multiple inheritance-like behaviors on the instance level.
<!--more-->

The idea is actually pretty simple. In the scheme described above my wrapper object implements the protocol, which it is designed to add to the wrapped object. However, abstracting the protocol implementation from the wrapper and implementing it in a separate class could achieve the same result. The wrapper itself would only be responsible for proper message forwarding between the objects it combines.

Now, why would we stop on protocols only? We could easily combine several classes just for the sake of doing it and say that our wrapper 'inherits' these objects' properties and methods. If we override the reflection methods such as `conformsToProtocol:` and `isKindOfClass:`, our wrapper could pose as the objects which it wraps, implementing 'is-a' relationship almost flawlessly. This looks a lot like inheritance to me.

Let's write some code shall we?
-------------------------------

Suppose the interface of our proxy class would look like this:

{% highlight objc %}
@interface WWInheritanceProxy: NSProxy
- (void)inherit:(id)parent;
- (void)setDesignatedTarget:(id)designatedTarget forSelector:(SEL)selector;
@end
{% endhighlight %}

The first method adds the parent object to the list of wrapped objects. Messages received by the proxy will be forwarded to one of these. However, there could be situations when several of the proxied objects do respond to a specified selector, and the proxy would not know which one to forward the message to. That is where the second method comes into the play. We could select a designated target for individual selectors to make sure that of several objects responding to the given selector, only the one which we want to will actually receive the message.

The implementation is pretty straightforward:
{% highlight objc %}
@interface WWInheritanceProxy()
@property (atomic, strong) NSDictionary *parents;
@property (atomic, strong) NSDictionary *designatedTargets;
@end


- (void)inherit:(id)parent
{
    NSParameterAssert(parent != nil);
    if (parent == nil) {
        return;
    }

    NSMutableDictionary *parents = [self.parents mutableCopy] ?: [NSMutableDictionary new];
    NSString *className = NSStringFromClass([parent class]);

    NSParameterAssert(className != nil);
    if (className == nil) {
        return;
    }

    parents[className] = parent;
    self.parents = [parents copy];
}

- (void)setDesignatedTarget:(id)target forSelector:(SEL)selector
{
    NSParameterAssert(target != nil);
    if (object == nil) {
        return;
    }

    NSString *selectorString = NSStringFromSelector(selector);
    NSParameterAssert(selectorString != nil);
    if (selectorString == nil) {
        return;
    }

    NSMutableDictionary *designatedTargets = [self.designatedTargets mutableCopy] ?: [NSMutableDictionary new];
    designatedTargets[selectorString] = target;
    self.designatedTargets = [designatedTargets copy];
}
{% endhighlight %}

I'm aiming for the thread-safe implementation, hence the atomic properties and copying the dictionaries instead of mutating them directly. Parent objects are stored using the class name as a key; designated targets are stored using the selector name as a key. Note that the designated targets are entirely independent of the parent objects. This is intentional. If you wanted, you could construct the proxy by adding method implementations one by one using the designated targets API.

Now let's look at the forwarding part. First we write a couple of helper methods to work with designated targets:

{% highlight objc %}
- (NSMethodSignature *)methodSignatureForDesignatedTargetForSelector:(SEL)aSelector
{
    NSString *selectorString = NSStringFromSelector(aSelector);
    id designatedTarget = self.designatedTargets[selectorString];
    return [designatedTarget methodSignatureForSelector: aSelector];
}


- (BOOL)forwardInvocationToDesignatedTarget:(NSInvocation *)invocation
{
    NSString *selectorString = NSStringFromSelector(invocation.selector);
    id designatedTarget = self.designatedTargets[selectorString];

    BOOL didInvoke = NO;

    if (designatedTarget != nil) {
        [invocation invokeWithTarget: designatedTarget];
    }

    return didInvoke;
}
{% endhighlight %}

Then the actual forwarding mechanism is implemented like this:

{% highlight objc %}
- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    // pose as union of the parent objects' protocols
    for (id parent in self.parents.allValues) {
        if ([parent conformsToProtocol: aProtocol]) {
            return YES;
        }
    }
    return NO;
}


- (BOOL)isKindOfClass:(Class)aClass
{
    // pose as union of the parent objects' classes
    // kind of multiple inheritance maybe?
    for (id parent in self.parents.allValues) {
        if ([parent isKindOfClass: aClass]) {
            return YES;
        }
    }
    return NO;
}


- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    // first try to find a designated target
    BOOL didInvoke = [self forwardInvocationToDesignatedTarget: anInvocation];

    // otherwise find the first parent who responds and forward to it
    if (didInvoke == NO) {
        for (id parent in self.parents.allValues) {
            if ([parent respondsToSelector: anInvocation.selector]) {
                [anInvocation invokeWithTarget: parent];
                return;
            }
        }
    }
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    // again, first look for a designated target
    NSMethodSignature *result = [self methodSignatureForDesignatedTargetForSelector: aSelector];

    // otherwise use  any parent who responds
    if (result == nil) {
        for (id parent in self.parents.allValues) {
            NSMethodSignature *methodSignature = [parent methodSignatureForSelector: aSelector];

            if (methodSignature != nil) {
                result = methodSignature;
                break;
            }
        }
    }

    // if the result is nil by the time we get here, we'll most likely
    // crash since NSProxy does not know a lot of method signatures by default
    return result ?: [super methodSignatureForSelector: aSelector];
}


- (BOOL)respondsToSelector:(SEL)aSelector
{
    // any parent of designated target will do
    NSString *selectorString = NSStringFromSelector(aSelector);

    if ([self.designatedTargets.allKeys containsObject: selectorString]) {
        return YES;
    }

    for (id parent in self.parents.allValues) {
        if ([parent respondsToSelector: aSelector]) {
            return YES;
        }
    }

    return NO;
}

{% endhighlight %}

We are almost there now. To make our proxy completely interchangeable with the objects it wraps, we may want to override `isEqual:` too. We could try to provide a similar implementation for this method:

{% highlight objc %}
- (BOOL)isEqual:(id)object
{
    BOOL equal = NO;

    for (id parent in self.parents.allValues) {
        if ([parent isEqual: object]) {
            equal = YES;
            break;
        }
    }

    return equal ?: [super isEqual: object];
}
{% endhighlight %}

However, here be dragons, they say. Remember that overriding `isEqual:` also requires having a consistent `hash` implementation? If two objects are equal, they should also have equal hashes. Suppose we have several parent objects and are comparing the proxy with each of the parents using `isEqual:`. In that case, this implementation will return `YES` each time, but which value of the `hash` would we return? Each parent could return a different hash in general.

That makes the creation of a universal `isEqual:` implementation kind of impossible. A designated 'identity' object, which is also set externally and is used to forward both `isEqual:` and `hash` calls, is probably a decent tradeoff.

So what's the purpose of that exactly?
--------------------------------------

I've not actually come up with a scenario when this would be useful yet. As usual, the code is [available](https://github.com/wanderwaltz/artificial-inheritance) on GitHub; feel free to have a look if you are interested. My lack of ideas for usage scenarios gets kind of clear when you look at the unit tests, which I've provided for the class. Without a proper usage scenario, these tests are rather artificial and contrived.

It is worth mentioning that this proxy class is rather useless by itself. You generally would not gain anything by just blindly combining several objects into one and providing automatic forwarding mechanisms. These objects are still completely independent. The usage scenario I am having in mind involves subclassing `WWInheritanceProxy` and providing custom implementations of some of the methods, which will allow the resulting object to be more than just a sum of its parts. You supply the most important methods; automatic forwarding gives the rest.
