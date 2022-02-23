---
title: UIResponder notes
description: "Notes on UIResponder and responder chain pattern on iOS"
date: 2022-02-22 20:38:00 +0700
tags: [UIResponder, iOS, Interview Questions]
---

This post is a collection of `UIResponder`-related facts[^why].

[^why]: Recently I've had a job interview. I've been working at the same place for almost 8 years now and thought that I'd try and freshen up my interviewing skills a little. While I did get an offer in the end, I'm not proud of some of the answers I've given during the interview. You'd think a developer with more than 10 years of iOS experience (that's me) should know some of the topics better. I've decided to keep these notes for myself as a quick reference.

----

**UIResponder is a class, not a protocol**

Just a fact to remember. For some reason I tend to think sometimes that `UIResponder` is a protocol and that `UIApplicatonDelegate` automatically conforms to it via protocol inheritance. This is not right though. [Documentation][UIResponder] clearly states that it is a class, although an abstract one.

`UIApplication`, `UIViewControllers` and `UIViews` inherit `UIResponder` and the documentation provides an insight on how the responder chain works with these mixed entities:

> UIKit manages the responder chain dynamically, using predefined rules to determine which object should be next to receive an event. For example, **a view forwards events to its superview**, and **the root view of a hierarchy forwards events to its view controller**.

Also, the following is true:

- when child view controllers are involved, child forwards events to parent's view, which then forwards events to parent itself,
- the root of a view controller hierarchy forwards events to its window,
- window forwards events to its scene,
- scene forwards events to application,
- application forwards events to its delegate.

This can be checked manually by following the [UIResponder.next][UIResponder.next] chain starting from the child view controller[^next-docs].

[^next-docs]: [UIResponder.next][UIResponder.next] describes some of this behavior in the following passage:

    > For example, **UIView** implements this method and **returns the UIViewController object that manages it** (if it has one) **or its superview** (if it doesn’t). **UIViewController** similarly implements the method and **returns its view’s superview**. **UIWindow returns the application object**. The shared **UIApplication** object normally returns nil, but it **returns its app delegate if that object is a subclass of UIResponder and has not already been called to handle the event**.

    It does not mention `UIScene` though.


----

**Q: Once a responder becomes first via becomeFirstResponder, does previous first responder automatically receive resignFirstResponder call?**

Yes, when another responder becomes first, the previous first responder receives [resignFirstResponder()][resignFirstResponder] and exits the responder chain.

This is explicitly stated in the [documentation][becomeFirstResponder]:

> Call this method when you want the current object to be the first responder. Calling this method is not a guarantee that the object will become the first responder. **UIKit asks the current first responder to resign as first responder, which it might not.**

----

**Q: If a responder in a responder chain receives an event, do all other responders receive this event, or event propagation stops?**

The event propagation stops on the first object in the responder chain (not necessary the _first responder_) which can handle the event.

Documentation on [UIApplication.sendAction][sendAction] provides useful insight on that:

> The default implementation dispatches the action method to the given target object or, if no target is specified, to the first responder. Subclasses may override this method to perform special dispatching of action messages.

So, `sendAction` without a target starts with the first responder. `action` which is sent is an Objective-C selector. What happens when the first responder does not respond to the `action` selector? The action is passed up the responder chain to the next responder until either one of the responders handles the event or the chain ends.

----

**Q: Follow-up to the previous question. How exactly UITouch events are processed in the responder chain? Each UIResponder can handle touches. Does this mean that touch handling always stops on the first responder object encountered? How does pointInside and hitTest fit into that scheme?**

This is actually two separate questions for the price of one.

> How does `pointInside` and `hitTest` fit into that scheme?

These methods are used to select which responder to start with when handling touches. The thing is, when delivering events, `UIApplication` uses the _first responder_ only when there are no other means of selecting who has to receive the event. In case of touch input, there is [hitTest][hitTest]. So, the `UIResponder` who receives the touch input is determined by `hitTest` and as I understand the first one to call will always be a `UIView`.

> Each `UIResponder` can handle touches. Does this mean that touch handling always stops on the first responder object encountered?

Well, kind of. You find a responder via `hitTest` and it has all the methods to handle the touches. The touch handling process can end there and now if the corresponding `UIResponder` has non-trivial implementation of the touch handling methods. But the default implementation forwards the events up the responder chain and does nothing else, so the touch handling may happen in the different object than the one which is determined by `hitTest`.

You can read about it for example in [touchesBegan][touchesBegan] documentation:

> UIKit calls this method when a new touch is detected in a view or window. Many UIKit classes override this method and use it to handle the corresponding touch events. The default implementation of this method forwards the message up the responder chain. When creating your own subclasses, call super to forward any events that you do not handle yourself. For example,
>
> ```objc
> [super touchesBegan:touches withEvent:event];
> ```
>
> If you override this method without calling super (a common use pattern), you must also override the other methods for handling touch events, even if your implementations do nothing.

----
**Q: How do you find the current first responder?**

AFAIK there is no public API in UIKit which returns the first responder. But it is possible using this code snippet:

```swift
extension UIResponder {
    static func findFirst() -> UIResponder? {
        UIResponder._first = nil
        defer { UIResponder._first = nil }

        // sendAction without a target dispaches
        // event to the first responder, and it
        // will store itself into the
        // UIResponder._first var
        UIApplication.shared.sendAction(
            #selector(_findFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )

        return UIResponder._first
    }

    private static weak var _first: UIResponder?

    @objc private func _findFirstResponder() {
        UIResponder._first = self
    }
}
```

<small>I've known this trick for years now, but initially I've read it in [this SO answer](https://stackoverflow.com/a/21330810) by Jakob Egger.</small>

----

**Q: Do you really ever need to find the current first responder?**

I've definitely thought I needed it at some point and even used the snippet above in production. Thinking about it now, I cannot recall the reason. After carefully reading the docs while writing these notes, I've started to think that knowing the exact first responder object is not really necessary. UIKit handles responder chain automatically and dispaches events to the first responder when appropriate.

----

<!-- links -->
[UIResponder]: https://developer.apple.com/documentation/uikit/uiresponder
[UIResponder.next]: https://developer.apple.com/documentation/uikit/uiresponder/1621099-next
[becomeFirstResponder]: https://developer.apple.com/documentation/uikit/uiresponder/1621113-becomefirstresponder
[resignFirstResponder]: https://developer.apple.com/documentation/uikit/uiresponder/1621097-resignfirstresponder
[sendAction]: https://developer.apple.com/documentation/uikit/uiapplication/1622946-sendaction
[hitTest]: https://developer.apple.com/documentation/uikit/uiview/1622469-hittest
[touchesBegan]: https://developer.apple.com/documentation/uikit/uiresponder/1621142-touchesbegan

**Notes:**
