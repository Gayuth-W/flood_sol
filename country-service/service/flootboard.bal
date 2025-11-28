import ballerina/http;
import ballerina/lang.array as array;
import country_service/types;
import country_service/db;

listener http:Listener floodListener = new(8080);

service /floodboard on floodListener {

    resource function post message(types:Message msg) 
        returns types:Message|types:FloodboardBadRequest|types:FloodboardServerError {

        if msg.text == "" {
            return http:BadRequest({body: {message: "Text cannot be empty"}});
        }

        int|error insertedId = db:insertMessage(msg);
        if insertedId is error {
            return http:InternalServerError({body: {message: "Failed to insert message"}});
        }
        msg.id = insertedId;

        types:Message|error savedMsg = db:getMessage(insertedId);
        if savedMsg is error {
            return http:InternalServerError({body: {message: "Failed to retrieve saved message"}});
        }
        return savedMsg;
    }

    resource function get messages() returns types:Message[]|types:FloodboardServerError {
        types:Message[]|error messages = db:getAllMessages();
        if messages is error {
            return http:InternalServerError({body: {message: "Failed to retrieve messages"}});
        }

        // Sort newest first
        messages = array:sortWithKey(messages, key = function (types:Message m) returns string {
            return m.timestamp ?: "";
        }, direction = "descending");

        return messages;
    }
}
