const db = require('./db_connection.js');

process.on("message", message => {
  db.conn.getConnection(function(err, connection) {
    if (err) {
      return console.error('error: ' + err.message);
    }
    console.log('Database connection established');
    updateTopic(message.originalTopicID, message.creator_id, message.user_id, message.update_topic_desc, connection).then(function(answer) {
      process.send(answer)
      connection.release();
      process.exit();
    
  }).catch(function(error) {
    if (error == "Topic does not exist") {
      process.send({"Error": "No topic with that name exists"});
    }
    process.send(error);
  });
});
});

 async function updateTopic(topic_id, creator_id, user_id, new_topic_desc, connection) {
    var updateQuery = "UPDATE topic_info SET topic_description = '"+new_topic_desc+"' WHERE topic_id = '"+topic_id+"'";
    return new Promise(function(resolve, reject) {
      if (creator_id != user_id) {
          reject("This user cannot edit this topic");
      }
      connection.query(updateQuery,  async function (err, result) {
        if (err) {
          console.log(err.message);
          reject(err.message);
        }
        resolve(result);
      });
    })
  };