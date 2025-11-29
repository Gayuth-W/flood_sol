import ballerina/http;
import ballerina/time;


service /messages on new http:Listener(8080) {

    isolated resource function post .(@http:Payload message msg)
            returns int|error? {

        msg.timestamp = time:utcToString(time:utcNow());
        return addMessage(msg);
    }

    isolated resource function get .() returns message[]|error? {
        return getAllMessages();
    }

    isolated resource function delete [int id]() returns int|error? {
        return removeMessage(id);
    }
}
