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
- [objc.io](http://www.objc.io/) by Chris Eidhof, Daniel Eggert, and Florian Kugler. Previously
  this was a blog with decent content, but for some years now the crew is doing subscription-based
  video tutorials and writing books. Still good, but not that accessible to general public now.
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

### Various
- [c2.com](http://c2.com/cgi/wiki), _a wiki focused on people, projects and patterns in software
  development_. This was _the_ first wiki site on the web as far as I understand. It has its own
  style of writing which may require some getting used to, but the content is still relevant
  nowdays
- [Coding Horror](http://blog.codinghorror.com/) by Jeff Atwood
- [Nick's Blog (Damn Cool Algorithms)](http://blog.notdot.net/tag/damn-cool-algorithms) by Nick
    Johnsonz. Has not been updated for a long time, but the articles are still pretty damn cool.
- [Sutter's Mill](http://herbsutter.com), _Herb Sutter on software, hardware and concurrency_. Mostly
  about C++
- [Yegor Bugayenko's Blog](http://www.yegor256.com), a personal, very opinionated programming-related
    blog. It often seems that the author is just trolling, and as a result, comment sections are
    pure gold.
{% endcapture %}
<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->



<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->
{% capture gamedev %}

- [NES emulation](http://wiki.nesdev.com/w/index.php/Nesdev_Wiki)

### Blogs
- [Red Blob Games](http://www.redblobgames.com/) by Amit Patel
- [Three Hundred Mechanics](http://www.squidi.net/three/) by Sean Howard

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
- [Cello](http://libcello.org), higher level programming in C.
- [openFrameworks](http://www.openframeworks.cc), an open source C++ toolkit for creative coding.
- [P99](http://p99.gforge.inria.fr/p99-html/index.html), preprocessor macros and functions
    for C99 and C11

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
    modeling and visualizations.
{% endcapture %}
<!-- -------------------------------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------------------------------- -->



{% include collapsed.html summary="Books" content=books %}
{% include collapsed.html summary="Blogs" content=blogs %}
{% include collapsed.html summary="Programming Languages" content=languages %}
{% include collapsed.html summary="Programming Problems" content=problems %}
{% include collapsed.html summary="Gamedev" content=gamedev %}
{% include collapsed.html summary="Various" content=various %}
