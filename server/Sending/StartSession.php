<?php
// Include the file that establishes a connection to the database
include __DIR__ . '/../DatabaseConnect.php';

try {
    // Get POST parameters
    $userID = isset($_POST['userID']) ? intval($_POST['userID']) : null;
    $start = isset($_POST['start']) ? trim($_POST['start']) : null;

    // Validate input
    if (is_null($userID) || is_null($start)) {
        throw new Exception("Missing or invalid parameters. Ensure userID and start are provided.");
    }

    // Prepare the SQL query
    $stmt = $conn->prepare("INSERT INTO `SessionTable` (`UserID`, `SessionStart`) VALUES (?, ?)");
    if (!$stmt) {
        throw new Exception("Failed to prepare SQL statement: " . $conn->error);
    }

    // Bind parameters
    if (!$stmt->bind_param("is", $userID, $start)) {
        throw new Exception("Failed to bind parameters: " . $stmt->error);
    }

    // Execute the query
    if (!$stmt->execute()) {
        throw new Exception("Failed to execute SQL statement: " . $stmt->error);
    }

    // Return the last inserted ID (session ID)
    echo $conn->insert_id;

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
