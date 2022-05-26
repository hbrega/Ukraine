Greeting Pilots!

What we have here, is a new pilot.

In the zip you'll find:

Pilot**.bmp
Pilot**.lod
Pilot**_lod002.lod
Pilot**.ini
Pilot_readme.txt == this file!

(where ** is the pilot designator number or name)

------
Instillaton instructions:

Unzip, if you wish, into a temporary folder. This works best.  All the files in the zip are seperate zips. This allows you to select which or how many pilots you wish to add.
Place your selections in the /StrikeFighters/Objects/Aircraft folder --do NOT place the files in specific aircraft folder!!

If you haven't extracted the data.ini for the aircraft you wish to modify, do so.
If already extracted, open up the **data.ini for your aircraft of choice. In the example below, we are using the F-100D:

Find the section marked crew, as below

// Crew ---------------------------------------------------------

[Pilot]
SystemType=PILOT_COCKPIT
PilotModelName=                <-- (left blank in this example)
Position=0.00,4.15,0.88
SeatModelName=seat_f-100
SeatPosition=0.00,3.98,0.45
MinExtentPosition=-0.25,3.52,-0.30
MaxExtentPosition= 0.25,4.83, 1.09
CanopyNodeName=canopy_frame_rear_outer

If your data ini does not have the line:

PilotModelName=

You =MUST= add it.
Then, you can add the pilot figure of choice. Remember, it is case sensitive, so if it's "PILOTAF" you must use all capitals. If it's "PilotCH", you must use the upper and lower case lettering. Adding ".lod" is NOT required.

NOTE: the Pilot**.bmp has NOT been resized. It is a very high-res texture. If space or machine specs require, I personally reccomend rezising to 256x256 or even 128x128 pixels for slower machines. BE ADVISED--this will lose detail. I've tried 512x512 on my personal POS PIII 500, and that seems about the best, other than full sized. 512 gives you a 769k bmp file, so it still fairly hefty.

Many thanks go the Deigo, who first created the pilot texture, and Pappychksix who repainted them to such beauty. All I can take credit for is editing/creating the necessary lods and inis.

If you have any problems, feel free to email me at the addy below, or post a message on the SimHQ Strike Fighter's message board.

That about covers it...now get out there, and fly!

Wrench
Kevin Stein

kjstein@comcast.net