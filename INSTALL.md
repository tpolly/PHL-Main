# Necessary components for PHL Study

# /opt/BA
Make directory as root, chown to yourself

# Make directories
 /opt/BA
 +-Distraction-Tasks
 |  +-clone Gweled-src here
 |  +-Gweled-bin empty dir
 |  +-clone OpenHexagon-src here (rename dir if needed)
 |  +-OpenHexagon-bin symlink to OpenHexagon-src/_RELEASE
 +-clone User-Interface here

# Dependencies
## Gweled
apt install build-essential intltool libgtk2.0-dev librsvg2-dev libmikmod-dev
./configure --prefix=/opt/BA/Distraction-Tasks/Gweled-bin
make install
turn of music in preferences

## Open Hexagon
apt install cmake liblua5.3-dev libsfml-dev
cd OpenHexagon-src
cd extlibs # if it does not already exist
git clone https://github.com/SuperV1234/SSVCMake.git
cd ..
cmake .
make
ln -s SSVOpenHexagon _RELEASE/SSVOpenHexagon

## User-Interface
apt install ruby ruby-dev rake
gem install gtk3 serialport
