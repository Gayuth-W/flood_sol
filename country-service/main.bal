import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;

// ---------- Data Models ----------
type Message record {
    int id?;
    string name;
    string text;
    string timestamp?;
};

// ---------- Database Configuration ----------
type DataBaseConfig record {
    string host;
    int port;
    string user;
    string password;
    string database;
};

configurable DataBaseConfig dbConfig = ?;

// Initialize MySQL client
mysql:Client dbClient = check new (
    host = dbConfig.host,
    port = dbConfig.port,
    user = dbConfig.user,
    password = dbConfig.password,
    database = dbConfig.database
);

// ---------- Floodboard Service ----------
service /floodboard on new http:Listener(8080) {

    // POST /floodboard/message
    resource function post message(Message msg) returns Message|error {
        // Insert message and get the inserted row
        Message? insertedMsg = check dbClient->queryRow(
            `INSERT INTO messages (name, text) VALUES (${msg.name}, ${msg.text}) RETURNING id, name, text, timestamp`,
            Message
        );

        if insertedMsg is Message {
            return insertedMsg;
        } else {
            return error("Failed to insert message");
        }
    }

    // GET /floodboard/messages
    resource function get messages() returns Message[]|error {
        stream<Message, sql:Error?> messageStream = dbClient->query(
            `SELECT id, name, text, timestamp FROM messages ORDER BY timestamp DESC`, 
            Message
        );

        Message[] messages = [];
        error? e = messageStream.forEach(function(Message m) {
            messages.push(m);
        });

        if e is error {
            return e;
        }
        return messages;
    }
}
