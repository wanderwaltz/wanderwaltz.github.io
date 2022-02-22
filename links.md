---
title: Links
permalink: /links/
---
Here I list websites, articles and books, which I find interesting and worth looking into. I was into
gamedev a lot while studying in the university, but don't do it that much nowadays.

This page is basically a backup of my browser's bookmarks list.

<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->
{% capture books %}
- [Mobile Security Testing Guide](https://mobile-security.gitbook.io/mobile-security-testing-guide/),
- [Game Programming Patterns](https://gameprogrammingpatterns.com/contents.html).
{% endcapture %}
<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->



<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->
{% capture blogs %}

### Mac/iOS Development
- [App Store Review Guidelines History](http://www.appstorereviewguidelineshistory.com) with
    a nice diff interface
- [NSBlog](https://mikeash.com/pyblog/) by Mike Ash
- [NSHipster](http://nshipster.com/) by Mattt Thompson
- [objc.io](http://www.objc.io/) by Chris Eidhof, Daniel Eggert, and Florian Kugler

### Various
- [c2.com](http://c2.com/cgi/wiki), a wiki focused on people, projects and patterns in software
    development
- [Coding Horror](http://blog.codinghorror.com/) by Jeff Atwood
- [Nick's Blog (Damn Cool Algorithms)](http://blog.notdot.net/tag/damn-cool-algorithms) by Nick
    Johnsonz. Has not been updated for a long time, but the articles are still pretty damn cool.
- [Sutter's Mill](http://herbsutter.com), Herb Sutter on software, hardware and concurrency
- [Yegor Bugayenko's Blog](http://www.yegor256.com), a personal, very opinionated programming-related
    blog. It often seems that the author is just trolling, and as a result, comment sections are
    pure gold.
{% endcapture %}
<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->



<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->
{% capture gamedev %}

- [GameDev.net forums](http://www.gamedev.net/index)
- [NES emulation](http://wiki.nesdev.com/w/index.php/Nesdev_Wiki)
- [r/gamedev](http://reddit.com/r/gamedev)

### Blogs
- [Gamasutra Blogs](http://www.gamasutra.com/blogs/)
- [Red Blob Games](http://www.redblobgames.com/) by Amit Patel
- [Three Hundred Mechanics](http://www.squidi.net/three/) by Sean Howard

### Libraries
- [cocos2d-x](http://www.cocos2d-x.org/)
- [kiwi.js](http://www.kiwijs.org/)

### Procedural Generation
- [Chris Pound's Language Machines](http://generators.christopherpound.com/), notably the Language
    Confluxer algorithm gives some neat results. I've actually implemented it [once](https://github.com/wanderwaltz/Blogdemos/blob/master/Language%20Confluxer/Ruby/language.rb) in Ruby, and the
    names generated based on the provided dataset were actually pretty nice. I think there is room
    for improvement and maybe I'll try to figure it out someday.

### Resources
- [2d Game Art for Programmers](http://2dgameartforprogrammers.blogspot.com), "Life is too short
    to make bad art"
- [King's Bounty (1990)](http://shrines.rpgclassics.com/genesis/kingbounty/index.shtml), unit
    stats, villain stats, spell lists, manual, etc
{% endcapture %}
<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->



<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->
{% capture languages %}

### C/C++
- [awesome-cpp](http://fffaraz.github.io/awesome-cpp/), a curated list of awesome C/C++
    frameworks, libraries, resources, and shiny things
- [Cello](http://libcello.org), higher level programming in C.
- [openFrameworks](http://www.openframeworks.cc), an open source C++ toolkit for creative coding.
- [P99](http://p99.gforge.inria.fr/p99-html/index.html), preprocessor macros and functions
    for C99 and C11

### Erlang
- [awesome-erlang](https://github.com/drobakowski/awesome-erlang), a curated list of awesome Erlang
     libraries, resources and shiny things.
- [Erlang Programming Language](http://www.erlang.org/)

### JavaScript

- [awesome-javascript](https://github.com/sorrycc/awesome-javascript), a collection of awesome
     browser-side JavaScript libraries, resources and shiny things.
- [TypeScript](http://www.typescriptlang.org/), a typed superset of JavaScript that
    compiles to plain JavaScript

### Scala
- [awesome-scala](https://github.com/lauris/awesome-scala), a community driven list of useful Scala
    libraries, frameworks and software.
- [Programming in Scala, First Edition](http://www.artima.com/pins1ed/) by Martin Odersky, Lex
    Spoon, and Bill Venners

### Squirrel
*Squirrel is a high level imperative, object-oriented programming language, designed to be a
lightweight scripting language that fits in the size, memory bandwidth, and real-time
requirements of applications like video games.*

- [Squirrel homepage](http://squirrel-lang.org/)
- [SQRat](http://scrat.sourceforge.net/), Squirrel Binding Utility (C++)

### Swift

- [Swift Community](https://swift.org),
- [Swift Forums](https://forums.swift.org),
- [Silver: The Swift for .NET and Java/Android](https://www.elementscompiler.com/elements/silver/)

#### Server-side Swift

- [Kitura (IBM)](https://github.com/IBM-Swift/Kitura) is a web framework and web server that is created for web services written in Swift. For more information, visit [www.kitura.io](www.kitura.io),
- [Vapor](https://vapor.codes) is a web framework for Swift. It provides a beautifully expressive and easy to use foundation for your next website, API, or cloud project.

{% endcapture %}
<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->



<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->
{% capture problems %}

- [LeetCode Online Judge](https://leetcode.com/)
- [Project Euler](https://projecteuler.net/), features a lot of problems to solve, with lots of
    math-related problems. I [used to](https://github.com/wanderwaltz/erlang-project-euler) solve
    these in Erlang, but have not done that for a while now

{% endcapture %}
<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->



<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->
{% capture various %}
- [Algorithmic Botany](http://algorithmicbotany.org/), a selection of articles and books on
    [Lindenmayer systems](http://en.wikipedia.org/wiki/L-system) and their applications in biological
    modeling and visualizations
{% endcapture %}
<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->



<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->
{% capture web %}
## Web Design

- [Codrops](http://tympanus.net/codrops), a lot of inspiring web-related articles, tutorials, free
    resources etc
{% endcapture %}
<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->

{% include collapsed.html summary="Books" content=books %}
{% include collapsed.html summary="Blogs" content=blogs %}
{% include collapsed.html summary="Programming Languages" content=languages %}
{% include collapsed.html summary="Programming Problems" content=problems %}
{% include collapsed.html summary="Gamedev" content=gamedev %}
{% include collapsed.html summary="Web Design" content=web %}
{% include collapsed.html summary="Various" content=various %}
