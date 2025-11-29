import ballerina/time;
import ballerinax/mysql;
import ballerinax/mysql.driver as _; 
import ballerina/sql;

public type message record {| 
    int id?;
    string name;
    string text;
    string timestamp?;
|};

configurable string USER = "root";
configurable string PASSWORD = "Gayuth12345!";
configurable string HOST = "localhost";
configurable int PORT = 3306;
configurable string DATABASE = "flooddb";

final mysql:Client dbClient = check new (
    host= HOST,
    user= USER,
    password= PASSWORD,
    port= PORT,
    database= DATABASE
);

// post message
isolated function addMessage(message msg)  returns int|error {
    sql:ExecutionResult result = check dbClient->execute(
        `insert into messages (name, text, timestamp) values (${msg.name}, ${msg.text}, ${msg.timestamp})`
    );

    if result.lastInsertId is int {
        return <int>result.lastInsertId;
    }
    return error("Could not post the message");
}

// read all of the message
isolated function getAllMessages() returns message[]|error {
    message[] messages = [];
    stream<message, error?> resultStream = dbClient->query(
        `select * from messages order by id desc`
    );
    check from message msg in resultStream
        do {messages.push(msg);};

    check resultStream.close();
    return messages;
}

// delete the message
isolated function removeMessage(int id)returns int|error {
    sql:ExecutionResult result = check dbClient->execute(
        `delete from messages where id =${id}`
    );
    if result.affectedRowCount is int {
        return <int>result.affectedRowCount;
    }
    return error("Unable to get affected row count");
}
