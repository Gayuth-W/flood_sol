import ballerinax/mysql;
import ballerina/sql;
import country_service.types;

configurable string dbHost = "localhost";
configurable int dbPort = 3306;
configurable string dbUser = "root";
configurable string dbPassword = "Test@123";
configurable string dbName = "FLOODDB";

public final mysql:Client db = check new mysql:Client({
    host: dbHost,
    port: dbPort,
    user: dbUser,
    password: dbPassword,
    database: dbName
});

// Insert message and return inserted ID
public function insertMessage(types:Message msg) returns int|error {
    sql:ExecutionResult|error result = db->execute(
        `INSERT INTO messages (name, text) VALUES (${msg.name}, ${msg.text})`
    );
    if result is error {
        return error("Failed to execute insert query: " + result.message);
    }
    int? insertedId = result.lastInsertId;
    if insertedId is int {
        return insertedId;
    }
    return error("Failed to get inserted ID after insert");
}

// Get message by ID
public function getMessage(int id) returns types:Message|error {
    types:Message?|error msg = db->queryRow(
        `SELECT id, name, text, timestamp FROM messages WHERE id = ${id}`, types:Message
    );
    if msg is error {
        return error("Failed to execute queryRow: " + msg.message);
    }
    if msg is types:Message {
        return msg;
    }
    return error("Message not found");
}

// Get all messages
public function getAllMessages() returns types:Message[]|error {
    stream<types:Message, sql:Error?>|error messagesStream = db->query(
        `SELECT id, name, text, timestamp FROM messages`, types:Message
    );
    if messagesStream is error {
        return error("Failed to execute query: " + messagesStream.message);
    }
    types:Message[] messages = [];
    error? e = messagesStream.forEach(function(types:Message m) {
        messages.push(m);
    });
    if e is error {
        return e;
    }
    return messages;
}
