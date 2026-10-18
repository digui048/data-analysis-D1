<?php
// Include the file that establishes a connection to the database
include __DIR__ . '/../DatabaseConnect.php';

try {
    // Get POST parameters
    $sessionID = isset($_POST['sessionID']) ? intval($_POST['sessionID']) : null;
    $itemID = isset($_POST['itemID']) ? intval($_POST['itemID']) : null;
    $date = isset($_POST['date']) ? trim($_POST['date']) : null;

    // Validate input
    if (is_null($sessionID) || is_null($itemID) || is_null($date)) {
        throw new Exception("Missing or invalid parameters. Ensure sessionID, itemID and date are provided.");
    }

    // Prepare the SQL query
    $stmt = $conn->prepare("INSERT INTO `PurchaseTable` (`SessionID`, `ItemID`, `PurchaseDate`) VALUES (?, ?, ?)");
    if (!$stmt) {
        throw new Exception("Failed to prepare SQL statement: " . $conn->error);
    }

    // Bind parameters
    if (!$stmt->bind_param("iis", $sessionID, $itemID, $date)) {
        throw new Exception("Failed to bind parameters: " . $stmt->error);
    }

    // Execute the query
    if (!$stmt->execute()) {
        throw new Exception("Failed to execute SQL statement: " . $stmt->error);
    }

    // Return the session ID (the simulator needs it to end the session)
    echo $sessionID;

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
