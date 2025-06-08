<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "taskverse_db";

try {
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $method = $_SERVER['REQUEST_METHOD'];

    // Handle preflight
    if ($method == 'OPTIONS') { exit; }

    // GET: List all tasks or get by id
    if ($method == 'GET') {
        if (isset($_GET['id'])) {
            $stmt = $conn->prepare("SELECT * FROM tasks WHERE id = ?");
            $stmt->execute([$_GET['id']]);
            $task = $stmt->fetch(PDO::FETCH_ASSOC);
            echo json_encode($task ?: []);
        } else {
            $stmt = $conn->query("SELECT * FROM tasks");
            echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
        }
        exit;
    }

    // POST: Create new task
    if ($method == 'POST') {
        $data = json_decode(file_get_contents('php://input'), true);
        $stmt = $conn->prepare("INSERT INTO tasks (id, title, description, due_date, due_time, is_completed, type, priority, streak, last_completed, project_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([
            $data['id'],
            $data['title'],
            $data['description'] ?? null,
            $data['dueDate'] ?? null,
            $data['dueTime'] ?? null,
            $data['isCompleted'] ?? 0,
            $data['type'],
            $data['priority'] ?? null,
            $data['streak'] ?? 0,
            $data['lastCompleted'] ?? null,
            $data['projectId'] ?? null
        ]);
        echo json_encode(['status' => 'success']);
        exit;
    }

    // PUT: Update task
    if ($method == 'PUT') {
        parse_str(file_get_contents("php://input"), $data);
        $stmt = $conn->prepare("UPDATE tasks SET title=?, description=?, due_date=?, due_time=?, is_completed=?, type=?, priority=?, streak=?, last_completed=?, project_id=? WHERE id=?");
        $stmt->execute([
            $data['title'],
            $data['description'] ?? null,
            $data['dueDate'] ?? null,
            $data['dueTime'] ?? null,
            $data['isCompleted'] ?? 0,
            $data['type'],
            $data['priority'] ?? null,
            $data['streak'] ?? 0,
            $data['lastCompleted'] ?? null,
            $data['projectId'] ?? null,
            $data['id']
        ]);
        echo json_encode(['status' => 'success']);
        exit;
    }

    // DELETE: Delete task
    if ($method == 'DELETE') {
        parse_str(file_get_contents("php://input"), $data);
        $stmt = $conn->prepare("DELETE FROM tasks WHERE id=?");
        $stmt->execute([$data['id']]);
        echo json_encode(['status' => 'success']);
        exit;
    }

    echo json_encode(['status' => 'error', 'message' => 'Invalid request']);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>