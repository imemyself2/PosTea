const db = require('./db_connection.js');

process.on("message", message => {
    db.conn.getConnection(async function(err, connection) {
          if (err) {
            return console.error('error: ' + err.message);
          }
          
          console.log('Database connection established');
          var data = {
            topicText: message.topicText,
            topic_creator_id: message.topicCreatorID,
            topic_description: message.topicDescription
          }
          await addTopicInfo(data, connection).then((result) => {
            connection.release();
            process.send(result);
            process.exit();
          }).catch((error) => {
            connection.release();
            process.send(error);
            process.exit();
          });
        });
});

const addTopicInfo = async function(data, connection) {
    console.log("data");
    var top_id =  Math.floor(Math.random() * 100000);
    var addtopicinfoq = "INSERT INTO topic_info (topic_id, topic_creator_id, topic_name, topic_description, topic_img, creation_date) VALUES ?";
    var date = new Date().toISOString().slice(0, 19).replace('T', ' ');
    var vals = [[top_id, data.topic_creator_id, data.topicText, data.topic_description, "", date]];
    return new Promise(function(resolve, reject) {
      connection.query()
      connection.query(addtopicinfoq,[vals], function(err, result) {
        if (err) {
            reject(err.message);
        } else {
          resolve(result);
        }

      });
    })


}

