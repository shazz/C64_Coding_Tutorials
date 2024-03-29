module.exports = {
    debug: ({}, args) => {
        console.log(args);
    },
    get_fade_table: ({}, start, nb_elements) => {
        const fade_2_black_chain = [0x00, 0x0d, 0x09, 0x0c, 0x02, 0x08, 0x00, 0x0f, 0x02, 0x00, 0x08, 0x09, 0x04, 0x03, 0x04, 0x05];
        var fade = Array(nb_elements).fill(0);
        var col = start;

        for (var i = 0; i < nb_elements; i++) {
            col = fade_2_black_chain[col];
            fade[i] = col; 
        }
        return fade
    },
    reverse: ({}, val) => {
        return val.reverse();
    },
    ascii_to_byte: ({}, text, offset) => {
        const res = Array(text.length).fill(0).map((v,i) => text.charCodeAt(i) - offset);
        return res;
    },
    generate_dd00: ({}, bank_start) => {
        var reg = 0;
        if (bank_start == 0) {
            reg = 0b11;      
        } else if (bank_start == 0x4000) {
            reg = 0b10;          
        } else if (bank_start == 0x8000) {
            reg = 0b01;          
        } else if (bank_start == 0xC000) {
            reg = 0b00;      
        } else {
            console.log("Unknown bank!", bank_start);
        }
        return reg;                                    
    },
    generate_dd02: ({}, bank_start) => {
        var reg = 0;
        if (bank_start == 0) {
            reg = 0b00;      
        } else if (bank_start == 0x4000) {
            reg = 0b01;          // reverse from d000
        } else if (bank_start == 0x8000) {
            reg = 0b10;         // reverse from d000      
        } else if (bank_start == 0xC000) {
            reg = 0b11;      
        } else {
            console.log("Unknown bank!", bank_start);
        }
        return reg;                                    
    },
    generate_full_dd02: ({}, bank_start) => {
        var reg = 0;
        if (bank_start == 0) {
            reg = 0x3c;      
        } else if (bank_start == 0x4000) {
            reg = 0x3d;          // reverse from d000
        } else if (bank_start == 0x8000) {
            reg = 0x3e;         // reverse from d000      
        } else if (bank_start == 0xC000) {
            reg = 0x3f;      
        } else {
            console.log("Unknown bank!", bank_start);
        }
        return reg;                                    
    },
    generate_d018: ({}, charmem, bitmap, screenmem) => {
        var reg = 0;
        const mapping_charmem = {
            0x0000: 0b000,
            0x0800: 0b001,
            0x1000: 0b010,
            0x1800: 0b011,
            0x2000: 0b100,
            0x2800: 0b101,
            0x3000: 0b110,
            0x3800: 0b111
        };
        const mapping_bitmap = {
            0x0000: 0b000,
            0x2000: 0b100
        }; 
        const mapping_screenmem = {
            0x0000: 0b0000,
            0x0400: 0b0001,
            0x0800: 0b0010,
            0x0C00: 0b0011,
            0x1000: 0b0100,
            0x1400: 0b0101,
            0x1800: 0b0110,
            0x1C00: 0b0111,
            0x2000: 0b1000,
            0x2400: 0b1001,
            0x2800: 0b1010,
            0x2C00: 0b1011,
            0x3000: 0b1100,
            0x3400: 0b1101,
            0x3800: 0b1110,
            0x3C00: 0b1111
            
        };
        // console.log(charmem, mapping_charmem[parseInt(charmem)]);
        // console.log(bitmap, mapping_bitmap[bitmap]);
        // console.log(screenmem, mapping_screenmem[screenmem]);
        reg = ((mapping_charmem[charmem] << 1) | (mapping_bitmap[bitmap] << 1) | (mapping_screenmem[screenmem] << 4));
        return reg; 
    }
}
