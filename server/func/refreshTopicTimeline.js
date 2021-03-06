//const { query } = require('express');
const db = require('./db_connection.js');

process.on("message", message => {
    db.conn.getConnection(async (err, connection) => {
        if (err) {
            // connection.release();
            return console.error("error: " + err.message);
        }

        refreshTopicTimeline(message.topicID, message.offset, message.time, connection).then((answer) => {
            connection.release();
            console.log("Exiting process: " + process.pid);
            process.exit();
        });
        // process.send({ "result": result });
        // connection.release();
    });
    // process.exit()
});

refreshTopicTimeline = async (topicID, offset, time, connection) => {

    var getOffset;
    var isTimeNull = false;

    console.log(time);

    if(time == null){
        // getOffset = `SELECT COUNT(*) as offs FROM user_post WHERE profile_id in ${followingListString} ORDER BY creation_date DESC`;
        isTimeNull = true;
        
    }

    var getNumPosts = "SELECT COUNT(*) FROM user_post WHERE topic_id=" + String(topicID);

    return new Promise(async (resolve, reject) => {
        await connection.query(getNumPosts, async (err, result) => {
            if (err) {
                console.log(err);
                reject(err.message);
            }
            result = JSON.stringify(result);
            // result = JSON.parse(result);
            var numOccurances = result.substring(28, result.indexOf("}"));
            if (isTimeNull) {

                var query = "SELECT * FROM user_post WHERE topic_id=" + String(topicID) + " ORDER BY creation_date DESC LIMIT " + String(offset) + ", 10"; // change if condition below if you change limit
                var newQuery = "SELECT * FROM user_post as up, profile as p where (up.topic_id = " + String(topicID) +") and up.profile_id = p.profile_id ORDER BY creation_date DESC LIMIT " + String(offset) + ", 10";
                await connection.query({ sql: newQuery, timeout: 7000 }, (err, result) => {
                    if (err && err.code === 'PROTOCOL_SEQUENCE_TIMEOUT') {
                        var dict = {
                            "error": 2
                        }
                        process.send(dict);
                        throw new Error('Request timed out after 15 seconds');
                    }
                    if (err) {
                        console.log("error: " + err.message);
                        reject(err.message);
                    }

                    result = JSON.stringify(result);
                    result = JSON.parse(result);
                    // var list = [];
                    // for (i = 0; i < length(result); i++) {

                    // }
                    var timeDiff = "";
                    var timeDiffList = [];
                    var currentDate = new Date();
                    console.log(currentDate.getDay())
                    for (var i = 0; i < result.length; i++) {
                        var postDate = new Date(result[i]['creation_date']);
                        if (currentDate.getDay() - postDate.getDay() > 1) {
                            timeDiff = (currentDate.getDay() - postDate.getDay()) + " days ago";
                        }
                        else if (currentDate.getHours() - postDate.getHours() > 1) {
                            timeDiff = (currentDate.getHours() - postDate.getHours()) + " hours ago";
                        }
                        else if (currentDate.getMinutes() - postDate.getMinutes() > 1) {
                            timeDiff = (currentDate.getMinutes() - postDate.getMinutes()) + " min. ago";
                        }
                        else if (currentDate.getSeconds() - postDate.getSeconds() > 1) {
                            timeDiff = (currentDate.getSeconds() - postDate.getSeconds()) + "s ago";
                        }
                        timeDiffList.push(timeDiff);
                    }
                    var dict = {
                        "result": result,
                        "timeDiff": timeDiffList,
                        "error": 0
                    }
                    process.send(dict);
                    console.log("Query completeeeeee");
                    // connection.release();
                    resolve(result);
                });

            }
            
            var getOffset = `SELECT COUNT(*) as offs FROM user_post WHERE topic_id=${topicID} AND creation_date > ${time} ORDER BY creation_date DESC`;

            // GET FOLLOWING LIST
            await connection.query({ sql: getOffset, timeout: 7000 }, [time], async (err, result) => {


                if (err) {
                    reject(err.message)
                }
                // result = JSON.stringify(result);
                // result = JSON.parse(result);
                console.log("result is .....");
                console.log(result[0].offs);
                console.log(offset);
                offset = parseInt(result[0].offs) + parseInt(offset);
                console.log(offset);

                if (offset >= numOccurances - 9) { // change if you change limit
                    var limit = numOccurances - offset;
                    var newquery = "SELECT * FROM user_post WHERE topic_id=" + String(topicID) + " ORDER BY creation_date DESC LIMIT " + String(offset) + ", " + String(limit); // change if condition below if you change limit
                    var newQuery2 = "SELECT * FROM user_post as up, profile as p where (up.topic_id = " + String(topicID) +") and up.profile_id = p.profile_id ORDER BY creation_date DESC LIMIT " + String(offset) + ", " + String(limit);
                    await connection.query({ sql: newQuery2, timeout: 7000 }, (err, result) => {
                        if (err && err.code === 'PROTOCOL_SEQUENCE_TIMEOUT') {
                            var dict = {
                                "error": 2
                            }
                            process.send(dict);
                            reject('Request timed out after 15 seconds');
                        }
                        if (err) {
                            console.log("error: " + err.message);
                            reject(err.message);
                        }

                        result = JSON.stringify(result);
                        result = JSON.parse(result);
                        // var list = [];
                        // for (i = 0; i < length(result); i++) {

                        // }
                        var timeDiff = "";
                        var timeDiffList = [];
                        var currentDate = new Date();
                        console.log(currentDate.getDay())
                        for (var i = 0; i < result.length; i++) {
                            var postDate = new Date(result[i]['creation_date']);
                            if (currentDate.getDay() - postDate.getDay() > 1) {
                                timeDiff = (currentDate.getDay() - postDate.getDay()) + " days ago";
                            }
                            else if (currentDate.getHours() - postDate.getHours() > 1) {
                                timeDiff = (currentDate.getHours() - postDate.getHours()) + " hours ago";
                            }
                            else if (currentDate.getMinutes() - postDate.getMinutes() > 1) {
                                timeDiff = (currentDate.getMinutes() - postDate.getMinutes()) + " min. ago";
                            }
                            else if (currentDate.getSeconds() - postDate.getSeconds() > 1) {
                                timeDiff = (currentDate.getSeconds() - postDate.getSeconds()) + "s ago";
                            }
                            timeDiffList.push(timeDiff);
                        }
                        var dict = {
                            "result": result,
                            "timeDiff": timeDiffList,
                            "error": 1
                        }
                        process.send(dict);
                        console.log("Query Complete");
                        // connection.release();
                        resolve(result);
                    });
                }
                else {

                    var query = "SELECT * FROM user_post WHERE topic_id=" + String(topicID) + " ORDER BY creation_date DESC LIMIT " + String(offset) + ", 10"; // change if condition below if you change limit
                    var newQuery3 = "SELECT * FROM user_post as up, profile as p where (up.topic_id = " + String(topicID) +") and up.profile_id = p.profile_id ORDER BY creation_date DESC LIMIT " + String(offset) + ", 10";
                    await connection.query({ sql: newQuery3, timeout: 7000 }, (err, result) => {
                        if (err && err.code === 'PROTOCOL_SEQUENCE_TIMEOUT') {
                            var dict = {
                                "error": 2
                            }
                            process.send(dict);
                            throw new Error('Request timed out after 15 seconds');
                        }
                        if (err) {
                            console.log("error: " + err.message);
                            reject(err.message);
                        }

                        result = JSON.stringify(result);
                        result = JSON.parse(result);
                        // var list = [];
                        // for (i = 0; i < length(result); i++) {

                        // }
                        var timeDiff = "";
                        var timeDiffList = [];
                        var currentDate = new Date();
                        console.log(currentDate.getDay())
                        for (var i = 0; i < result.length; i++) {
                            var postDate = new Date(result[i]['creation_date']);
                            if (currentDate.getDay() - postDate.getDay() > 1) {
                                timeDiff = (currentDate.getDay() - postDate.getDay()) + " days ago";
                            }
                            else if (currentDate.getHours() - postDate.getHours() > 1) {
                                timeDiff = (currentDate.getHours() - postDate.getHours()) + " hours ago";
                            }
                            else if (currentDate.getMinutes() - postDate.getMinutes() > 1) {
                                timeDiff = (currentDate.getMinutes() - postDate.getMinutes()) + " min. ago";
                            }
                            else if (currentDate.getSeconds() - postDate.getSeconds() > 1) {
                                timeDiff = (currentDate.getSeconds() - postDate.getSeconds()) + "s ago";
                            }
                            timeDiffList.push(timeDiff);
                        }
                        var dict = {
                            "result": result,
                            "timeDiff": timeDiffList,
                            "error": 0
                        }
                        process.send(dict);
                        console.log("Query complete");
                        // connection.release();
                        resolve(result);
                    });

                }



            });


            // resolve(result);
        });
    

        // return result;
        
    });

}
