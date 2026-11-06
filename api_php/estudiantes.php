
<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit;
}

include "conexion.php";

$metodo = $_SERVER["REQUEST_METHOD"];

if ($metodo === "GET") {
    $sql = "SELECT * FROM estudiantes3";
    $resultado = $conexion->query($sql);

    $estudiantes = [];

    while ($fila = $resultado->fetch_assoc()) {
        $estudiantes[] = $fila;
    }

    echo json_encode($estudiantes);
}

elseif ($metodo === "POST") {
    $datos = json_decode(file_get_contents("php://input"), true);

    $nombre = $datos["nombre"] ?? "";
    $correo = $datos["correo"] ?? "";
    $programa = $datos["programa"] ?? "";
    $semestre = $datos["semestre"] ?? "";

    if ($nombre === "" || $correo === "" ||
        $programa === "" || $semestre === "") {
        http_response_code(400);
        echo json_encode([
            "error" => "Todos los campos son obligatorios"
        ]);
        exit;
    }

    $sql = "INSERT INTO estudiantes3
            (nombre, correo, programa, semestre)
            VALUES (?, ?, ?, ?)";

    $stmt = $conexion->prepare($sql);
    $stmt->bind_param(
        "ssss",
        $nombre,
        $correo,
        $programa,
        $semestre
    );

    if ($stmt->execute()) {
        echo json_encode([
            "mensaje" => "Estudiante registrado correctamente"
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            "error" => "No se pudo registrar el estudiante"
        ]);
    }

    $stmt->close();
}

$conexion->close();
?>
