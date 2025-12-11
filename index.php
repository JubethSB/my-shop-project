<?php
session_start(); // Start the memory
?>
<!DOCTYPE html>
<html>
<head>
    <title>Jubeth's DevOps Shop</title>
</head>
<body>
    <h1>🍔 DevOps Burger Shop</h1>
    
    <div style="border: 1px solid gray; padding: 10px; margin: 10px;">
        <h3>Burger ($5)</h3>
        <form action="cart.php" method="post">
            <input type="hidden" name="item_name" value="Burger">
            <input type="submit" value="Add to Cart">
        </form>
    </div>

    <div style="border: 1px solid gray; padding: 10px; margin: 10px;">
        <h3>Fries ($3)</h3>
        <form action="cart.php" method="post">
            <input type="hidden" name="item_name" value="Fries">
            <input type="submit" value="Add to Cart">
        </form>
    </div>

    <br>
    <a href="cart.php">🛒 Go to Checkout</a>
</body>
</html>