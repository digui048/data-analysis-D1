# Server (PHP)

Scripts that receive the gameplay events sent by Unity and store them in the MySQL database.

```
server/
├── DatabaseConnect.php      opens the MySQL connection ($conn)
└── Sending/                 one script per simulator event
    ├── CreateUser.php
    ├── StartSession.php
    ├── BuyItem.php
    └── EndSession.php
```

## Sending scripts
All scripts take `POST` fields and answer with a plain ID, or `Error: ...` if something failed.
Dates use the format `YYYY-MM-DD HH:MM:SS` (the simulated date).

| Script | Simulator event | POST fields | Answer |
|---|---|---|---|
| `CreateUser.php` | `OnNewPlayer` | `name`, `country`, `age`, `gender`, `date` | user ID |
| `StartSession.php` | `OnNewSession` | `userID`, `start` | session ID |
| `BuyItem.php` | `OnBuyItem` | `sessionID`, `itemID`, `date` | session ID |
| `EndSession.php` | `OnEndSession` | `sessionID`, `end` | user ID |

## Setup
1. Write the database user and password in `DatabaseConnect.php`.
2. Upload the `server/` folder to the web folder with FileZilla (SFTP).
