const db = require('./db_connection.js');

process.on("message", message => {
    db.conn.getConnection(async(err, connection)=> {
          if (err) {
            return console.error('error: ' + err.message);
          }
          console.log('Database connection established');
          var data = {
             topic_id: message.topic_id,
             follower_id: message.follower_id
           }
           console.log(data);
         addTopicFollower(data, connection).then((answer) => {
            connection.release();
            if (answer == "Relationship already exists") {
                process.send({"Error": "User-Topic relationship already exists"});
            } else if (answer == "Added") {
                process.send({"Success": "Topic Follower relationship created"});
            } else {
              process.send({"Error": "Topic Follower relationship not created"});
            }
            process.exit();
          });
        });
        
});
 function addTopicFollower(data, connection) {
    var topic_id = data.topic_id;
    var follower_id = data.follower_id;
    var selectQuery = "SELECT * FROM topic_follower WHERE topic_id = '"+topic_id+"' AND follower_id = '"+follower_id+"'";
    var addFollowerQuery = "INSERT INTO topic_follower (row_id, topic_id, follower_id) VALUES ?";
    var row_id = Math.floor(Math.random() * 100000);
    var values1 = [[topic_id, follower_id]];
    var values2 = [[row_id, topic_id, follower_id]]
    return new Promise(function(resolve, reject) {
      connection.query(selectQuery,[values1],  function (err, result) {
        if (err) {
          console.log(err);
          reject(err.message);
        }
        try {
          if (result.length == 1) {
            resolve("Relationship already exists");
            } else {
                connection.query(addFollowerQuery, [values2], function (err, result) {
              if (err) {
                if (err.code === 'ER_DUP_ENTRY') {
                    addFollower(data, connection)
                } else {
                console.log(err);
                reject(err.message);
                }
              } 
                resolve("Added");
              });
          }
        }
        catch (error){
          reject(err.message);
        }
        resolve(result);
      });
    })
  };

  