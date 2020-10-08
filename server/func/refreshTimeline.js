const { query } = require('express');
const db = require('./db_connection.js');

process.on("message", message => {
    db.conn.getConnection(async (err, connection) => {
        if (err) {
            return console.error("error: " + err.message);
        }

        await refreshTimeline(message.profileID, message.offset, connection).then((answer) => {
            connection.release();
            process.exit();
        });
        // process.send({ "result": result });
        // connection.release();
    });
    // process.exit()
});

refreshTimeline = async (profileID, offset, connection) => {
    var getNumPosts = "SELECT profile_id, COUNT(*) FROM user_post WHERE profile_id = " + String(profileID);
    var query = "SELECT * FROM user_post WHERE profile_id = " + String(profileID) + " ORDER BY creation_date DESC LIMIT " + String(offset) + ", 3"; // change if condition below if you change limit
    return new Promise(async (resolve, reject) => {
        await connection.query(getNumPosts, async (err, result) => {
            if (err) {
                console.log(err);
                throw err;
            }
            result = JSON.stringify(result);
            // result = JSON.parse(result);
            var numOccurances = result.substring(28, result.indexOf("}"));
            if (offset >= numOccurances - 2) { // change if you change limit
                var limit = numOccurances - offset;
                var newquery = "SELECT * FROM user_post WHERE profile_id = " + String(profileID) + " ORDER BY creation_date DESC LIMIT " + String(offset) + ", " + String(limit); // change if condition below if you change limit
                await connection.query(newquery, (err, result) => {
                    if (err) {
                        console.log("error: " + err.message);
                        throw err;
                    }
    
                    result = JSON.stringify(result);
                    result = JSON.parse(result);
                    // var list = [];
                    // for (i = 0; i < length(result); i++) {
    
                    // }
                    var dict = {
                        "result": result,
                        "error": 1
                    }
                    process.send({ "result": dict});
                    console.log(result);
                    return result;
                });
            } else {
                await connection.query(query, (err, result) => {
                    if (err) {
                        console.log("error: " + err.message);
                        throw err;
                    }
    
                    result = JSON.stringify(result);
                    result = JSON.parse(result);
                    // var list = [];
                    // for (i = 0; i < length(result); i++) {
    
                    // }
                    var dict = {
                        "result": result,
                        "error": 0
                    }
                    process.send({ "result": dict});
                    console.log(result);
                    return result;
                });
            }
            return result;
        });
    });
};