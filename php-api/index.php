<?php
header("Content-Type: application/json");
// Handle preflight requests (CORS headers are handled by .htaccess)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Function to send JSON error response
function sendError($code, $message) {
    http_response_code($code);
    echo json_encode(['error' => $message]);
    exit();
}

// Function to validate email format
function isValidEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

// Function to validate name
function isValidName($name) {
    return is_string($name) && strlen(trim($name)) >= 2 && strlen(trim($name)) <= 100;
}

try {
    // Database connection with error handling
    $dsn = "mysql:host=" . getenv('DB_HOST') . ";dbname=" . getenv('DB_NAME');
    $db = new PDO($dsn, getenv('DB_USER'), getenv('DB_PASS'));
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    sendError(500, 'Database connection failed');
}

// Get the request path
$requestPath = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($requestPath === '/users' || $requestPath === '/users/')) {
    try {
        // Get and validate JSON input
        $rawInput = file_get_contents("php://input");
        if (empty($rawInput)) {
            sendError(400, 'Request body is required');
        }

        $input = json_decode($rawInput, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            sendError(400, 'Invalid JSON format');
        }

        // Validate required fields
        if (!isset($input['name']) || !isset($input['email'])) {
            sendError(400, 'Name and email are required fields');
        }

        // Validate name
        if (!isValidName($input['name'])) {
            sendError(400, 'Name must be between 2 and 100 characters');
        }

        // Validate email
        if (!isValidEmail($input['email'])) {
            sendError(400, 'Invalid email format');
        }

        // Sanitize inputs
        $name = trim($input['name']);
        $email = trim(strtolower($input['email']));

        // Check if email already exists
        $checkStmt = $db->prepare("SELECT id FROM users WHERE email = ?");
        $checkStmt->execute([$email]);
        if ($checkStmt->fetch()) {
            sendError(409, 'Email already exists');
        }

        // Insert user with error handling
        $stmt = $db->prepare("INSERT INTO users (name, email) VALUES (?, ?)");
        $stmt->execute([$name, $email]);
        $id = $db->lastInsertId();

        // Return success response
        http_response_code(201);
        echo json_encode([
            'id' => (int)$id,
            'name' => $name,
            'email' => $email
        ]);

    } catch (PDOException $e) {
        sendError(500, 'Database error occurred');
    } catch (Exception $e) {
        sendError(500, 'Internal server error');
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'GET' && ($requestPath === '/users' || $requestPath === '/users/')) {
    try {
        // Get all users from database
        $stmt = $db->prepare("SELECT id, name, email FROM users ORDER BY id DESC");
        $stmt->execute();
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Convert id to integer for consistency
        foreach ($users as &$user) {
            $user['id'] = (int)$user['id'];
        }
        
        // Return success response with users data
        http_response_code(200);
        echo json_encode([
            'data' => $users,
            'count' => count($users),
            'message' => 'Users retrieved successfully'
        ]);
        
    } catch (PDOException $e) {
        sendError(500, 'Database error occurred');
    } catch (Exception $e) {
        sendError(500, 'Internal server error');
    }
} else {
    // Debug information for troubleshooting
    sendError(404, 'Endpoint not found. Method: ' . $_SERVER['REQUEST_METHOD'] . ', Path: ' . $requestPath);
}
