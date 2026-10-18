<?php

// Database connection details
$servername = "localhost";
$username = "mariomr2";
$password = "Not going to tell you";
$database = "mariomr2";

// Report errors
mysqli_report(MYSQLI_REPORT_OFF);

// Create connection to the database
$conn = new mysqli($servername, $username, $password, $database);

// Check connection status
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$conn->set_charset("utf8mb4");


?>
