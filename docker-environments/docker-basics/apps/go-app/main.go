package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-redis/redis/v8"
	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

// Structures de données
type Task struct {
	ID          int       `json:"id" db:"id"`
	Title       string    `json:"title" db:"title"`
	Description string    `json:"description" db:"description"`
	Completed   bool      `json:"completed" db:"completed"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

type HealthStatus struct {
	Status    string            `json:"status"`
	Timestamp time.Time         `json:"timestamp"`
	Services  map[string]string `json:"services"`
	Hostname  string            `json:"hostname"`
	Uptime    string            `json:"uptime"`
}

type SystemInfo struct {
	Hostname      string    `json:"hostname"`
	GoVersion     string    `json:"go_version"`
	OS            string    `json:"os"`
	Architecture  string    `json:"architecture"`
	NumCPU        int       `json:"num_cpu"`
	NumGoroutines int       `json:"num_goroutines"`
	MemoryUsage   string    `json:"memory_usage"`
	Timestamp     time.Time `json:"timestamp"`
}

// Variables globales
var (
	db          *sql.DB
	redisClient *redis.Client
	startTime   time.Time
)

func main() {
	startTime = time.Now()

	// Charger les variables d'environnement
	if err := godotenv.Load(); err != nil {
		log.Println("Aucun fichier .env trouvé, utilisation des variables d'environnement système")
	}

	// Initialiser les connexions
	initDatabase()
	initRedis()

	// Configuration Gin
	if os.Getenv("GIN_MODE") == "" {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.Default()

	// Middleware CORS
	router.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	// Routes
	setupRoutes(router)

	// Démarrer le serveur
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("🚀 Serveur Go démarré sur le port %s", port)
	log.Printf("🌍 Environnement: %s", os.Getenv("GIN_MODE"))
	log.Printf("🐳 Container ID: %s", getHostname())
	log.Println("✅ Application prête !")

	if err := router.Run(":" + port); err != nil {
		log.Fatal("Erreur de démarrage du serveur:", err)
	}
}

func initDatabase() {
	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		databaseURL = "postgresql://labuser:labpass@localhost:5432/labdb?sslmode=disable"
	}

	var err error
	db, err = sql.Open("postgres", databaseURL)
	if err != nil {
		log.Printf("❌ Erreur connexion PostgreSQL: %v", err)
		return
	}

	if err = db.Ping(); err != nil {
		log.Printf("❌ Impossible de ping PostgreSQL: %v", err)
		return
	}

	log.Println("✅ Connexion PostgreSQL établie")

	// Créer la table des tâches
	createTable := `
	CREATE TABLE IF NOT EXISTS tasks (
		id SERIAL PRIMARY KEY,
		title VARCHAR(200) NOT NULL,
		description TEXT,
		completed BOOLEAN DEFAULT FALSE,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	)`

	if _, err := db.Exec(createTable); err != nil {
		log.Printf("❌ Erreur création table: %v", err)
		return
	}

	// Insérer des données d'exemple
	var count int
	db.QueryRow("SELECT COUNT(*) FROM tasks").Scan(&count)

	if count == 0 {
		sampleTasks := []Task{
			{Title: "Apprendre Docker", Description: "Maîtriser les concepts de base de Docker", Completed: false},
			{Title: "Créer un Dockerfile", Description: "Écrire un Dockerfile optimisé", Completed: true},
			{Title: "Utiliser Docker Compose", Description: "Orchestrer plusieurs conteneurs", Completed: false},
			{Title: "Déployer en production", Description: "Mettre en production avec Docker", Completed: false},
		}

		for _, task := range sampleTasks {
			_, err := db.Exec(
				"INSERT INTO tasks (title, description, completed) VALUES ($1, $2, $3)",
				task.Title, task.Description, task.Completed,
			)
			if err != nil {
				log.Printf("❌ Erreur insertion tâche: %v", err)
			}
		}
		log.Println("✅ Données d'exemple insérées")
	}
}

func initRedis() {
	redisURL := os.Getenv("REDIS_URL")
	if redisURL == "" {
		redisURL = "redis://localhost:6379"
	}

	opt, err := redis.ParseURL(redisURL)
	if err != nil {
		log.Printf("❌ Erreur parsing Redis URL: %v", err)
		return
	}

	redisClient = redis.NewClient(opt)

	ctx := context.Background()
	if err := redisClient.Ping(ctx).Err(); err != nil {
		log.Printf("❌ Erreur connexion Redis: %v", err)
		redisClient = nil
		return
	}

	log.Println("✅ Connexion Redis établie")
}

func setupRoutes(router *gin.Engine) {
	// Route racine
	router.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message":     "🐹 Docker Go App",
			"version":     "1.0.0",
			"timestamp":   time.Now(),
			"environment": os.Getenv("GIN_MODE"),
			"hostname":    getHostname(),
		})
	})

	// Health check
	router.GET("/health", healthCheck)

	// API routes
	api := router.Group("/api")
	{
		api.GET("/tasks", getTasks)
		api.POST("/tasks", createTask)
		api.GET("/tasks/:id", getTask)
		api.PUT("/tasks/:id", updateTask)
		api.DELETE("/tasks/:id", deleteTask)
		api.GET("/stats", getStats)
		api.GET("/info", getSystemInfo)
		api.GET("/counter", getCounter)
	}
}

func healthCheck(c *gin.Context) {
	status := HealthStatus{
		Status:    "healthy",
		Timestamp: time.Now(),
		Services:  make(map[string]string),
		Hostname:  getHostname(),
		Uptime:    time.Since(startTime).String(),
	}

	// Test PostgreSQL
	if db != nil {
		if err := db.Ping(); err != nil {
			status.Services["database"] = "disconnected"
			status.Status = "degraded"
		} else {
			status.Services["database"] = "connected"
		}
	} else {
		status.Services["database"] = "disconnected"
		status.Status = "degraded"
	}

	// Test Redis
	if redisClient != nil {
		ctx := context.Background()
		if err := redisClient.Ping(ctx).Err(); err != nil {
			status.Services["redis"] = "disconnected"
			status.Status = "degraded"
		} else {
			status.Services["redis"] = "connected"
		}
	} else {
		status.Services["redis"] = "disconnected"
		status.Status = "degraded"
	}

	if status.Status == "healthy" {
		c.JSON(http.StatusOK, status)
	} else {
		c.JSON(http.StatusServiceUnavailable, status)
	}
}

func getTasks(c *gin.Context) {
	ctx := context.Background()

	// Vérifier le cache Redis
	if redisClient != nil {
		cached, err := redisClient.Get(ctx, "tasks").Result()
		if err == nil {
			var tasks []Task
			if json.Unmarshal([]byte(cached), &tasks) == nil {
				c.JSON(http.StatusOK, gin.H{
					"data":   tasks,
					"source": "cache",
					"count":  len(tasks),
				})
				return
			}
		}
	}

	// Requête base de données
	rows, err := db.Query("SELECT id, title, description, completed, created_at, updated_at FROM tasks ORDER BY created_at DESC")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	var tasks []Task
	for rows.Next() {
		var task Task
		err := rows.Scan(&task.ID, &task.Title, &task.Description, &task.Completed, &task.CreatedAt, &task.UpdatedAt)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		tasks = append(tasks, task)
	}

	// Mettre en cache pour 5 minutes
	if redisClient != nil {
		tasksJSON, _ := json.Marshal(tasks)
		redisClient.SetEX(ctx, "tasks", string(tasksJSON), 5*time.Minute)
	}

	c.JSON(http.StatusOK, gin.H{
		"data":   tasks,
		"source": "database",
		"count":  len(tasks),
	})
}

func createTask(c *gin.Context) {
	var task Task
	if err := c.ShouldBindJSON(&task); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if task.Title == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Title is required"})
		return
	}

	err := db.QueryRow(
		"INSERT INTO tasks (title, description, completed) VALUES ($1, $2, $3) RETURNING id, created_at, updated_at",
		task.Title, task.Description, task.Completed,
	).Scan(&task.ID, &task.CreatedAt, &task.UpdatedAt)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Invalider le cache
	if redisClient != nil {
		ctx := context.Background()
		redisClient.Del(ctx, "tasks")
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Task created successfully",
		"task":    task,
	})
}

func getTask(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid task ID"})
		return
	}

	var task Task
	err = db.QueryRow(
		"SELECT id, title, description, completed, created_at, updated_at FROM tasks WHERE id = $1",
		id,
	).Scan(&task.ID, &task.Title, &task.Description, &task.Completed, &task.CreatedAt, &task.UpdatedAt)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Task not found"})
		return
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": task})
}

func updateTask(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid task ID"})
		return
	}

	var task Task
	if err := c.ShouldBindJSON(&task); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	result, err := db.Exec(
		"UPDATE tasks SET title = $1, description = $2, completed = $3, updated_at = CURRENT_TIMESTAMP WHERE id = $4",
		task.Title, task.Description, task.Completed, id,
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Task not found"})
		return
	}

	// Invalider le cache
	if redisClient != nil {
		ctx := context.Background()
		redisClient.Del(ctx, "tasks")
	}

	c.JSON(http.StatusOK, gin.H{"message": "Task updated successfully"})
}

func deleteTask(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid task ID"})
		return
	}

	result, err := db.Exec("DELETE FROM tasks WHERE id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Task not found"})
		return
	}

	// Invalider le cache
	if redisClient != nil {
		ctx := context.Background()
		redisClient.Del(ctx, "tasks")
	}

	c.JSON(http.StatusOK, gin.H{"message": "Task deleted successfully"})
}

func getStats(c *gin.Context) {
	stats := make(map[string]interface{})

	// Statistiques base de données
	if db != nil {
		var totalTasks, completedTasks int
		db.QueryRow("SELECT COUNT(*) FROM tasks").Scan(&totalTasks)
		db.QueryRow("SELECT COUNT(*) FROM tasks WHERE completed = true").Scan(&completedTasks)

		stats["total_tasks"] = totalTasks
		stats["completed_tasks"] = completedTasks
		stats["pending_tasks"] = totalTasks - completedTasks
	}

	// Statistiques Redis
	if redisClient != nil {
		ctx := context.Background()
		visits := redisClient.Incr(ctx, "api_visits").Val()
		stats["api_visits"] = visits
	}

	c.JSON(http.StatusOK, gin.H{
		"stats":     stats,
		"timestamp": time.Now(),
		"hostname":  getHostname(),
	})
}

func getCounter(c *gin.Context) {
	if redisClient == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "Redis not available"})
		return
	}

	ctx := context.Background()
	count := redisClient.Incr(ctx, "page_counter").Val()

	c.JSON(http.StatusOK, gin.H{
		"visits":  count,
		"message": fmt.Sprintf("Cette page a été visitée %d fois", count),
	})
}

func getSystemInfo(c *gin.Context) {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)

	info := SystemInfo{
		Hostname:      getHostname(),
		GoVersion:     runtime.Version(),
		OS:            runtime.GOOS,
		Architecture:  runtime.GOARCH,
		NumCPU:        runtime.NumCPU(),
		NumGoroutines: runtime.NumGoroutine(),
		MemoryUsage:   fmt.Sprintf("%.2f MB", float64(m.Alloc)/1024/1024),
		Timestamp:     time.Now(),
	}

	c.JSON(http.StatusOK, info)
}

func getHostname() string {
	hostname, err := os.Hostname()
	if err != nil {
		return "unknown"
	}
	return hostname
}
