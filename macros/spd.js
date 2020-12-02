// SPD file format information
// bytes 00,01,02 = "SPD"
// byte 03 = version number of spritepad
// byte 04 = number of sprites
// byte 05 = number of animations
// byte 06 = color transparent
// byte 07 = color multicolor 1
// byte 08 = color multicolor 2
// byte 09 = start of sprite data
// byte 73 = 0-3 color, 4 overlay, 7 multicolor/singlecolor
// bytes xx = "00", "00", "01", "00" added at the end of file (SpritePad animation info)
module.exports = ({readFileSync, resolveRelative}, filename) => {
    const buf = readFileSync(resolveRelative(filename));
    const numSprites = buf.readUInt8(4)+1;
    const data = [];
    const colors = [];
    for (let i = 0; i < numSprites; i++) {
        const offs = i*64+9;
        const bytes = [];
        for (let j = 0; j < 64; j++) {
            bytes.push(buf.readUInt8(offs + j));
        }
        data.push(bytes);
        colors.push(0x0f & buf.readUInt8(8+(64*(i+1))));
        // console.log("color at", 8+(64*(i+1)), buf.readUInt8(8+(64*(i+1))));
    }
    console.log(colors);
    console.log("Multicolor 1:" + buf.readUInt8(7));
    console.log("Multicolor 2:" + buf.readUInt8(8));
    return {
        numSprites,
        enableMask: (1<<numSprites)-1,
        colors,
        bg: buf.readUInt8(6),
        multicol1: buf.readUInt8(7),
        multicol2: buf.readUInt8(8),
        data
    };
}
