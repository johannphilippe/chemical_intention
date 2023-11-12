# Chemical intention 

This generative music installation is made with Csound. 
It can take advantage of any number of speakers, and run forever.
It is available to download [here](github.com/johannphilippe/chemical_intention).
It can be performed in two ways :
* Played within a web browser with the Csound web IDE
* Downloaded and played locally on a computer with OS supporting Csound (OSX, Linux, Windows).

It is intended to be very easy to set up and run : 
* Simple "play" clic for the web version (demo version)
* Only Csound installation is required for local version (the original version)

## A musical automaton for public spaces

As a public space installation, this work can be played everywhere, with any speaker configuration : exhibition hall, railway station, virtual space online, concert hall (...). 
Since it is an algorithmic automaton, it will generate different results every time it is run. 

## Configure 

In the project, you will find a file named `config.orc`.
This file might need to be slightly modified so the installation may fit the correct layout.
This configuration will enable or disable features, such as plugin opcodes, binaural mode (...).  

### Plugin Opcodes

Plugin opcodes can be turned out by commenting the line `#define ENABLE_PLUGINS ##`. It will allow the installation to run with Csound only (no other dependency). 
If you want to enable the plugins, you will need to : 
- Download and install [HYPERCURVE](github.com/johannphilippe/hypercurve)
- Download and install [lua_csound](https://framagit.org/johannphilippe/lua_csound)

### Binaural 
To enable Binaural mode, uncomment the line `#define BINAURAL ##`.
Binaural in this project is made from six virtual sources around listener. 
When enabling binaural mode, you might also need to set `nchnls` variable to `2`. 

### Multichannel 
To enable multichannel (or stereo) mode, comment the `#define BINAURAL` and set `nchnls` variable to the number of speakers you use (it must be more than 1). 
Please note that more channels will increase CPU load, as well as modify the speed of sound trajectories in space, since spatialization is made of speaker trajectories.
In a multichannel layout, there is no importance on the actual speaker physical layout (which speaker is 1 or 2 or 3), since there is no font/rear concept in this installation.

## Play Chemical Intention online

Simply follow the following steps : 
- [Go to the link](https://ide.csound.com/editor/SPfWPuQKEW8XRZtDHfOL)
- Click on the play button

Note that Web version might modify slightly the way synthesis is produced, due to the locked sample rate (44100) of the IDE.
There are some small changes to the code, due to web IDE limitations. 
Thus, it must be considered as a demo version.  

## Play Chemical Intention locally

- Download the [project](github.com/johannphilippe/chemical_intention) 
- Download and install Csound v6.18 or above - [link](https://csound.com/download.html) following the official instructions.
- Edit `config.orc` (see Configure section above)
- Open a terminal and navigate to the downloaded project
- `cd chemical intention`
- `./start.sh` (MaxOS or Linux) or `csound main.csd` (Windows)
