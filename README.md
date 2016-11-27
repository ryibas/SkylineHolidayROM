**Skyline Holidays NES Game**

Getting started I tried to do most of this on a Mac, but sadly many of the tools used in these types of development projects are fading to time and only available on Win machines. For those of us who remember it like yesterday, it actually turns out that the NES was released over 30 years ago....

You can still use a Mac to do most of the development, it’s just that some of the sprite editors used to create the graphics aren’t available on a Mac. If you have most of the graphics done and you just need to do the coding, using a Mac is just fine. The emulators used to run the NES ROM’s on Windows have more debugging information available and built in, which can also be useful.

**Ingredients Needed**

**PC** - Really any Windows machine will work for this.
**Visual Studio Code** - A great lightweight editor that works surprisingly well for editing assembly code.
        [https://code.visualstudio.com/](https://code.visualstudio.com/)

**Emulator (Fceux)** - This is the application you will use to actually run your NES game.
        [http://www.fceux.com/web/home.html](http://www.fceux.com/web/home.html)

**NESASM3** - This is the application that takes your source code (.asm file) and compiles it into a .nes file which can then be opened by the Fceux emulator. 
    NESASM3 Source Code [https://github.com/toastynerd/nesasm](https://github.com/toastynerd/nesasm)
    NESASM3 Application [http://www.nespowerpak.com/nesasm/NESASM3.zip](http://www.nespowerpak.com/nesasm/NESASM3.zip)

**YY CHR** - The application that can be used to create sprite images. This was used to create the letters and the little monster in the game.
    [http://www.romhacking.net/utilities/119/](http://www.romhacking.net/utilities/119/)

Keep in mind that these tools are slowly fading from the Internet and you may have to search around for links to download them or even replacements (if they exist). Also, always be prudent when downloading things from the Internet. We don't need any viruses for the holidays.

_You can find similar tools needed to run most of this on a Mac listed at the bottom of this article. Unfortunately many of these tools over the last decade or so have been lost to time and are only minimally maintained on Windows and not at all on Mac’s._

**Directions**

1.) Download the code for this project at [https://github.com/ryibas/SkylineHolidayROM](https://github.com/ryibas/SkylineHolidayROM) and extract the .zip file to a folder somewhere on your computer.

2.) Load up Visual Studio Code. You may want to install one of the 6502 Assembly extensions available. These help with syntax highlighting. Open the SkylineHolidayROM folder that you just downloaded and open up the SkylineHolidays.asm file once the folder is open. This file is the entire program, which then compiles down into your NES ROM.

3.) So now that you've taken a look at the code, you'll probably want to take a peek at the rockin' graphics of this thing. To do this open up the YY CHR program you downloaded in the ingredients and navigate to the folder where you extracted the code. Open up the holidays.chr file and you should see a screen similar to below. You can use the tool to create/modify the lettering, image, or add your own sprites to the file.

4.) Ready to compile the program! Open up a terminal/command line window and navigate to the (source) directory that the SkylineHolidays.asm file is located in. Run ‘nesasm3.exe SkylineHolidays.asm’ and if no errors come out, you’ll see a resulting ‘.nes’ file that was created. This file is the compiled version of the .asm code and the .chr sprites. If there were any compilation issues, you would see them listed in the terminal/command output.

5.) Open up the Fceux - NES emulator application and navigate to the folder where the ‘.nes’ file that was created in the previous step exists. You can then open this file and the ‘game’ will start up. You should see a ‘Happy Holiday’s’ message along with a little pink monster in the center of the screen that you can move around with arrow keys.

6.) Explore. Tweak the code, the sprites, etc.. and recompile and re-open the .nes file in the Fceux application to see your results. 