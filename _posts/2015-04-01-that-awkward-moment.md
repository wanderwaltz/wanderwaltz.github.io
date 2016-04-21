---
title: That awkward moment when `git rebase --continue`
description: "Where I complain about my inability to use the `vi` editor."
date: 2015-04-01
tags: [Git, Rebase, Vi, Editor, SourceTree, Jedi, Terminal]
---
...suddenly opens vi to update a commit message and you don't really know how to save the file and exit the goddamn editor.

No, really, I should probably learn some vi because it is kind of ridiculous to go to [Stack Overflow](http://stackoverflow.com/questions/11828270/how-to-exit-the-vim-editor) each time that happens in search for the magical keystroke. Another question is why my GUI git [client of choice](https://www.atlassian.com/software/sourcetree/overview) does not handle this situation and does not allow entering the commit message in the user interface anyway.
<!--more-->

I'm not really a terminal guy. I've been using svn and git client apps for ages now and am pretty happy about it. Yes, if I end up in a situation when the GUI is not available, and something has to be done through the terminal prompt, I'm pretty much screwed and have to google the proper commands. But that almost never happens anyway so who cares.

Almost.

Sometimes when performing a complex interactive `git rebase` SourceTree just hangs up for some reason and won't `continue` the operation however long would I wait. There was a time when that would intimidate me and make me do *abort rebase*, but these times are in the past. Now I know what that means. I have to open the terminal prompt and perform `git rebase --continue` manually. It turns out that SourceTree waits because git automatically opens `vi` prompting me for a commit message update. SourceTree apparently cannot handle this situation and display a text view for me in the GUI, so an awkward google search ensues to find the keystrokes that save the buffer and exit the editor.

A friend of mine once wrote a [to-do list](https://stkhapugin.github.io/2015/02/28/Becoming-a-Jedi.html) of becoming a tech Jedi. I'm not sure I would follow his exact list; I guess each one has a Jedi path of his own. But I think I've figured out one of the bullet points in my Jedi list - learning `vi`. I've managed to write this post entirely in `vi`, so that's a start I guess.
