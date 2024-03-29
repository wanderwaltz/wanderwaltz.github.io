---
title: Putting more "C" in your Objective-C
description: "Where I ramble about inability to create 'true' private methods for Objective-C classes."
date: 2015-03-26
tags: [Objective-C, Coding Style, iOS]
---
I like Objective-C. I've been writing Objective-C code for almost six years now, and I can surely say that I am comfortable with the language and that it provides everything I need to make awesome apps. However, nothing is perfect of course.

The dynamic nature of the language can be a woe at some times. One of such things is the lack of proper private methods in Objective-C.
<!--more-->

Whether you like it or not, whatever you call your method, it could
be overridden in a subclass even if you do not want it to be. More so, if your method is not listed in the header file, someone could override your 'private' hidden method even without realizing it - who knows what will happen in that case. Hopefully, your app will crash fast and early.

I have a small silly practical reason to talk about it right now. I've been creating a lot of `IB_DESIGNABLE` views recently and therefore as a responsible person I have to override two initializers[^1] for each of them:

[^1]: The designated initializer for a `UIView` subclass is, of course, the `initWithFrame:`, but when loading the view from a storyboard or a xib it will not be called in favor of the `initWithCoder:`.

{% highlight objc %}
// if someone wants to create such view in code
- (instancetype)initWithFrame:(CGRect)frame;

// will be called when loading from a xib or storyboard
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{% endhighlight %}

Often the code that goes in these initializers is the same. It creates some subviews or maybe sets up some initial internal state of the view - whatever. So I create a method which does all the setup and is called by both of these initializers:

{% highlight objc %}
- (void)private_setup
{
    // Create subviews, set up state etc.
}
{% endhighlight %}

I prefix the name of this method with `private_` to notify myself and my teammates that it should not be exposed to the outside world and is actually a private implementation detail of my class.

It gets somewhat ugly when I am trying to subclass such a view. I want then to have another common setup logic specific to the subclass, but I cannot actually use the name `private_setup` anymore. Otherwise, it would override the logic of the superclass initialization, and I will not be able to call `super` since the method is not exposed anywhere.

This is actually not a real problem. I can instantly name at least two possible solutions to that which aren't even hard to do:

- The most obvious one is to expose some setup method, tag it with `NS_REQUIRES_SUPER` and call it a day. It is probably the simplest one to go with, but I am really in a mood to dig deeper today. What if someone would call this method manually? Since it is exposed, someone might just do that. It also may become confusing. Instead of knowing about the two initializers of the class we also should keep in mind the `setup` method and always remember when it gets called and whether it is safe to use other methods or properties of this class from this method etc., etc.

- Give the 'private' method a more complicated class-dependent name that is less likely to be overridden by mistake: `private_MyAwesomeIBDesignableViewClass_setup` for example. And then in subclass use something like `private_MyEvenMoreAwesomeIBDesignableViewClassSubclass_setup`. How's that sound? Ugly, I know.

Both these solutions do work, and both are somewhat OK, but I want more. I want actual private methods for my classes which could not possibly be ever called by anyone else and which won't name clash so I could use simple identifiers like `private_setup`. Can Objective-C help me with that?

Apparently Objective-C does not, but plain old C probably will.

I've ended up using this kind of construct:

{% highlight objc %}
@implementation MyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];

    if (self != nil) {
        private_setup(self);
    }

    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder: coder];

    if (self != nil) {
        private_setup(self);
    }

    return self;
}

static void private_setup(MyView *self)
{
    // Here we do the common initialization.
    // Using `self` as an explicit variable in a C function instead of
    // using an Objective-C method provides almost no inconvenience except
    // that if you're accessing ivars, you have to write self->_ivarName
    // instead of just _ivarName.
}

@end
{% endhighlight %}

So a static C function which accepts `self` as a parameter (you could add any other parameters as required) does pretty much exactly what I need regarding privacy and non-overridability.

I know a couple of people who probably would say that this kind of code is even more ugly than the variants I've listed before (I am looking at you [@stkhapugin](http://twitter.com/stkhapugin)), but I'm quite fond of it at the moment. It does everything I wanted to and does not require any obscure runtime or preprocessor magic to implement. I call it a win.
