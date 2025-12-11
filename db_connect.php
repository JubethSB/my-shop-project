<?php
$servername = "terraform-20251211052001059100000004.coxcy06kuzke.us-east-1.rds.amazonaws.com"; 
// ^ I pasted your link here and removed :3306
$username = "admin";
$password = "password123"; 
$dbname = "food_db";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>