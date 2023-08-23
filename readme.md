# WELCOME!

Welcome to my most ambitious project yet, I know it's not much at the moment but I plan to make it big. It's a general devtools that I wanted to make to help develop your products. Many of the devtool scripts I've found out there just didn't have enough for what I wanted to test so I made this. Its rough around the edges at the moment but changes will be coming. Thank you for supporting me by downloading this and if you have any suggestions for features please let me know! If you are a developer who is fluent in NUI and want to help me make a custom UI and replace ScaleformUI from this project please reach out.

## COMMANDS

`/changeloglevel <number or string>` - number 0-5 or name
(YOU WILL NEED TO SET THIS ON FIRST RUN, DEFAULT IS 0 or DISABLED)

`/triggerevent <destination> <EventName> <args>`
(0 for server, -1 for all clients, server id for specific client)
(args separated by spaces)

`/saferestart <ResourceName>`

## Other Features:

* framework detection with exports (framework names can be adjusted/added in the config)
* EventWatcher (place any Networked Event in the config spot with the type of logging you want it to represent and it will generate a log for it. Including a visualized table for every argument)
  * NOTE: Currently Supports up to 10 arguments
* Log Level/Types include:
  * DISABLED - 0 (do not pass this for a NewLog argument)
  * ERROR - 1
  * WARNING - 2
  * INFO - 3
  * SUCCESS - 4
  * CUSTOM - 5
* Log Level is saved as a KVP so it will not reset on server restart.
* Will forward logs to discord webhook
  * Configurable max log number so you don't get spammed with Info/Success messages.
* Safe Restart
  * Safely restart any resource that has loaded assets. This command will automatically detect all assets loaded by your script and automatically delete them before restarting the script.
  * REQUIRES ACE PERMS:
    * add_ace resource.TLdevtools command.start
    * add_ace resource.TLdevtools command.stop
    * add_ace resource.TLdevtools command.restart
* NO MORE SPAM
  * In the menu there is an option to log information selected. I wrote in a catch to make sure that the same log doesn't get passed twice. I.E. if you are logging player position you will only receive one log if you are standing still, same for vehicles, if you are logging a vehicle It will only log it if a data point has changed.
* TimeStamps
  * Every log can be timestamped based on server time. This can be disabled/enabled in the config

## EXPORTS

```lua
exports.TLdevtools:NewLog(LogType <string>, Message <string>)
```

(submits a new log, automatically detects and displays the script that sent the request)

```lua
exports.TLdevtools:AceCheck(Permission <string>)
```

(SERVER ONLY: Does an Ace Permission Check and Automatically logs it on both the server and the client.)

```lua
exports.TLdevtools:getFramework()
```

(returns detected framework)

```lua
exports.TLdevtools:isFramework(FrameworkName <string>)
```

(returns if framework is equal to FrameworkName)

## DEPENDENCY

[ScaleformUI_Lua](https://github.com/manups4e/ScaleformUI/releases)
