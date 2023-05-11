# Planning Poker

## Project structure
```
app/ # Domain logic
web/ # Rest API with websockets
spec/ # Tests
```

## Capabilities
1. Uses plain json HTTP requests to create a new session `web/controller/*.rb`
2. Uses websockets to notify about game changes `web/command_handler.rb`
