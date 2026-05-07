package main

import (
	"artha/config"
	"artha/controllers"
	"artha/routes"
	"artha/services"

	"github.com/gin-gonic/gin"
)

func main() {
	config.ConnectDB()
	services.MulaiRobotPenyapu(config.DB)
	authController := &controllers.AuthController{
		DB: config.DB,
	}
	transactionController := &controllers.TransactionController{DB: config.DB}
	r := gin.Default()
	routes.SetupRoutes(r, authController, transactionController)
	r.Run("0.0.0.0:8080")
}