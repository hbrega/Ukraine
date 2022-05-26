To install, simply copy the two files to your SF or WoV sounds folder.  Next, you must modify the aircraft's existing avionics.ini file,as follows:

Open up the aviaonics.ini, and change the following two lines under the [RWR] header to match...

TrackSound=MiGRWRS.wav
LockSound=MiGRWRL.wav

*NOTE* The default MiGs in both SFP1 & WoV do not have an avionics.ini.  You must create one and reference it (and the avionics60.dll file) from the aircraft's aircraft.ini file.

First, an example of a simple avionics.ini. As an example, we'll create one for the MiG-17F.  Cut and paste the text between the dotted lines into wordpad, and name it "MiG-17F_AVIONICS.INI". Save it in the MiG-17F folder.
*****************************************************************
[TextureData]
;RadarTexture=cockpit\f-4c_radar.bmp
RWRTexture=cockpit\f-4e_rwr.bmp

[RWR]
Type=3_RING
AirSearchTexture=RWRair1.tga
AirTrackTexture=RWRair2.tga
AirLockTexture=RWRair2.tga
GroundSearchTexture=RWRground1.tga
GroundTrackTexture=RWRground2.tga
GroundLockTexture=RWRground2.tga
SearchPosition=0.90
TrackPosition=0.55
LockPosition=0.15
SearchSize=0.075
TrackSize=0.075
LockSize=0.075
SearchFlash=FALSE
TrackFlash=TRUE
TrackFlashRate=0.2
LockFlash=TRUE
LockFlashRate=0.1
TrackSound=MiGRWRS.wav
LockSound=MiGRWRL.wav

[RWRTrackSound]
Priority=HIGH
3DSound=FALSE
Looped=TRUE
NumBuffers=1

[RWRLockSound]
Priority=HIGH
3DSound=FALSE
Looped=TRUE
NumBuffers=1
*****************************************************************

Next, we need to reference it from the MiG-17F.ini file.  Open that up and edit the [AircraftData] section to include a reference to the Avionics Data and DLL files like so (the last two lines):

[AircraftData]
AircraftFullName=MiG-17F Fresco-C
AircraftDataFile=MiG-17F_data.ini
CockpitDataFile=F-100D_cockpit.ini
AvionicsDataFilename=MiG-17F_AVIONICS.INI
AvionicsDLL=Avionics60.dll
LoadoutFile=MiG-17F_loadout.ini

Save the changes, make sure the file is saved in the aircraft's folder.

When you hear a beeping tone, you're being painted.  As the scan narrows, the beeps will come in a faster interval.  When you hear a solid, low warbling sound, you're in a world of hurt!

Enjoy!

Fubar512