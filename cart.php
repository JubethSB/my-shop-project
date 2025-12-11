<?php
session_start();
include 'db_connect.php'; // We will create this next

// 1. Add item to cart if clicked
if (isset($_POST['item_name'])) {
    $_SESSION['cart'][] = $_POST['item_name'];
}

// 2. Place Order (Save to Database)
$message = "";
if (isset($_POST['place_order'])) {
    if (!empty($_SESSION['cart'])) {
        foreach ($_SESSION['cart'] as $item) {
            $product = $item;
            // SQL to insert into AWS RDS
            $sql = "INSERT INTO orders (product_name) VALUES ('$product')";
            if ($conn->query($sql) === TRUE) {
                $message = "Order Sent to Kitchen (Database)!";
            } else {
                $message = "Error: " . $conn->error;
            }
        }
        $_SESSION['cart'] = []; // Clear cart
    }
}
?>

<h1>Your Cart</h1>
<?php if($message) echo "<h2 style='color:green'>$message</h2>"; ?>

<ul>
    <?php 
    if(isset($_SESSION['cart'])) {
        foreach ($_SESSION['cart'] as $item) {
            echo "<li>$item</li>";
        }
    }
    ?>
</ul>

<form method="post">
    <input type="submit" name="place_order" value="✅ Place Order Now">
</form>

<a href="index.php">Back to Menu</a>