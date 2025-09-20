---
tags:
  - Linux
  - Command line
  - bash
  - vi
  - vim
---

# Keep indentation with vi

When you when you copy-paste idented code into vi/vim, by default it tries to auto-indent every line, which messes up pasted text.  
To keep indentation as-is when pasting, you can enable paste mode with `set paste`.

To enter into paste mode:  
1. edit the file with vi  
2. by default it is in command mode, if not press Esc  
3. then enter `:set paste`  
4. move to insertion mode pressing `i`  
5. paste your code  
6. exit with `Esc+:+x`  


In summary, to keep your indentation you need to enable paste mode (Esc + `:set paste`) then move to insertion mode, paste your code, save and exit. 
 