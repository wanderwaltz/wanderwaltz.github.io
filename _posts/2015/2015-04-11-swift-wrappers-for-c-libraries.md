---
title: Writing Swift wrappers for C libraries
description: "Where I talk about my first experience in writing Swift code."
date: 2015-04-11 02:30:00
updated: 2015-04-23 00:41:00
tags: [Swift, Squirrel, Type Inference]
---
I've been kind of bashing Swift recently because of the current buggy state of the tools (SourceKit service and Swift compiler crashes are the most notable offenders). However, I have to admit that Swift has become much more usable as a language than it was the last time I've touched it. I still encounter weird seemingly unrelated compilation error messages but (thanks to Stack Overflow and all the people who already encountered something similar) I usually can decipher the errors and either fix them or mourn for things that cannot be fixed.

Swift interaction with C code was a pleasant surprise for me. I've decided to practice Swift a bit by creating a wrapper/bindings library for [Squirrel](http://squirrel-lang.org/) language. Squirrel is written in C++ but has C API so it should be simple to import it and use in Swift code. I've never actually thought it would be that easy.
<!--more-->

## Project structure

I've decided to create a Swift framework for Squirrel, so a Cocoa Touch Framework template was an obvious choice for me. Squirrel is hosted on [SourceForge](http://sourceforge.net/projects/squirrel/) while my project lives on [GitHub](https://github.com/wanderwaltz/SwiftSquirrel), so to simplify things a bit, I've added Squirrel sources directly into my project (it seems that Squirrel license permits this kind of thing).

Xcode does display a bunch of compiler warnings when trying to build Squirrel, so I've decided to put all the vendor code in a separate framework named `CSquirrel` while my `SwiftSquirrel` framework would import it as a dependency. That way I could completely disable compiler warnings generated by the original Squirrel source[^1].

[^1]: Well, it would probably be better just to fix them, but it is not my goal currently. I just want to practice some Swift.

## Working with Squirrel API

As I've already mentioned, Squirrel provides C API, which allows working with it from Swift. Somewhat surprisingly for me, most of the things are imported really well. Squirrel VM stack operations can be easily performed with just a little bit of typecasting involved:

{% highlight swift %}
func push(value: Int) {
  sq_pushinteger(vm, SQInteger(value))
}

func push(value: Float) {
  sq_pushfloat(vm, SQFloat(value))
}

// ... etc.
{% endhighlight %}

Well, there are some quirks to it obviously. For example `SQBool` is actually an `SQUnsignedInteger`, which differs from the type of the `SQTrue` and `SQFalse` constants (which happens to be `Int32` in Swift). The boolean handling gets a bit clunky as the result (since you have to explicitly cast Squirrel boolean constants to `SQBool`):

{% highlight swift %}
func push(value: Bool) {
  sq_pushbool(vm, (value == true) ? SQBool(SQTrue) : SQBool(SQFalse))
}
{% endhighlight %}

On the other side, I thought strings would be a pain, but they are handled pretty simple:

{% highlight swift %}
func push(value: String) {
  let cString = (value as NSString).UTF8String
  let length = strlen(cString)
  sq_pushstring(vm, cString, SQInteger(length))
}
{% endhighlight %}

## SQValue

Trying to think like a Swift programmer would, I've been using the rich Swift enum facility for all Squirrel types. Squirrel VM interaction is stack-based, so I've built the wrapper in such a way that essentially anything that could be pushed into the Squirrel VM stack is described as one of the `SQValue` enum values[^2].

[^2]: `SQValue` enum values are derived from the Squirrel's `SQObjectType` enum with a reasonable addition that Swift enum can also contain the actual value besides representing its type.

SwiftSquirrel is obviously a very early work in progress currently, so the `SQValue` definition is not yet near to completion, but it looks kind of like that:

{% highlight swift %}
public enum SQValue {
    public typealias IntType = Swift.Int
    public typealias FloatType = Swift.Double
    public typealias BoolType = Swift.Bool
    public typealias StringType = Swift.String

    case Int(IntType)
    case Float(FloatType)
    case Bool(BoolType)
    case String(StringType)
    case Object(SQObject)
    case Null
}
{% endhighlight %}

Notice that the types of the associated values have to be explicitly namespaced since the enum values have the same names.

There is another thing I'd like to mention since I've had some trouble finding a way to implement it. Notice that the `FloatType` alias of the enum is really a `Double`? That is intentional. I've started with `Float` and got stuck on the following problem:

I wanted `SQValue` objects to behave as much as their native Swift counterparts as possible. So arithmetical operations with `SQValues` should yield appropriate results; pushing Swift values (like usual `Ints`, `Floats` etc.) to the Squirrel VM stack should result in pushing the corresponding `SQValues`, etc., etc.

One could argue that this kind of goes against the Swift philosophy of having strict type information everywhere: the `SQValue` is a variant type and `var x: SQValue` could hold anything from `Strings` to `Bools` to `Floats` etc. This is true probably, but I wanted to do play around with operators and literal convertible protocols, so I still did that.

In order to allow assigning `Float` constants to the `SQValue` vars, we have to conform to `FloatLiteralConvertible`:

{% highlight swift %}
extension SQValue: FloatLiteralConvertible {
    public init(floatLiteral value: Float) {
        self = .Float(value)
    }
}
{% endhighlight %}

Implementation of this protocol is pretty much straightforward. I also had several `push` overloads in the `VMStack` protocol:

{% highlight swift %}
func push(x: SQValue)
func push(x: Float)
{% endhighlight %}

I've started writing some unit tests for the Squirrel VM stack wrapper, and then it backfired:

{% highlight swift %}
squirrel.stack.push(2.0) // Error! Ambiguous use of 'push'
{% endhighlight %}

Of course, it cannot decide which version of `push` to call!

Thinking about it now, I see that this is my fault of not knowing the language that well. The [docs](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html) clearly say that

>if you do not specify a type for a floating-point literal, Swift infers that you want to create a `Double`

So what do we have here exactly? Literal `2.0` was inferred to be a `Double` which then had to be converted to either `SQValue` or to a `Float` to be able to be pushed into the Squirrel VM stack. In this case, Swift cannot decide which overload to use and generates the error. The solution I've decided to roll with is simple: use `Double` as the `SQValue` backing floating point type. Then push functions would look like that:
{% highlight swift %}
func push(x: SQValue)
func push(x: Double)
{% endhighlight %}

Calling the func with the `2.0` parameter would not be ambiguous anymore since there would be two alternatives: either convert the `Double` parameter to `SQValue` or use `Double` directly without any conversion. Swift uses the latter in this case.

## Convert all the types!

List of the `push` function overloads began to grow[^3]:

{% highlight swift %}
func push(x: SQValue)
func push(x: Int)
func push(x: Double)
func push(x: String)
func push(x: Bool)
func push(x: SQObject)
func push(x: SQTable)
{% endhighlight %}

[^3]: I'll probably talk about `SQObjects` more at some other time, for now just take into account that they were there and added more overloads to implement.

I've also added a `<<` operator as a more concise form of stack pushing. This operator also required all the overloads to be implemented separately.

The further I went into this rabbit hole the less I liked it. If I needed to add one more type to the mix, I would have to add the corresponding `push` overload to `VMStack` protocol, add the implementation and add the `<<` operator overload which calls `push`.

The `push` function declarations are almost the same and differ only by the parameter type. Do I really need all of these overloads? Internally all `push` implementations call the `SQValue` push implementation, which contained a big switch and called the appropriate Squirrel API func:

{% highlight swift %}
func sq_pushstring(v: HSQUIRRELVM, s: UnsafePointer<SQChar>, len: SQInteger)
func sq_pushfloat(v: HSQUIRRELVM, f: SQFloat)
func sq_pushinteger(v: HSQUIRRELVM, n: SQInteger)
func sq_pushbool(v: HSQUIRRELVM, b: SQBool)
{% endhighlight %}

Generics you say? I do not really see how they would help. I have some experience with Squirrel C++ bindings, and C++ templates could've proven useful here (make the template dependent on the `push` argument parameter and provide specializations for all required types), but this kind of stuff is not available for Swift generics. It turns out it is not needed either.

Meet `SQValueConvertible`:

{% highlight swift %}
public protocol SQValueConvertible {
    var asSQValue: SQValue { get }
}
{% endhighlight %}

Now all that we have to do is provide one `push(x: SQValueConvertible)` implementation and add the following extension to all the types we want to work with:

{% highlight swift %}
extension Int: SQValueConvertible {
    public var asSQValue: SQValue {
        get {
            return SQValue.Int(self)
        }
}

// Provide the similar implementation for Double,
// String, Bool, SQObject, SQTable etc.
{% endhighlight %}

Even `SQValue` itself should conform:

{% highlight swift %}
extension SQValue: SQValueConvertible {
    public var asSQValue: SQValue {
        get {
            return self
        }
    }
}
{% endhighlight %}

Now calling `push(10)`, `push(3.14)`, `push("Hello, World!")` would all automatically work and adding one more type is as easy as adding one more extension which implements `SQValueConvertible`.

Swift baby steps. I am so proud of myself.

## Not the last one

I've really enjoyed solving this particular problem. It is completely different from what I usually do while writing Objective-C code. I've been coding the SwiftSquirrel project at nighttime for the whole last week. That did not go well with getting up and going to work the next days, but it was a lot of fun.

I've already had a couple more problems to scratch my head over, but I'll probably talk about them some other time.

### Followup posts

- [Binding Swift funcs]({% post_url /2015/2015-04-22-binding-swift-funcs %}) describes the non-trivial approach required to use Swift funcs as native Squirrel closures.

<br/>
