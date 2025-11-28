import ballerina/http;

public type Message record {|
    int id?;
    string name;
    string text;
    string timestamp?;
|};

public type FloodboardBadRequest record {|
    *http:BadRequest;
    string message;
|};

public type FloodboardServerError record {|
    *http:InternalServerError;
    string message;
|};
