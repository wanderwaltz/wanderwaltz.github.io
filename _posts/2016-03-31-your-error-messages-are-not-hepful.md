---
title: Your Error Messages Are Not Helpful
description: "An example of an error message popup in Xcode, which does not really help anyone."
date: 2016-03-31 11:51:00 +0600
tags: [Xcode, iOS, Error, Message, Unknown Error, Run, Device, iPhone, Install, Framework, Code Signing]
---

    An unknown error occurred

I imagine everyone has seen this error message at least once in their lives. It's not very helpful, is it?

I've encountered this error message today when trying to run an app on my iPhone using Xcode. No other explanation was provided, no ways of recovery. What should one do in this scenario?

<!--more-->

<figure class="float-center">
<img src="/images/xcode-unknown-error.png" alt="An 'unknown error occurred' dialog presented by
Xcode when trying to run an application on a device.">
</figure>

*OK Xcode, level with me, could you just tell me what the actual problem is?*

### Hello, IT. Have you tried turning it off and on again?

First thing coming to mind is just to unplug the iPhone and reconnect it again. Nope, the problem persists.

Next step is to restart the iPhone -- nope, still not working.

Restarting Xcode? - does not help. Restarting the Mac? Probably won't help too, I have not actually tried it, however.

Then I finally think about looking at the device logs. Maybe I should've really thought about it earlier and save myself a couple of minutes staring at the screen. Device logs end up being actually helpful since they contain the actual reason of the problem:

    installd[50] <Error>: 0x16e087000 -[MIInstaller performInstallationWithError:]: Verification
    stage failed
    streaming_zip_conduit[233] <Error>: 0x16e12f00
    __MobileInstallationInstallForLaunchServices_block_invoke222: Returned error Error
    Domain=MIInstallerErrorDomain Code=13 "Failed to verify code signature of /private/var/mobile/
    Library/Caches/com.apple.mobile.installd.staging/temp.bL1wVu/extracted/radio.app/Frameworks/
    YPJSONModel.framework : 0xe8008001 (An unknown eror has occurred.)"
    UserInfo={LibMISErrorNumber=-402620414, LegacyErrorString=ApplicationVerificationFailed,
    SourceFileLine=142, FunctionName=+[MICodeSigningVerifier
    _validateSignatureAndCopyInfoForURL:withOptions:error:], NSLocalizedDescription=Failed to
    verify code signature of /private/var/mobile/Library/Caches/com.apple.mobile.installd.staging/
    temp.bL1wVu/extracted/radio.app/Frameworks/YPJSONModel.framework : 0xe8008001 (An unknown
    error has occurred.)}

OK, this is something I can understand. Code signature verification failed for one of the
frameworks embedded in the app. Deleting derived data and rebuilding the whole app solved the issue.

The thing I am ranting about is why does not Xcode display this info in the error popup? I am not asking to dump the whole log excerpt there, but at least to tell me that there is a problem with code signing, is it that hard?

I admit, I am guilty of using the _'an unknown error has occurred'_ message in my apps too. This non-descript message is usually used in user-facing error popups with a not much more helpful suggestion to _'please try again later'_. However, this is done for the sake of the user -- we programmers automatically suppose that not all of our application users are that tech-savvy to understand what the actual error means, and displaying lots of internal terms would just confuse or even scare the user. Maybe this is right, maybe this is wrong, I do not really know. Sometimes _'an unknown error occurred'_ is left there just as a placeholder message to be replaced by something helpful later and this 'later' just does not ever happen.

I would think that Xcode is different, however. It is a tool for programmers who really do know what they're doing and for whom a more verbose and relevant error message would save much time and
nerves.
