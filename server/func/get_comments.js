const db = require('./db_connection.js');

process.on("message", message => {
    db.conn.getConnection(async function(err, connection) {
        if (err) {
            return console.error('error: ' + err.message);
        }
        console.log('Database connection established');
        await getComments(message.post_id, connection).then(function(answer) {
            connection.release();
            process.exit();

        });
    });
});

function getComments(post_id, connection) {
    var selectQuery = "SELECT * FROM engagement as e, profile as p WHERE e.post_id = " + post_id + " and e.profile_id = p.profile_id ORDER BY creation_date DESC";
    return new Promise( async function(resolve, reject) {
         await connection.query(selectQuery, async function(err, result) {
            if (err) {
                console.log(err);
                reject(err.message);
            }
            for (var i = 0; i < result.length; i++) {
                var comment = result[i].comment;
                console.log(comment);
                if (typeof comment !== 'undefined' && comment != null){
                  if (comment.includes("@")) {
                      var index_of_at = comment.indexOf("@");
                      if (index_of_at >= 0 && comment.charAt(index_of_at-1) == ' ') {

                      var tag = comment.substring(index_of_at, comment.length);
                      var index_of_space = tag.indexOf(" ");
                      if (index_of_space == -1) {
                        index_of_space = tag.length-1;
                      }
                      var tag = tag.substring(1, index_of_space + 1);
                      await get_updated_result(result[i], tag, connection).then((value)=> {
                        result[i] = value;
                    }); 
                  } else {
                    result[i]["flag"] = "No tag";
                  }                   
                  } else {
                    result[i]["flag"] = "No tag";
                  }
              } else {
                  result[i]["flag"] = "No tag";
                }
            }
            result = JSON.stringify(result);
            result = JSON.parse(result);
            process.send({
                "message": result
            });
            resolve(result);
        });
    })
};


const get_updated_result = async(current_result, tag, connection) => {
  var new_field = "";
  var id = 0;
  var selectQuery1 = "SELECT profile_id FROM profile WHERE profile.username = ?";
  return new Promise(async function(resolve, reject) {
     await connection.query(selectQuery1,[tag],async function(err, result)  {
          if (err) {
              console.log("error exists");
              reject(err.message);
          }
          else {
              if (result.length == 0) {
                await get_updated_result1(current_result, tag, connection).then((value)=> {
                  current_result = value;
                });  
              } else {
                new_field = "profile_id";
                id = result[0].profile_id;
                if (new_field == "") {
                  current_result["flag"] = "No tag";
                } else {
                  current_result["tag_id"] = id;
                  current_result["flag"] = "Tag exists: profile_id";
                }
              }
              
              current_result = JSON.stringify(current_result);
              current_result = JSON.parse(current_result);
              resolve(current_result);
          }
      });
  });
}

const get_updated_result1 = async(current_result, tag, connection) => {
  var new_field = "";
  var id = 0;
  var selectQuery1 = "SELECT topic_id FROM topic_info WHERE topic_info.topic_name = ?";
  return new Promise(function(resolve, reject) {
     connection.query(selectQuery1,[tag],function(err, result)  {
          if (err) {
              console.log("error exists");
              reject(err.message);
          }
          else {
              if (result.length == 0) {
                current_result["flag"] = "Incorrect tag";
              } else {
                new_field = "topic_id";
                id = result[0].topic_id;
                if (new_field == "") {
                  current_result["flag"] = "No tag";
                } else {
                  current_result["tag_id"] = id;
                  current_result["flag"] = "Tag exists: topic_id";
                }
              }
              
              current_result = JSON.stringify(current_result);
              current_result = JSON.parse(current_result);
              resolve(current_result);
              // return result;  
          }
      });
  });
}