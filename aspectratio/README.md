# AspectRatio
One of the things I really missed from Windower after switching over was the ability to change the game's aspect ratio that was available in the config plugin for windower. With some help from Arcon on the Windwer discord, I was able to find out where in memory the aspect ratio exists and how it is stored. So, I decided to make an addon for Ashita to allow similar functionality.

## To load and unload the addon:
```
/addon load aspectratio   # this loads the addon and will automatically set the aspect ratio to whatever is in settings/aspectratio.json
/addon unload aspectratio # this unloads the addon, but it does not revert your aspect ratio to a default one, it will change back on zoning
```

## Addon commands
```
/ar                    # the same as the help command
/ar help               # displays the help text (mainly just lists the set command)
/ar set [aspect ratio] # sets the aspect ratio of the game to your specified aspect ratio (needs to be in x:y format, e.g. 16:9)
```

## Settings
```
{
  "ratio": <string: aspectratio> # "21:9", "16:9", "123456:1" (good luck playing like that), etc.
}
```

## Known Issues
1. Aspect Ratio Changes Too Late After Zoning
    - In most zones, the game tells the server that you've zoned in before the black screen ends. In such cases the addon works fine. In some zones (Jeuno, Adoulin, Qufim, etc.) the game will display the zone before it's told the server you've zoned in. When this happens, your game will be the original aspect ratio you have chosen in the menu for ~1s and then pop back to the aspect ratio you've chosen.
