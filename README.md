# Intel 3700N + Archlinux + Kodi + Steam + RetroArch
This is a writeup of my HTPC setup inspired by [this gist](https://gist.github.com/SierraNL/8837b787bb0905a709d0).
Although eventually almost none of the tips there applied to my setup, I wished they had and I hope these tips might help someone else in a similar situation like me.
I have always tried to keep the software installation as minimal as possible.
This means that I have avoided installing any display managers or desktop environments.
Window managers (ratpoison or openbox) are only run when needed.

## Hardware
|Type|Model|Extras|
|---|---|---|
|Mainboard|ASRock N3700-ITX||
|RAM|8GB Crucial DDR3-1600 SO-DIMM||
|SSD|128GB SanDisk Z400s 2.5"||
|HDDs|2x 2 Terabyte WD Green WD20EZRX||
|Case|Inter-Tech Mini ITX E-i7|includes 90 Watt PSU|
|WiFi|dodocool AC600 WiFi Adapter|Dual Band|
|Keyboard|Rii MINI i10 Wireless 2,4G||
|Remote Control|Rii Mini i7||
|Optical Drive|External LG DVD RW drive|No space left inside case for an internal drive|
|Controllers|4x Xbox 360 Wireless Gamepads||

### Assembly
* If you add 2 3.5 inch HDDs like me, you MUST remove the case's external SATA and Molex connectors. But who uses these anyways?
* Use the correct slot if you only install 1 bank of RAM
* The case's power button LEDs are very bright. I added 2 1kO resistor in front of each of the LEDs, but it could still be darker.

## Software
I won't describe the basic setup of an Archlinux system here.
But after you have one up and running on your HTPC, you might want to take a look at my [packages list](packages).
It contains a list of packages that can help you get the best out of your htpc.
The following sections deal with each of the problems/goals I had when setting up my box and how I solved/achieved them.

### WiFi
The Dodocool usb dongle was advertised with having Linux support.
Therefore I expected it to "just work" when plugged in.
Of course, this isn't the case, since the mainline kernel does not (yet?) support this dongle out of the box.
But still, I was positively surprised that the included CD had a folder containing a Linux driver.
Of course I didn't want to make use of the binary blob in there, but the added PDF files at least told me that the dongle's chipset is Mediatek's mt7610u.
If you search on google, you will find several github repositories containing an open source driver for this chipset.
As an experienced arch user, one naturally looks for a pre-packaged version of it in the AUR.
There I went with the package [`mt7610u_sta-dkms-git`](https://aur.archlinux.org/packages/mt7610u_sta-dkms-git/), since dkms is the way to go for external drivers.

Now the dongle was detected and I could concentrate on setting it up.
I found that I had the `netctl` package already installed as part of the `base` package group, so I went with it.
The setup process is simply:
* Add a config file to `/etc/netctl` or copy one from `/etc/netctl/examples` that matches your intended configuration
* Execute `sudo netctl start <your config filename>`
* Execute `sudo netctl enable <your config filename>` to run it on boot
This of course is a very simple setup which only handles one single connection.
But since the htpc is stationary anyways, that's just enough.
You can have a look at [`/etc/netctl/ra0`](etc/netct/ra0) to see my config file.
`ra0` was the name assigned to my dongle.
I also assigned a static IP to the HTPC as can be seen from the config file.

### Sound
Personally, I do not need sound outputs any other than the one over HDMI to my TV.
That's why I can live without Pulseaudio and its excellent support for multiple sinks.
Instead, I use plain old ALSA, which has the added benefit of being less resource hungry than pulse.
Take a look at my [`/etc/asound.conf`](etc/asound.conf) to see how to set a single card's default device (also referred to as PCH, I think?).
You can find the name of your device by running `aplay -L`.

### HDD Idle
Western Digital drives may cause trouble with the basic tool `hdparm` since they respond to certain parameters differenlty than expected or they don't respond at all.
But don't worry, I found using `hd-idle` (which is in the official repos) much simpler anyways and also more reliable.
The only cost of this is having another daemon running in the background.

### NFS
This is fairly straight forward, but I thought I should still mention it.
I have the config files for my setup in this repository.

### Kodi: Mount External Drives Automatically
Install the  `udisks` package.
Kodi does not seem to work with `udisks2` yet, but I still have it installed, so a Kodi update in the future can take advantage of it.
You will also need to [configure Polkit](etc/polkit-1/rules.d/50-udisks.rules/50-udisks.rules) (needs a restart to take effect).
My configuration file grants all members of the `storage` group permission to mount devices, so make sure your `kodi` user is a member of this group.

### Controllers and Games
I immediately install the userspace driver `xboxdrv` on all of my systems, so it could be that I have missed improvements in the official drivers.
But in the past I found this driver a much better experience than Linux' own drivers.
Don't forget to add the extra 2 `next-controller = true` in [/etc/default/xboxdrv](etc/default/xboxdrv) if you want to be able to use 4 controllers.

### The Window Manager Trick
Some external applications might behave weirdly without a window manager.
One example for this are Chrome, which does not seem to use the whole screen if started without a running WM.
Another example is RetroArch which does not return keyboard focus to kodi after exit.
You will find several wrapper scripts for these applications in [`/var/lib/kodi`](var/lib/kodi).
Most of the time, you can directly set the launch command for an application inside the respective Kodi plugin.
The method of wrapper scripts has 2 benefits:
1. You can edit the scripts and play around with different start options with your favorite editor instead of Kodi.
2. Sending `kill -SIGSTOP` to Kodi before launching your application should in theory free up CPU/GPU resources, since it is essentially halted while you are inside your other app.

### Chrome
The file [`/var/lib/kodi/.config/google-chrome/Default/Preferences`](var/lib/kodi/.config/google-chrome/Default/Preferences) only contains the `window_placement` key, since this is the only issue I encountered using chrome with the chrome-launcher addon.
It might also help to run chrome alongside a window manager for the initial setup.

### Retroarch
My retorarch config ([`/var/lib/kodi/.config/retroarch/retroarch.cfg`](var/lib/kodi/.config/retroarch/retroarch.cfg)) can be found in its complete form in this repo.
The only culprit on ArchLinux is that the official packages for libretro-cores install the .so files into directories other than expected by Kodi.
So you want to make sure that the config contains `/usr/lib/libretro/` as core path and `/usr/share/libretro/info` as info path.
This is also documented in the [Arch Wiki](https://wiki.archlinux.org/index.php/RetroArch#No_cores_found).

### Steam
Run Steam with the `-windowed` flag for the initial setup.
Otherwise, steam might run in a frame which is smaller than your screen but its UI might still expand over the size of this frame, making it nearly impossible to navigate the ui.
After the initial setup (Settings > Resolution), you can remove this flag again.
I also set up a [pre-launch script](var/lib/kodi/pre-steam.sh) in the Steam launcher plugin.
This makes sure that incompatible libraries are deleted from the Steam installation every time you try to start it, so updates to the Steam client won't break it again.

### Other config files in this repo
I encourage you to try the default config of the respective programs.
Maybe they are already adapting to your setup and the changes between yours and mine.
But if you run into any troubles, feel free to have a look at the config files in this repo.

### WIP
* RetroArch performance should be improved

## Hardware Limitations
### Dolphin-Emu
I couldn't get Dolphin-Emu to work in an acceptable manner, so I think it is simply too demanding for the Intel integrated graphics.
If someone convinces me this is not the case (by showing me how to make it work), I would be happy, but I think you should know that it's probably not gonna work before getting your HTPC.
