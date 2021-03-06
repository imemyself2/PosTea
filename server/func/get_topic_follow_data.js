
const db = require('./db_connection.js');

process.on("message", message => {
    db.conn.getConnection(async function(err, connection) {
        if (err) {
            return console.error('error: ' + err.message);
        }
        console.log('Database connection established');
        getTopicFollowers(message.topic_id, connection).then((result)=> {
            if (message.flag == "follower_list") {
                process.send(result);
              } else if (message.flag == "follower_count") {
                var followerCount = {
                    "followerCount": result.length
                  };
                followerCount = JSON.stringify(followerCount);
                followerCount = JSON.parse(followerCount);
                process.send(followerCount);
              }
            connection.release();
            process.exit();
        }).catch(function(result) {
            process.send(result);
            connection.release();
            process.exit();
        });
    });
}); 

const getTopicFollowers = async(topic_id, connection) => {
    var query = "SELECT * FROM topic_follower WHERE topic_follower.topic_id = ?";
    return new Promise(async function(resolve, reject) {
       await connection.query(query,[topic_id], async function(err, result)  {
            if (err) {
                console.log("error:" + err.message);
                reject(err.message);
            }
            if (result.length == 0) {
                console.log("Topic followers record does not exist");
                reject("Topic followers record does not exist");
            } else {
                result = JSON.stringify(result);
                result = JSON.parse(result);
                console.log(result);
                await convert_to_id_and_name(result, connection).then((value)=> {
                    result = value;
                });
                console.log("Topic followers retrieved.")
                resolve(result);
            }
        });
    });
}

const convert_to_id_and_name = async(ids, connection) => {
    var query1 = "SELECT profile_id, name FROM profile WHERE";
    var profile_ids = [];
    for (var i = 0; i < ids.length; i++) {
        profile_ids.push(ids[i].follower_id);
        query1 = query1.concat(" profile.profile_id = ? OR");
    }
    query1 = query1.substr(0, query1.length-2);
    return new Promise(function(resolve, reject) {
       connection.query(query1,profile_ids,function(err, result)  {
            if (err) {
                console.log("error exists");
                reject(err.message);
            }
            else {
                result = JSON.stringify(result);
                result = JSON.parse(result);
                console.log(result)
                resolve(result);
                // return result;  
            }
        });
    });
}