[Sparkle Loader Script]

Path:	SparkleTest.d64
Header:	TRSi
ID:	disk1
Name:	SparkeTest
Start:	1e00
DirArt:	sequencer\dirart.txt
IL0:	05
IL1:	03
IL2:	03
IL3:	03
ZP:	10
Loop:	1

Script:	sequencer\sequencer.sls

Align
File:	part1\bin\charset.prg	0801	0002	0153
File:	part1\data\charset_40s_5x4_padded.bin	7000
File:	part1\bin\charset.prg	4000	3801

File:	part2\bin\bitmap.prg	0801	0002	005a
File:	part2\data\arsenic_0_bitmap.bin	2000	0000	1b80
File:	part2\data\arsenic_0_screenmem.bin	3c00
File:	part2\data\arsenic_0_colorram.bin	d800
File:	part2\bin\bitmap.prg	c500	bd01
