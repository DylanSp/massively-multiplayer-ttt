# MassivelyMultiplayerTtt

[Play this app on Fly.io!](https://small-lake-1570.fly.dev/)

This project is a tic-tac-toe game able to be played simultaneously by any number of connected players, all updating in real-time. It's a way for me to learn a bit about the Elixir/Phoenix/LiveView stack and the BEAM, as an alternative to SPA frontends and stateless application servers.

## Caveats

- While you can enter a username through the form on the left (which will show up in the user list for all users), this will be lost on refresh.
- A single game state is shared between all users.

## Overall Architecture

I initialized this project with `mix phx.new massively_multiplayer_ttt --live --no-ecto` to create a Phoenix LiveView app without a database backend. From there, as can be seen in my [`Application` module](lib/massively_multiplayer_ttt/application.ex), I have the following processes running under the root supervisor:

- `Endpoint`, which spawns the `GameLive` processes that serve the UI and handle input.
- `Telemetry` and `PubSub`, provided out of the box by Phoenix.
- [`GameServer`](lib/massively_multiplayer_ttt/game_server.ex), which maintains the tic-tac-toe game state. `GameLive` processes call it to submit moves or game resets; `GameServer` then broadcasts over pubsub to update the game state for all clients.
- [`UsernameServer`](lib/massively_multiplayer_ttt/username_server.ex), which maintains a map of `GameLive` view process IDs to usernames, holding the list of all currently connected users, broadcasting username additions/changes/removals over pubsub.

The [`Game`](lib/massively_multiplayer_ttt/game.ex) module encapsulates all tic-tac-toe game logic. The [Live EEx template](lib/massively_multiplayer_ttt_web/live/game_live.html.leex) describes the UI (with a [bit of CSS](assets/css/ttt.css)), while [`GameLive`](lib/massively_multiplayer_ttt_web/live/game_live.ex) handles input and responds to messages coming from the pubsub system.

## Running locally

### Dependencies

- [Install Elixir](https://elixir-lang.org/install.html).
- Install the Hex package manager by running `mix local.hex`.
- Install [Node.js](https://nodejs.org/en/download/).
- If on linux, install [`inotify-tools`](https://github.com/inotify-tools/inotify-tools/wiki).
- At the root of this repo, run `mix setup` to install and compile all dependencies.

### Starting and Running

- Start the Phoenix server with `mix phx.server`.
- The application should now be available at [`localhost:4000`](http://localhost:4000) in your browser.

## Deliberate Non-goals

There are several improvements/opportunities I deliberately haven't pursued with this project, largely to keep the scope manageable:

- Persisting data beyond the server; I didn't want to bother with database access for this. Admittedly, this has made managing usernames more difficult, especially persisting them across browser refreshes.
- A mobile-friendly UI; I did the minimum necessary to create a usable UI for desktops.
- Notifications for erroneous moves; Phoenix's built-in [flash messages](https://hexdocs.pm/phoenix/controllers.html#flash-messages) only work on redirects; they don't work especially well with LiveView. I didn't want to spend the time necessary to integrate a JS library for notifications.
- Preserving session state (i.e. usernames) through refreshes. This is tricky without a database backend; I tried saving a session key client-side, getting it with [JS hooks](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#module-js-interop-and-client-controlled-dom), and using that to manage state in the `UsernameServer`. However, I couldn't get everything synchronizing correctly.

## Inspirations and Education

I've been eyeing Erlang/Elixir for a long while, interested by its performance, reliability, and unique approach to structuring and maintaining applications. I then watched Chris McCord's video, [Build a real-time Twitter clone in 15 minutes with LiveView and Phoenix 1.5](https://www.youtube.com/watch?v=MZvmYaFkNJI), which really piqued my interest and inspired me to start this project. I've also worked through some of The Pragmatic Studio's [Phoenix LiveView course](https://pragmaticstudio.com/phoenix-liveview) to help build my understanding.
