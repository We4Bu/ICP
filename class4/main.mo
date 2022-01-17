import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import List "mo:base/List";
import Iter "mo:base/Iter";

actor {
    public type Message = (Text, Time.Time);
    
    public type Blog = actor {
        follow: shared(Principal) -> async ();
        follows: shared query () -> async [Principal];
        post: shared(Text) -> async ();
        posts: shared query (Time.Time) -> async [Message];
        timeline: shared(Time.Time) -> async [Message];
    };

    stable var myFollows: List.List<Principal> = List.nil();
    stable var myPosts: List.List<Message> = List.nil();

    public shared func follow(id: Principal): async () {
        myFollows := List.push(id, myFollows);
    };

    public shared query func follows(): async [Principal] {
        List.toArray(myFollows)
    };

    public shared (msg) func post(m: Text): async () {
        assert(Principal.toText(msg.caller) == "zbgs7-kosbu-x2r3n-cwmx6-gxnh6-n2gfd-oxrdm-7eqbo-ufu7q-3ecjg-uqe");
        myPosts := List.push((m, Time.now()), myPosts);
    };

    public shared query func posts(since: Time.Time): async [Message] {
        var all: List.List<Message> = List.nil();
        for (m in Iter.fromList(myPosts)) {
            if (m.1 > since) {
                all := List.push(m, all);
            };
        };
        List.toArray(all);
    };

    public shared func timeline(since: Time.Time): async [Message] {
        var all: List.List<Message> = List.nil();
        for (id in Iter.fromList(myFollows)) {
            let canister: Blog = actor(Principal.toText(id));
            let msgs = await canister.posts();
            for (m in Iter.fromArray(msgs)) {
                if (m.1 > since) {
                    all := List.push(m, all);
                };
            };
        };
        List.toArray(all)
    };

};
