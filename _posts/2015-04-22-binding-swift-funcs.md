---
title: "Binding Swift funcs"
description: "Where I talk about my implementation of Squirrel bindings for Swift funcs"
date: 2015-04-22 23:12:00 +0600
tags: [Squirrel, Swift, Functions, Binding, Objective-C]
---
I've already talked about my [quest]({% post_url 2015-04-11-swift-wrappers-for-c-libraries %}) to learn me some Swift. Having implemented basic Swift wrappers for Squirrel tables and arrays, the time has come to move on to the fun stuff: binding functions.

Squirrel allows binding native functions having the `SQFUNCTION` signature which is as following:
{% highlight objc %}
typedef SQInteger (*SQFUNCTION)(HSQUIRRELVM);
{% endhighlight %}
Working with C function pointers in Swift? Oh boy, this gonna be good!
<!--more-->

## What the hell do you want to achieve anyway?

The goal is simple. I would like to create an `SQClosure` class, which would be initialized with a Swift function like this:
{% highlight swift %}
let closure = SQClosure(vm: squirrel) { (x: Int) -> Int in
  return x+1;
}
{% endhighlight %}
And then it could be used as a valid Squirrel object and called from the Squirrel code.

That's not that a big thing to dream of. [SQRat](http://scrat.sourceforge.net/), a Squirrel binding utility for C++, does that easily with templates (although it has been written a long time before lambdas appeared on the C++ horizon, so these are not supported AFAIK).

How does one achieve this sorcery? It could be done with a certain amount of boilerplate code and some clever templates, at least in C++.

So the in the core of the binding mechanism lies the following API:
{% highlight c %}
void sq_newclosure(HSQUIRRELVM v,SQFUNCTION func,SQUnsignedInteger nfreevars);
{% endhighlight %}

Here you pass the Squirrel VM handle, an `SQFUNCTION` pointer and number of free variables to bind to the function[^1].

After that you have your freshly bound native closure in the Squirrel VM stack and can set it as a value for a table slot, use it as a parameter for another function or whatever.

When this function is called from the Squirrel code, the native C `SQFUNCTION` will get called with the Squirrel VM as the only parameter. All parameters passed from Squirrel code will already be pushed to the VM stack waiting to be read and processed.

Pretty simple, right? Apparently not if we're accessing Squirrel from Swift.

[^1]: I don't really know if the 'free variable' term is commonly used in this meaning. Squirrel API documentation defines free variables as following: *"A free variable is a variable external from the function scope as is not a local variable or parameter of the function. Free variables reference a local variable from a outer scope".* So basically 'free variables' are captured variables from an outer scope, which are actually the reason why the Squirrel closures are closures. When binding a native function you can pass external free variables using the provided API.

## Trouble ahead

Googling "swift c function pointer" yields the following [result](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html):

>C function pointers are imported into Swift as `CFunctionPointer<Type>`, where `Type` is a Swift function type. For example, a function pointer that has the type `int (*)(void)` in C is imported into Swift as `CFunctionPointer<() -> Int32>`.

So we delve deeper and look into the mysterious `CFunctionPointer` template... to find almost nothing (less relevant code omitted).

{% highlight swift %}
/// The family of C function pointer types.
///
/// In imported APIs, `T` is a Swift function type such as
/// `(Int)->String`.
///
/// Though not directly useful in Swift, `CFunctionPointer<T>` can be
/// used to safely pass a C function pointer, received from one C or
/// Objective-C API, to another C or Objective-C API.
struct CFunctionPointer<T> : Equatable, Hashable, NilLiteralConvertible {
...
init()
init(_ value: COpaquePointer)
...
}

extension CFunctionPointer : DebugPrintable {
...
}

extension CFunctionPointer : CVarArgType {
...
}
{% endhighlight %}

Nothing really useful so far. It seems we won't be able to create `CFunctionPointers` from Swift code ourselves and surely we won't be able to pass Swift funcs as C functions to the Squirrel API.

## Objective-C to the rescue!

Well it seems we won't be able to avoid Objective-C code in our Swift framework completely. Since we cannot reasonably provide `SQFUNCTIONs` to the Squirrel API from Swift, it seems to be the only possible solution to do it from Objective-C.

Why not 'Objective' and not just 'C' you ask? Because we'll be binding Objective-C blocks.

The idea is actually pretty simple. First we introduce a 'Swift binder' block type, which has a signature similar to `SQFUNCTION`:
{% highlight objc %}
typedef SQInteger (^private_block_SwiftFuncBinder)(HSQUIRRELVM vm);
{% endhighlight %}

Then we use a single `SQFUNCTION` for all our bindings, which expects the block passed to it as a free variable and just forwards the `HSQUIRRELVM` param to the said block. One of the possible implementations looks like this:
{% highlight objc %}
SQInteger SwiftSquirrel_Private_SQFUNC_SwiftFuncBinder(HSQUIRRELVM vm) {
    private_block_SwiftFuncBinder block = nil;

    SQInteger result = 0;

    if (SQ_SUCCEEDED(sq_getuserpointer(vm, -1, (void*)&block))) {
        if (block != nil) {
            result = block(vm);
        }
    }

    return result;
}
{% endhighlight %}

Here we're using the `SQUserPointer` type (which actually is just a `void*`) to pass the block to the bound function. The binding call uses a helper function and looks like this:

{% highlight objc %}
void SwiftSquirrel_Private_createNativeClosureWithBlock(HSQUIRRELVM vm,
        SQInteger (^block)(HSQUIRRELVM))
{
    // TODO: block is never released;
    // reimplement with user data & add release hook
    sq_pushuserpointer(vm, [block copy]); // File is compiled without ARC
    sq_newclosure(vm, SwiftSquirrel_Private_SQFUNC_SwiftFuncBinder, 1);
}
{% endhighlight %}

The single free variable will be on top of the Squirrel VM stack when calling the native function.

Notice that this code has a flaw. The block is leaked on the native closure creation. It happens because the user pointer itself is a simplified version of a 'user data' concept in Squirrel and it is considered a value type and therefore has no destruction facility built in. We obviously have to release the block when the closure is destroyed, so `SQUserPointer` is probably not a good way to go.

The comment in the last code snippet hints that using `sq_newuserdata` API would probably help. I've left this note for myself, but have not actually tried it yet. User data can have release hooks - additional functions, which are called when the corresponding Squirrel object is destroyed[^2]. These should prove helpful for releasing our blocks when needed.

[^2]: Squirrel utilizes memory-counted model similar to the Objective-C with ARC enabled: there are strong and weak references between Squirrel objects, and when the reference count of an object becomes zero, it gets immediately destroyed. Although I remember there some APIs related to garbage collection so there may be other options.

Now we have a binding API with an overly verbose name `SwiftSquirrel_Private_createNativeClosureWithBlock`, which no longer accepts a C function pointer, but an Objective-C block instead. This one can be used from Swift rather straightforwardly:

{% highlight swift %}
public class SQClosure: SQObject {
    internal init(vm: SquirrelVM, name: String?,
      impl: @objc_block(HSQUIRRELVM) -> SQInteger) {
        super.init(vm: vm)

        let top = vm.stack.top

        // The hard part: create the native closure;
        // it is pushed on top of the Squirrel VM stack
        SwiftSquirrel_Private_createNativeClosureWithBlock(vm.vm, impl)

        // Get the stack object into the obj var which is defined
        // in the SQObject class
        sq_getstackobj(vm.vm, -1, &obj)

        // Increase reference count of the Squirrel object by 1
        // so it lives while the SQClosure is alive
        sq_addref(vm.vm, &obj)

        // Provide a readable name for the newly created closure so it
        // can be printed in the call stack info if needed
        if let closureName = name {
            let (length, cName) = closureName.toSquirrelString()
            sq_setnativeclosurename(vm.vm, -1, cName)
        }

        vm.stack.top = top
    }
}
{% endhighlight %}

A little bit of this and that is going on here: we're also keeping a strong reference to the Squirrel object representing newly created closure, adding a readable name to it for debugging purposes etc. But the general idea should be more or less clear. We've bound an Objective-C block to Squirrel and it is callable from inside the Squirrel scripts.

## Now what?

We can bind simple functions using the API we've created. For example this is a function binding which adds two integers together:
{% highlight swift %}
SQClosure(vm: vm, name: nil, impl: { sqvm in
  let vm = SquirrelVM.associated(vm: sqvm) // get SquirrelVM associated with a given HSQUIRRELVM
  let a = vm.stack[2].asInteger! // read the first parameter from the stack
  let b = vm.stack[3].asInteger! // read the second parameter from the stack
  vm.stack << SQValue.Int(a+b) // push the sum back to the stack
  return 1; // 1 indicates that Squirrel should pop the result value; 0 for void functions
})
{% endhighlight %}

But that's not really what we wanted initially. At least it is not completely what we wanted. It would be more convenient to do the same thing by calling something like that:
{% highlight swift %}
SQClosure(vm: squirrel) { (x: Int, y: Int) -> Int in
  return x+y;
}
{% endhighlight %}

Is that possible? Kind of. But this is a topic of a future post.
