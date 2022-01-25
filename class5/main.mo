import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import List "mo:base/List";
import Iter "mo:base/Iter";

actor {
    // content, author, time
    public type Message = (Text, Text, Time.Time);

    public type Blog = actor {
        set_name: shared(Text) -> async ();
        get_name: shared query () -> async Text;
        follow: shared(Principal) -> async ();
        follows: shared query () -> async [(Principal, Text)];
        post: shared(Text) -> async ();
        posts: shared query () -> async [Message];
        other_posts: shared(Text) -> async [Message];
        timeline: shared() -> async [Message];
    };
    
    // initialization
    stable var myName: Text = "Zhendong";
    stable var myFollows: List.List<(Principal, Text)> = List.nil();
    stable var myPosts: List.List<Message> = List.nil();

    public shared (msg) func set_name(name: Text): async () {
        // assert(Principal.toText(msg.caller) == "zbgs7-kosbu-x2r3n-cwmx6-gxnh6-n2gfd-oxrdm-7eqbo-ufu7q-3ecjg-uqe");
        myName := name;
    };

    public shared query func get_name(): async Text {
        myName
    };

    public shared func follow(id: Principal): async () {
        let canister: Blog = actor(Principal.toText(id));
        let author: Text =  await canister.get_name();
        myFollows := List.push((id, author), myFollows);
    };

    public shared query func follows(): async [(Principal, Text)] {
        List.toArray(myFollows)
    };

    public shared (msg) func post(m: Text): async () {
        // assert(Principal.toText(msg.caller) == "zbgs7-kosbu-x2r3n-cwmx6-gxnh6-n2gfd-oxrdm-7eqbo-ufu7q-3ecjg-uqe");
        myPosts := List.push((m, myName, Time.now()), myPosts);
    };

    public shared query func posts(): async [Message] {
        var all: List.List<Message> = List.nil();
        for (m in Iter.fromList(myPosts)) {
            all := List.push(m, all);
        };
        List.toArray(all);
    };

    public shared func other_posts(id: Text): async [Message] {
        let canister: Blog = actor(id);
        let msgs = await canister.posts();
        msgs
    };

    public shared func timeline(): async [Message] {
        var all: List.List<Message> = List.nil();
        for (id in Iter.fromList(myFollows)) {
            let canister: Blog = actor(Principal.toText(id.0));
            let msgs = await canister.posts();
            for (m in Iter.fromArray(msgs)) {
                all := List.push(m, all);
            };
        };
        List.toArray(all)
    };

};
