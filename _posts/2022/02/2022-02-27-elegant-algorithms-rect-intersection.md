---
title: "Elegant algorithms: 2D rectangle intersection"
description:
date: 2022-02-27 01:50:00 +0700
tags: [Algorithms, Elegant Algorithms, Geometry, Pictures Needed]
---

I admire the elegance of the 2D axis-aligned rectangle intersection algorithm[^1].

Let's suppose we have a `Rect` type which represents an axis-aligned rectangle on a 2D plane. This rectangle can be represented as following[^2]:

```swift
struct Rect {
    let minX: Double
    let maxX: Double

    let minY: Double
    let maxY: Double
}
```

If two shapes do not intersect on a 2D plane, then there exists a line which can separate these two shapes. If you draw this line on the plane, one shape will be entirely on the one side of the line and other shape will be on the other side of the line.

In case of the axis-aligned rectangles this separation line is parallel to either `X` or `Y` axis[^3]. So the check becomes the following:

```swift
func areIntersecting(_ r1: Rect, _ r2: Rect) -> Bool {
    let separatedOnXAxis = r1.maxX < r2.minX || r2.maxX < r1.minX
    let separatedOnYAxis = r1.maxY < r2.minY || r2.maxY < r1.minY
    return !separatedOnXAxis && !separatedOnYAxis
}
```

----

**Notes:**

[^1]: Checking whether two axis-aligned rectangles intersect on a 2D plane was a formiddable task for me when I've started learning programming back in school. The only thing I could come up by myself then was checking whether one of the vertices of one rectangle is contained in another. That involved checking all four of the vertices, and then maybe switching the rectangles and checking again just to be sure.

[^2]: This and the following code examples are in Swift. If you're familiar with Apple's `CoreGraphics` framework, think of `CGRect`. It's declaration is a bit different than the `Rect` I'm using here, but the `minX`/`maxX` etc. properties are there.

[^3]: This is really obvious when you're drawing this stuff on a piece of paper. Note to self: add some pictures here.
