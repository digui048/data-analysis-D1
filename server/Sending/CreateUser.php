<?php
// Include the file that establishes a connection to the database
include __DIR__ . '/../DatabaseConnect.php';

try {
    // Get POST parameters
    $name = isset($_POST['name']) ? trim($_POST['name']) : null;
    $country = isset($_POST['country']) ? trim($_POST['country']) : null;
    $age = isset($_POST['age']) ? intval($_POST['age']) : null;
    $gender = isset($_POST['gender']) ? floatval($_POST['gender']) : null;
    $date = isset($_POST['date']) ? trim($_POST['date']) : null;

    // Validate input
    if (is_null($name) || is_null($country) || is_null($age) || is_null($gender) || is_null($date)) {
        throw new Exception("Missing or invalid parameters. Ensure name, country, age, gender and date are provided.");
    }

    // Prepare the SQL query
    $stmt = $conn->prepare("INSERT INTO `UsersTable` (`UserName`, `UserCountry`, `UserAge`, `UserGender`, `UserDate`) VALUES (?, ?, ?, ?, ?)");
    if (!$stmt) {
        throw new Exception("Failed to prepare SQL statement: " . $conn->error);
    }

    // Bind parameters
    if (!$stmt->bind_param("ssids", $name, $country, $age, $gender, $date)) {
        throw new Exception("Failed to bind parameters: " . $stmt->error);
    }

    // Execute the query
    if (!$stmt->execute()) {
        throw new Exception("Failed to execute SQL statement: " . $stmt->error);
    }

    // Return the last inserted ID (user ID)
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
