module.exports = {
    sintab: ({}, len, scale) => {
        const res = Array(len).fill(0).map((v,i) => Math.round(Math.sin(i/len * Math.PI * 2.0) * scale));
        return res;
    },
    exp: ({}, nb, exp) => {
        return nb**exp;
    },
    int_to_bin: ({}, val) => {
        return `0b${(val >>> 0).toString(2)}`;
    }    
}
