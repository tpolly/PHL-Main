This repository contains software that was used in the study "Reevaluating Passive Haptic Learning of Morse Code" (https://doi.org/10.1145/3341163.3347714). In particular, this is the main program that guides participants through the initial survey, the training and test sessions, and the final survey.

The code is only sparsely commented - as it was only intended to be used in a single study. If you want to use this, feel free to contact me.
There is no internationalization, all UI text is in German.

# Installation
Create a directory for the necessary components, this will be called $ROOT from now on.

The default directory structure looks like this (the paths for the games can be changed in the respective Distraction class):

	$ROOT
	+-[Distraction-Tasks]
	|  +-clone PHL-Gweled-src here
	|  +-Gweled-bin empty directory
	|  +-clone PHL-OpenHexagon-src here
	|  +-OpenHexagon-bin symlink to OpenHexagon-src/_RELEASE once OpenHexagon is built
	+-[PHL-Main] clone this repository here
        +-[Results] empty directory for writing the test results

## Dependencies
### Gweled

	apt install build-essential intltool libgtk2.0-dev librsvg2-dev libmikmod-dev
	./configure --prefix=$ROOT/Distraction-Tasks/Gweled-bin
	make install

Then, turn off the music in preferences

### Open Hexagon

	apt install cmake liblua5.3-dev libsfml-dev
	cd OpenHexagon-src
	cd extlibs # if it does not already exist
	git clone https://github.com/SuperV1234/SSVCMake.git
	cd ..
	cmake .
	make
	ln -s SSVOpenHexagon _RELEASE/SSVOpenHexagon

### PHL-Main

	apt install ruby ruby-dev rake
	gem install gtk3 serialport
