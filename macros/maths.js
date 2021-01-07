module.exports = {
    sintab: ({}, len, scale) => {
        const res = Array(len).fill(0).map((v,i) => Math.round(Math.sin(2*i/len * Math.PI * 2.0) * scale));
        return res;
    },
    sinatttab: ({}, len, scale) => {
        const res = Array(len).fill(0).map((v,i) => (1/(len/2))*(i-len/2)*Math.round(Math.sin( (Math.PI/2) + (i-len/2)*(2.0*Math.PI/len*2) ) ) );
        return res;
    },    
    exp: ({}, nb, exp) => {
        return nb**exp;
    },
    int_to_bin: ({}, val) => {
        return `0b${(val >>> 0).toString(2)}`;
    },
    int_to_hex: ({}, val) => {
        return `0x${(val >>> 0).toString(16)}`;
    },
    str_to_int: ({}, val) => {
        return parseInt(val);
    }        
}
