module.exports = {
    debug: ({}, args) => {
        console.log(args);
    },
    reverse: ({}, val) => {
        return val.reverse();
    }
}
