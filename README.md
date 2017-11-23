# gordon--'s ESET Password Recovery

This commandline tool is able to crack the password needed for settings, uninstall and the "temporarily disable protection" feature.  
Since the password is stored as a hash in the registry it needs to be cracked.  
This tool implements a simple bruteforce routine, it's not optimised as f*ck, it's just a proof of concept. (Features like wordlist attacks or something are not planned, but feel free to implement it and do a pull request if you like)  


## Optional commandline arguments
-h [hash]  
&nbsp;&nbsp;If obtained this hash will be used and this tool will not search the registry
for it.

-c [charset]  
&nbsp;&nbsp;Obtain your own charset to the bruteforce routine. Default: abcdefghijklmnopqr
stuvwxyz0123456789_-

-l [length]  
&nbsp;&nbsp;Define the maximal password length for the bruteforce routine. Default: 5

-?  
&nbsp;&nbsp;Displays this help text.

The hash will be read vom the windows registry if no agruments are passed. It will be displayed, so you can write it down and use it with the -h parameter on another computer if you want.


## Changelog
0.2:
 - Win64 fix (registry redirection)


## Build
Tested on Delphi XE7 but should compile on any Version. Just open the .dproj file in the IDE and hit compile, there are no special requirements.
