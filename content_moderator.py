banned_words = ["bad", "toxic", "hate"]


def load_posts():
    posts_list = []

    with open("messy_posts.txt", "r") as source_file:
        for line in source_file:
            line = line.strip()
            if line != "":
                posts_list.append(line)

    return posts_list


def clean_post(post_text, banned_list):
    cleaned_text = post_text
    was_cleaned = False

    for bad_word in banned_list:
        lower_words = cleaned_text.lower().split()
        if bad_word in lower_words:
            cleaned_text = cleaned_text.replace(bad_word, "***")
            cleaned_text = cleaned_text.replace(bad_word.capitalize(), "***")
            was_cleaned = True

    return cleaned_text, was_cleaned


def find_links(post_text):
    links = []
    words = post_text.split()

    for word in words:
        if word.startswith("http"):
            links.append(word)

    return links


def update_flag_report(user_name, report_dictionary):
    if user_name not in report_dictionary:
        report_dictionary[user_name] = 0

    report_dictionary[user_name] = report_dictionary[user_name] + 1


def main():
    posts_data = load_posts()
    total_posts_screened = 0
    cleaned_posts = 0
    blocked_posts = 0

    moderator_flags = {
        "User123": 0,
        "User456": 0,
        "User789": 0,
        "User999": 0
    }

    safe_posts = []
    all_links = []

    for line in posts_data:
        total_posts_screened = total_posts_screened + 1

        parts = line.split("|", 1)
        user_name = parts[0]
        post_text = parts[1]

        cleaned_text, was_cleaned = clean_post(post_text, banned_words)
        links_in_post = find_links(post_text)

        if was_cleaned:
            cleaned_posts = cleaned_posts + 1
            update_flag_report(user_name, moderator_flags)

        if len(links_in_post) > 0:
            blocked_posts = blocked_posts + 1
            update_flag_report(user_name, moderator_flags)

            for link in links_in_post:
                all_links.append(link)
        else:
            safe_posts.append(user_name + ": " + cleaned_text)

    with open("links_found.txt", "w") as link_file:
        for link in all_links:
            link_file.write(link + "\n")

    with open("safe_posts.txt", "w") as safe_file:
        for post in safe_posts:
            safe_file.write(post + "\n")

    print("SAFE POSTS")
    for post in safe_posts:
        print(post)

    print()
    print("MODERATOR FLAG REPORT")
    print(moderator_flags)

    print()
    print(
        "Total Posts Screened: "
        + str(total_posts_screened)
        + " | Cleaned: "
        + str(cleaned_posts)
        + " | Blocked: "
        + str(blocked_posts)
    )


main()
