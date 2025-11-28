import ballerina/http;
import ballerina/time;

type Message record {
    int id;
    string name;
    string text;
    string timestamp;
};

service /floodboard on new http:Listener(8080) {

    private final map<json> store = {};
    private int nextId = 1;

    function nowUtcString() returns string {
        time:Utc utc = time:utcNow();
        return time:utcToString(utc);
    }

    // POST /floodboard/message
    resource function post message(map<anydata> payload) returns json {
        string name = payload.hasKey("name") ? payload.get("name").toString() : "Anonymous";
        string text = payload.get("text").toString();

        int id = self.nextId;

        json saved = {
            id: id,
            name: name,
            text: text,
            timestamp: self.nowUtcString()
        };

        self.store[id.toString()] = saved;
        self.nextId += 1;

        return {
            status: "ok",
            message: "Posted",
            data: saved
        };
    }


    // GET /floodboard/messages
    resource function get messages() returns Message[]|error {
        Message[] all = [];
        foreach var [_, v] in self.store.entries() {
            Message m = check v.cloneWithType(Message);
            all.push(m);
        }

        return all;
    }
}
