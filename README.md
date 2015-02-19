# javawindowsinstallerdemo
Java Gui Maven Shade Launch4j NSIS Windows Installer Demo

This project is to demonstrate that using open source technologies we can build a neat windows installer for Java applications, that are typically required for standalone (Swing/Gui based) programs. 

Usually, batch or shell scripts are used for performing setup related tasks for Java GUI applications but if there is going to be future patch releases, a lot of configuration in the setup then a windows style wizard will certainly ease the life to a great deal.

The scripting language used by NSIS lets you do a lot of things, so your installation can be as complex as setting up Norton AV software, or as simple as just copying a couple of files to a directory. The best source for describing all the functions and capabilities of NSIS is in Nullsoft's NSIS User Manual. It lists all of the features available, so if you have any specific requirements for installing your program, be sure to check it out. But if your requirements are pretty much in align with mine you can get away with reusing my scripts. 

NSIS Main Website  - http://nsis.sourceforge.net/Main_Page <br>
NSIS User's Manual - http://nsis.sourceforge.net/Docs/Contents.html 

Alternatively, there are some commercial products such as Advanced Installer and Install4j which let you create windows installers for Java projects but if you wish to use purely open source technologies then please continue reading. 

To summarise the requirements:
-----
1. Easy to use Windows installation wizard for the user to install the Java standalone/Gui software.
2. Install types - The installation wizard should give user options to either do a full installation (clean install) or a patch install (future updates, only application source code is updated but existing configuration is retained).
2. Configuration - allow the user to configure the application during the installation.
3. Start the process - The installation wizard to check and stop any running Java process, apply new configuration and restart the Java process so the new application is ready to use. 


Let's get started…

Required stack
-----
1. Maven installed
2. Launch4J and Shade Maven plugins
5. NSIS software installed and required .nsh scripts copied from '/NSIS Includes' to 'Includes' folder of NSIS

Steps to build
----
1. To build the application, run “mvn package”. This will generate the executable .exe file for the project. 
2. The next step is to run NSIS scripts which will make use of this executable and create the installer file that should be distributed to the end user. 
3. Run the Configure.nsi script first, this generates Configure.exe file which can be used by the user to configure the application.
4. Run the Setup.nsi script to generate the final installer file. 

