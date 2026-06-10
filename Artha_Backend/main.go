package main

import (
	"artha/config"
	"artha/controllers"
	"artha/handlers"
	"artha/jobs"
	"artha/repositories"
	"artha/routes"
	"artha/services"

	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/robfig/cron/v3"
)

func main() {
	config.ConnectDB()
	services.MulaiRobotPenyapu(config.DB)
	authController := &controllers.AuthController{
		DB: config.DB,
	}
	transactionController := &controllers.TransactionController{DB: config.DB}
	historyController := &controllers.HistoryController{DB: config.DB}
	savingController := &controllers.SavingController{DB: config.DB}

	favoriteRepository := repositories.NewFavoriteRepository(config.DB)
	favoriteService := services.NewFavoriteService(favoriteRepository)
	favoriteHandler := handlers.NewFavoriteHandler(favoriteService)

	r := gin.Default()

	// CORS Middleware
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		// Allow custom headers used by Flutter client (e.g. X-PIN) and Authorization
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, X-PIN, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE, PATCH")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		c.Next()
	})

	r.Static("/uploads", "./uploads")
	routes.SetupRoutes(r, authController, transactionController, historyController, savingController, favoriteHandler)
	loc, err := time.LoadLocation("Asia/Jakarta")
	if err != nil {
		loc = time.FixedZone("WIB", 7*60*60)
	}
	c := cron.New(cron.WithLocation(loc))
	c.AddFunc("0 0 * * *", func() {
		jobs.ProsesAutoDebit(config.DB)
	})
	c.Start()
	r.Run("0.0.0.0:8080")
}
