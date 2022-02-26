---
title: How special is Swift.Error anyway?
description: "It seems that Swift.Error can do things no other protocols are allowed to."
date: 2022-02-25 09:35:00 +0700
tags: [Swift, Protocols, Existentials, Generics]
---

Consider the [Result][Swift.Result] generic in Swift:

```swift
@frozen enum Result<Success, Failure> where Failure : Error
```

Here [Error][Swift.Error] is an empty protocol:

```swift
protocol Error
```

It is somewhat common to use `Result<T, Error>` where occurring errors are not specified[^unknown-error].

```swift
enum ConcreteError: Error {
    case anUnknownErrorOccurred
}

// this is fine
let result: Result<Int, Error> = .failure(ConcreteError.anUnknownErrorOccurred)
```

What bothers me is that no other protocol can be used in the same fashion. If I create my own error protocol and custom result type like this:

```swift
protocol MyError {}

@frozen enum MyResult<Success, Failure> where Failure : MyError {
    case success(Success)
    case failure(Failure)
}

enum MyConcreteError: MyError {
    case anUnknownErrorOccurred
}

// this is broken
let result: MyResult<Int, MyError> = .failure(MyConcreteError.anUnknownErrorOccurred)
```

I get a compilation error stating that

> protocol 'MyError' as a type cannot conform to the protocol itself
>
> **note:** only concrete types such as structs, enums and classes can conform to protocols

So, `Error` as a protocol can be used as a generic parameter as a type conforming to `Error` while all other protocols do not conform to themselves.

Turns out it is actually [documented][protocol-type-non-conformance] in Swift source repository:

> Currently, even if a protocol `P` requires no initializers or static members, the existential type `P` does not conform to `P` (with exceptions below). This restriction allows library authors to add such requirements (initializers or static members) to an existing protocol without breaking their users' source code.
>
> **Exceptions**
>
> When used as a type, the Swift protocol `Error` conforms to itself; `@objc` protocols with no static requirements can also be used as types that conform to themselves.

I confess that I don't know Swift type system implementation _that_ deeply to understand why these kinds of restrictions are necessary, although it was discussed more than once in Swift evolution mailing lists and then forums. Mostly people were complaining about the protocols with associated types which are kind of a pain to use. I used to write code with this kind of generic protocols a lot, but almost never bother nowadays.

----

**Notes:**

[Swift.Result]: https://developer.apple.com/documentation/swift/result
[Swift.Error]: https://developer.apple.com/documentation/swift/error
[protocol-type-non-conformance]: https://github.com/apple/swift/blob/main/userdocs/diagnostics/protocol-type-non-conformance.md

[^unknown-error]: Gotta love those [unknown errors]({% post_url /2016/2016-03-31-your-error-messages-are-not-hepful %}).
