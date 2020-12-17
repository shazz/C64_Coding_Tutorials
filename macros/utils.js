module.exports = {
    debug: ({}, args) => {
        console.log(args);
    },
    reverse: ({}, val) => {
        return val.reverse();
    },
    ascii_to_byte: ({}, text, offset) => {
        // var text_without_space = text.split(' ').join('@');
        // const res = Array(text_without_space.length).fill(0).map((v,i) => text_without_space.charCodeAt(i) - offset);
        const res = Array(text.length).fill(0).map((v,i) => text.charCodeAt(i) - offset);
        return res;
    }
}
