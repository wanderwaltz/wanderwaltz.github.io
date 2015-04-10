---
title: Once upon an App
description: "Where I talk about an app I've been making two times already and I'm probably going for the third one."
date: 2015-04-02
tags: [Delphi, Objective-C, Windows, iOS, iPad, MMPI, JSON]
---
I was making this one app for a long time already. An app for a single user. Not really a promising venture, one might say. But this is personal. It's an app for my father which helps him do his job and which he asked me to make for him when I was still going to school.

The app is actually pretty simple. It's an implementation of a customized [Minnesota Multiphasic Personality Inventory](https://en.wikipedia.org/wiki/Minnesota_Multiphasic_Personality_Inventory)) test (MMPI for shortness) which involves the user answering 500+ yes/no questions and a lot of tedious but otherwise simple math to calculate the results.

Before the app, father was calculating these results manually, which required comparing the answers list with a bunch of template tables, calculate means, standard deviations and all that statistical stuff, which is rather simple in formulae, but is tedious to compute by hand. I was aiming to be a programmer from my early days and it's no surprise that my father asked me to make this app for him.

Well, I've made it. Two times from scratch already. And I think I'm going for the third.
<!--more-->

A long time ago in a galaxy far, far away...
-------------------------------------------

The first implementation was one of my first *complete* projects (like in '*a project, which someone besides me could comfortably use*'). It was created somewhere between 2004-2006. I don't really know the exact date because neither the source does contain any header comments similar to these created by Xcode by default, nor did I use any version control system these days. Yep, I did not even hear of version control systems yet in that time.

I still have the source though. It's Windows only and looks like this:

{% highlight delphi %}
For I:=1 to Count do
Begin
    GR:=ReadGroup('G'+IntToStr(I));
    Groups.Add(GR.Name,GR);
End;

Answers:=TAnswerList.Create;

Reg:=Nil;
Try
    Reg:=TRegistry.Create;
    Reg.RootKey:=HKEY_CURRENT_USER;
    If Reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders',False) then
    Begin
        AnsPath:=Reg.ReadString('Personal')+'\MMPI\Ответы\';
        Reg.CloseKey;
    End
    Else
        AnsPath:=AppPath+'Ответы\';
Finally
   Reg.Free;
End;
{% endhighlight %}

Ah, the glorious Delphi 6 days.

Notice the Cyrillic file paths? Well this source file does not display them properly when opened on Mac. Probably the encoding not being detected properly. This kind of stuff did not bother me those days.

I'm messing with the Windows registry in this piece of code, but I don't really remember how that works. The app was actually implemented as two separate executables - one for entering answers and another for analyzing the results. They were supposed to be on the same machine nevertheless and store the data in a shared documents folder so answers created in one app could automatically appear in another. That was the reason for messing up with the registry probably, but I'm not 100% sure.

Application data was stored in the simplest binary form I could ever think of. No format specifiers. No version numbers. Just binary representation of the application data dumped directly on disk. I've never heard of 64 bit architectures, I've never thought I would be updating this app or god forbid rewriting it to work in another platform.

Those blissful ignorant days.

The second time around
----------------------

Fast-forward several years. Surprisingly the app is still working and the registry magic survived the transition from Windows XP to Windows 7. But the result printing functionality is lacking (it exists though!) and there is some nasty division by zero bug which messes up some results. Father asks me to fix the bug, but I've never touched Delphi for a long time now and don't have a Windows machine either. I'm an iOS developer these days.

It's time to write an iOS version of the app!

Luckily father has an iPad, so he could actually use this second version. This time around iOS 5 is a new kid in the block so I use this opportunity to check out storyboards and all the new shinies which otherwise would wait at least a year until we could use them in our regular work[^1].

[^1]: That's the reality of iOS development: Apple presents new stuff each year, but businesses usually try to support one or more previous iOS versions so the shinies are either conditionally used depending on the host OS version or not used at all. In practice the stuff shown on WWDC this year will be used in our apps only a year later, and sometimes that's an optimistic estimate.

That's how MMPI app got an *i* and become [iMMPI](https://github.com/wanderwaltz/iMMPI).

Remember the binary files the previous app used to save? Making the new app able to read these was an adventure of its own. One of the fun things to recall is the fact that the dates were stored as Delphi's `TDateTime`, which is a `double` in the following [format](http://docs.embarcadero.com/products/rad_studio/delphiAndcpp2009/HelpUpdate2/EN/html/delphivclwin32/System__TDateTime.html):

>The integral part of a `System::TDateTime` value is the number of days that have passed since 12/30/1899. The fractional part of a `System::TDateTime` value is the time of day.

It's not that hard to parse, but it is kind of a strange storage format to think about.

But in the end, since I've already had a bunch of experience these days, I think I've done a pretty decent job making the iOS version. It lacks unit tests though; we were testing the app manually by comparing the results shown on display with our manual calculations. I've been thinking about adding unit tests and refactoring the app for a long time now, but for some reason did not really get to it. I've actually tried to start rewriting parts of it for the better testability, but then Swift dropped and I thought of writing a Swift version instead. I've done neither in the end, but that's a different story.

The problem with this app is that it's for iOS. A funny thing to say, but despite that I really like making iOS apps, I have never bothered to get an Apple Developer Program of my own. I've always used my employer's program when necessary. I've never published iMMPI to the App Store because of that. My father is using a build, which I've installed on his iPad using Xcode. It's a developer build and it suffers from the provisioning profile expiration problem. I have to reinstall the app on his iPad once in a while.

I don't know if I should actually get a dev program and try to publish the app to make our lives a bit easier. That's such a hassle. The app is not really suited to be in the store, it's tailored to my father's needs and there are some questionable (in general case) UI decisions made by his requests. It would be much easier to have it as a small private app, which no one ever sees besides its sole user.

Third time's a charm?
---------------------

And here I come, thinking about rewriting MMPI once more. What if I make it a browser-compatible app? It would be possible to run it on both desktop and iOS devices, not bothering about the App Store stuff. I'll have an opportunity to get some experience in web development[^2].

Rewriting the app again and again from scratch is probably a bad way to support a product, but I've learned a lot while walking this path.

[^2]: I've been thinking a lot about what would I like to do if I decide to quit iOS development whatsoever. I think web has a lot of creative opportunities, whether it would be a frontend or backend work.
