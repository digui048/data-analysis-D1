<?php
// Include the file that establishes a connection to the database
include __DIR__ . '/../DatabaseConnect.php';

try {
    // Get POST parameters
    $sessionID = isset($_POST['sessionID']) ? intval($_POST['sessionID']) : null;
    $end = isset($_POST['end']) ? trim($_POST['end']) : null;

    // Validate input
    if (is_null($sessionID) || is_null($end)) {
        throw new Exception("Missing or invalid parameters. Ensure sessionID and end are provided.");
    }

    // Prepare the SQL query to close the session
    $stmt = $conn->prepare("UPDATE `SessionTable` SET `SessionEnd` = ? WHERE `SessionID` = ?");
    if (!$stmt) {
        throw new Exception("Failed to prepare SQL statement: " . $conn->error);
    }

    // Bind parameters
    if (!$stmt->bind_param("si", $end, $sessionID)) {
        throw new Exception("Failed to bind parameters: " . $stmt->error);
    }

    // Execute the query
    if (!$stmt->execute()) {
        throw new Exception("Failed to execute SQL statement: " . $stmt->error);
    }
    $stmt->close();

    // Prepare the SQL query to get the user that played this session
    $stmt = $conn->prepare("SELECT `UserID` FROM `SessionTable` WHERE `SessionID` = ?");
    if (!$stmt) {
        throw new Exception("Failed to prepare SQL statement: " . $conn->error);
    }

    // Bind parameters
    if (!$stmt->bind_param("i", $sessionID)) {
        throw new Exception("Failed to bind parameters: " . $stmt->error);
    }

    // Execute the query and read the result
    if (!$stmt->execute() || !$stmt->bind_result($userID) || !$stmt->fetch()) {
        throw new Exception("Session " . $sessionID . " does not exist.");
    }

    // Return the user ID (the simulator needs it to start the player's next session)
    echo $userID;

    // Close the statement
    $stmt->close();
} catch (Exception $e) {
    // Output error for debugging
    echo "Error: " . $e->getMessage();
} finally {
    // Close the database connection
    $conn->close();
}

?>
