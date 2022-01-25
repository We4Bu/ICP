import { BlogWeb } from "../../declarations/BlogWeb";

var num_my_posts = 0;
var num_total_posts = 0;
var num_follows = 0;

async function set_name() {
    let button = document.getElementById("submit_name");
    button.disabled = true;
    let content = document.getElementById("name");
    await BlogWeb.set_name(content.value);
    button.disabled = false;
}

async function create_post() {
    let button = document.getElementById("submit_post");
    button.disabled = true;
    let content = document.getElementById("message");
    await BlogWeb.post(content.value);
    button.disabled = false;
}

async function load_posts() {
    let section = document.getElementById("posts");
    let content = await BlogWeb.posts();
    if (num_my_posts == content.length) reutrn ;
    section.replaceChildren([]);
    num_my_posts = content.length;
    for (var i = 0; i < content.length; ++i) {
        let post = document.createElement("p");
        post.innerText = content[i][2] + " -> " + content[i][0];
        section.appendChild(post);
    }
}

async function load_follows() {
    let section = document.getElementById("follows");
    let content = await BlogWeb.follows();
    if (num_follows == content.length) reutrn;
    section.replaceChildren([]);
    num_follows = content.length;
    for (var i = 0; i < content.length; ++i) {
        let author = document.createElement("button");
        author.innerText = content[i][1];
        author.id = content[i][0];
        author.onclick = async function () {
            let section = document.getElementById("other_posts");
            section.replaceChildren([]);
            let content = await BlogWeb.other_posts(this.id);
            for (var i=0; i<content.length; ++i) {
                let post = document.createElement("p");
                post.innerText = content[i][2] + " -> " + content[i][0];
                section.appendChild(post);
            };
        };
        section.appendChild(author);
    }
}

async function load_timeline() {
    let section = document.getElementById("timeline");
    let content = await BlogWeb.timeline();
    if (num_total_posts == content.length) reutrn;
    section.replaceChildren([]);
    num_total_posts = content.length;
    for (var i = 0; i < content.length; ++i) {
        let post = document.createElement("p");
        post.innerText = content[i][1] + " -> " + content[i][2] + " -> " + content[i][0];
        section.appendChild(post);
    }
}

function init() {
    let name_button = document.getElementById("submit_name");
    name_button.onclick = set_name;
    let post_button = document.getElementById("submit_post");
    post_button.onclick = create_post;
    load_posts();
    load_follows();
    load_timeline();
    setInterval(load_posts, 3000);
    setInterval(load_follows, 3000);
    setInterval(load_timeline, 3000);
}

window.onload = init