Battery_Indicator
=================

This is a minimalist tray battery indicator for Linux created in Eiffel. It 
is functionnal on a MacBookPro 7.1 using Linux Ubuntu 14.04 on an Awesome 
window manager. It should be easy to adapt to your need. See the 
{BATTERY_PROTOCOL} class.

Installation
------------

To install, you will need EiffelStudio. Also, Eiffelstudio's binaries must be in you
PATH. The following command shoud give you an EiffelStudio version string. The program
has been compile with EiffelStudio 13.11, but it should work with other version too.

***

    ec -version

***

From here, the compilation is quite easy. Get and compile:

***

    git clone --recursive https://github.com/tioui/Battery_Indicator.git
    cd Battery_Indicator/project/
    ec -finalize -c_compile -config battery_indicator.ecf

***

The generated binary file should be in the "EIFGENs/battery_indicator/F_code" directory.
It is call "battery_indicator". You can move it in you PATH. For exemple, you can do:

***

    sudo mv EIFGENs/battery_indicator/F_code/battery_indicator /usr/local/bin/

***
