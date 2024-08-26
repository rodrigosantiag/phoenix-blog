# Phoenix Blog Project

## Summary
Blog project part of Dockyard Curriculum course.

This project is only for studies purpose. All of what is seen here must not be considered for a production application.

## Stack
* [Phoenix 1.7.14](https://www.phoenixframework.org/)
* [Elixir 1.14.4](https://elixir-lang.org/)


## Entity Relationship Diagram
```mermaid
erDiagram
User {
  string username
  string email
  string password
  string hashed_password
  naive_datetime confirmed_at
}

Post {
    string title
    text content
    date published_on
    boolean visibility
}

CoverImage {
    text url
    id post_id
}

Comment {
  text content
  id post_id
}

Tag {
    string name
}

User |O--O{ Post: ""
Post }O--O{ Tag: ""
Post ||--O{ Comment: ""
Post ||--|| CoverImage: ""
```