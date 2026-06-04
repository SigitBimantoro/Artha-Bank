package main

import (
	"artha/config"
	"artha/controllers"
	"artha/handlers"
	"artha/jobs"
	"artha/repositories"
	"artha/routes"
	"artha/services"

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
	r.Static("/uploads", "./uploads")
	routes.SetupRoutes(r, authController, transactionController, historyController, savingController, favoriteHandler)
	c := cron.New()
	c.AddFunc("0 0 * * *", func() {
		jobs.ProsesAutoDebit(config.DB) // (Ganti config.DB dengan variabel database-mu)
	})
	c.Start()
	r.Run("0.0.0.0:8080")
}
